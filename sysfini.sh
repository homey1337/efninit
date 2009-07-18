#subprogram shutdown
/sbin/hwclock --systohc
#term_then_kill
/bin/umount /dev/pts
/bin/umount -a
/bin/mount -o remount,ro /
#sync
