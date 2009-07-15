#subprogram shutdown
#term_then_kill
/bin/umount -a
/bin/mount -o remount,ro /
#sync
