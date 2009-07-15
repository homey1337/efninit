/*
 the cornerstone of my vastly simplified init system

 it has several helper scripts that live in /etc/uinit.d/
 
 startup: startup bits that you would want to configure
   hostname, network, console font, daemons, etc
 task: the thing this computer does!
   task will be respawned if it quits/dies
 shutdown: shutdown bits that you might want to configure
   cleanly close down any daemons you started in startup, etc
*/

#include <unistd.h>
#include <signal.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <sys/wait.h>

#define SUBPROGRAM_BASE "/home/homey1337/pr/uinit/" // "/etc/uinit.d/"

#include "sysfini.c"
#include "sysinit.c"

#define RB_POWEROFF 0x4321fedc // from the reboot(2) manpage

void handle_sig(int sig) {
  sysfini();

  if (sig == SIGINT) {  
    reboot(RB_AUTOBOOT);
  } else {
    reboot(RB_POWEROFF);
  }
}

int main(int argc, char** argv) {
  signal(SIGINT, handle_sig);
  signal(SIGUSR1, handle_sig);
  reboot(RB_DISABLE_CAD);
  
  sysinit();

  for (;;) {
    int pid = fork();
    if (!pid) {
      execl(SUBPROGRAM_BASE "task", "task", NULL);
      _exit(1);
    } else {
      waitpid(pid, NULL, 0);
    }

    sleep(5);
  }

  return 0; // never happens
}
