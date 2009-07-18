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

#include "config.h"

void subprogram(char* filename) {
  int pid = fork();
  if (!pid) {
    execl(filename, filename, NULL);
    _exit(1);
  } else {
    waitpid(pid, NULL, 0);
  }
}

void handle_sig(int sig) {
  subprogram(SUBPROGRAM_BASE "sysfini");

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
  
  subprogram(SUBPROGRAM_BASE "sysinit");

  for (;;) {
    subprogram(SUBPROGRAM_BASE "task");
    sleep(5);
  }

  return 0; // never happens
}
