;; the cornerstone of my vastly simplified init system
;;
;; it has several helper scripts that live in /etc/uinit.d/
;; 
;; startup: startup bits that you would want to configure
;;   hostname, network, console font, daemons, etc
;; task: the thing this computer does!
;;   task will be respawned if it quits/dies
;; shutdown: shutdown bits that you might want to configure
;;   cleanly close down any daemons you started in startup, etc

%define __NR_exit 1
%define __NR_fork 2
%define __NR_waitpid 7
%define __NR_execve 11
%define __NR_signal 48
%define __NR_reboot 88
%define __NR_nanosleep 162

%define SIGINT 2
%define SIGUSR1 10

%define SUBPROGRAM_BASE "/etc/uinit.d/"

%define LINUX_REBOOT_MAGIC1 0xfee1dead
%define LINUX_REBOOT_MAGIC2 672274793

%define RB_AUTOBOOT 0x1234567
%define RB_POWEROFF 0x4321fedc
%define RB_DISABLE_CAD 0

section .data

sysfini:
  db SUBPROGRAM_BASE, "sysfini", 0

sysfini_args:
  dd sysfini, 0

sysinit:
  db SUBPROGRAM_BASE, "sysinit", 0

sysinit_args:
  dd sysinit, 0

task:
  db SUBPROGRAM_BASE, "task", 0

task_args:
  dd task, 0

timespec:
  dd 5, 0

_path:
  db "PATH=/bin:/sbin:/usr/bin:/usr/sbin", 0

environ:
  dd _path, 0

section .text

global _start  
_start:
  mov eax, __NR_signal
  mov ebx, SIGINT
  mov ecx, handle_sig
  int 0x80
  
  mov eax, __NR_signal
  mov ebx, SIGUSR1
  mov ecx, handle_sig
  int 0x80

  mov eax, __NR_reboot
  mov ebx, LINUX_REBOOT_MAGIC1
  mov ecx, LINUX_REBOOT_MAGIC2
  mov edx, RB_DISABLE_CAD
  int 0x80

  mov ebx, sysinit
  mov ecx, sysinit_args
  call subprogram  

  .loop:
    mov ebx, task
    mov ecx, task_args
    call subprogram

    mov eax, __NR_nanosleep
    mov ebx, timespec
    xor ecx, ecx
    int 0x80
  jmp .loop

subprogram:
  mov eax, __NR_fork
  int 0x80
  or eax, eax
  jnz .wait
    mov eax, __NR_execve
    mov edx, environ
    int 0x80
    mov eax, __NR_exit
    mov ebx, 1
    int 0x80
  .wait:
    mov ebx, eax
    mov eax, __NR_waitpid
    xor ecx, ecx
    xor edx, edx
    int 0x80
    ret

handle_sig:
  push eax

  mov ebx, sysfini
  mov ecx, sysfini_args
  call subprogram

  mov edx, RB_POWEROFF
  pop eax  
  cmp eax, SIGUSR1
  je .poweroff
    mov edx, RB_AUTOBOOT
  .poweroff:
  mov eax, __NR_reboot
  mov ebx, LINUX_REBOOT_MAGIC1
  mov ecx, LINUX_REBOOT_MAGIC2
  int 0x80
