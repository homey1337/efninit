import sys

filename = sys.argv[1]
fn_name = filename.split('.')[0]

top_lines = list()
fn_lines = list()

_FS = '''
pid = fork();
if (!pid) {
  execv(%s_cmd_%%d[0], %s_cmd_%%d);
  _exit(1);
} else {
  wait(&stat_loc);
}
''' % (fn_name, fn_name)

def fork_stanza(pr_name, args):
  n = len(top_lines)
  sargs = ', '.join(['"%s"' % s for s in args])
  if sargs:
    sargs = '%s,' % sargs
  top_lines.append('char* %s_cmd_%d[] = {%s, %s NULL};'
    % (fn_name, n, pr_name, sargs))
  fn_lines.append(_FS % (n, n))

def process_special(line):
  tokens = line.split()
  if tokens[0] == '#subprogram':
    fork_stanza('SUBPROGRAM_BASE "%s"' % tokens[1], list())
  elif tokens[0] == '#term_then_kill':
    fn_lines.append('''
      kill(-1, SIGTERM);
      sleep(5);
      kill(-1, SIGKILL);
    ''')
  elif tokens[0] == '#sync':
    fn_lines.append('''
      sync();
      sleep(2);
    ''')
  elif tokens[0] == '#fsck_check':
    reboot_msg = 'rebooting in 3 secs...'
    top_lines.append('static const char* FSCK_REBOOT_MSG = "%s\\n";' % reboot_msg)
    fn_lines.append('''
      if (WIFEXITED(stat_loc) && WEXITSTATUS(stat_loc)&2 == 2) {
        write(2, FSCK_REBOOT_MSG, %d);
        sync();
        sleep(3);
        reboot(RB_AUTOBOOT);
      }
    ''' % (len(reboot_msg) + 1))
  elif tokens[0] == '#sh':
    command = ' '.join(tokens[1:])
    fork_stanza('"/bin/sh"', ['-c', command])
  else:
    print "homey don't play %s" % tokens[0]
    sys.exit(1)

f = open(filename, 'r')
for line in f:
  line = line.strip()
  if line.startswith('#'):
    process_special(line)
  else:
    tokens = line.split()
    command = tokens[0]
    rest = tokens[1:]
    fork_stanza('"%s"' % command, rest)

f.close()
f = open(fn_name + '.c', 'w')
print >>f, '''
#include <unistd.h>
#include <sys/reboot.h>
#include <sys/wait.h>
#include <sys/types.h>
#include "config.h"
'''
for line in top_lines:
  print >>f, line
print >>f, '''
int main() {
  int pid;
  int stat_loc;
'''
for line in fn_lines:
  print >>f, line
print >>f, '''
  return 0;
}
'''
