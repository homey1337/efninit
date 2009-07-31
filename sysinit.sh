/bin/mount -n -t proc proc /proc
/bin/mount -n -t sysfs sysfs /sys
/bin/mount -n -t tmpfs dev /dev
#sh /bin/cp -a /lib/udev/devices/* /dev
/sbin/udevd --daemon
/sbin/udevadm trigger
/sbin/udevadm settle
/sbin/hwclock --adjust
/sbin/hwclock --hctosys
/sbin/fsck -A -T -C -a
#fsck_check
/bin/mount -n -o remount,rw /
/bin/rm -f /etc/mtab
/bin/cp /proc/mounts /etc/mtab
/bin/mount -a
/bin/find /etc/nologin /forcefsck /var/run /var/lock ! -type d -exec /bin/rm -f -- {} ;
/bin/cp /dev/null /var/run/utmp
/bin/chmod 0664 /var/run/utmp
/sbin/ifconfig lo 127.0.0.1 up
#subprogram startup
