/bin/mount -n -t proc proc /proc
/bin/mount -n -t sysfs sysfs /sys
/bin/mount -n -t tmpfs dev /dev
#sh /bin/cp -a /lib/udev/devices/* /dev
/sbin/udevd --daemon
/sbin/udevadm trigger
/sbin/udevadm settle
/sbin/fsck -A -T -C -a
#fsck_check
/sbin/hwclock --adjust
/sbin/hwclock --hctosys
/bin/mount -n -o remount,rw /
#sh /bin/rm -f /etc/mtab*
/bin/cp /proc/mounts /etc/mtab
/bin/mount -a
#sh /bin/rm -rf /etc/nologin /etc/shutdownpid /var/lock/* /tmp/* /tmp/.* /forcefsck &>/dev/null
/bin/find /var/run ! -type d -exec rm -f -- {} ;
/bin/cp /dev/null /var/run/utmp
/bin/chmod 0664 /var/run/utmp
/bin/mkdir /tmp/.ICE-unix
/bin/chmod 1777 /tmp/.ICE-unix
/bin/mkdir /tmp/.X11-unix
/bin/chmod 1777 /tmp/.X11-unix
/sbin/ifconfig lo 127.0.0.1 up
#subprogram startup
