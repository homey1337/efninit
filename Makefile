all:	init sysinit sysfini

init:	init.c
	${CC} ${CFLAGS} init.c -o init

sys%:	sys%.c
	$(CC) $(CFLAGS) $< -o $@

sys%.c:	sys%.sh make_sys_c.py
	python make_sys_c.py $<

install:	init sysinit sysfini
	mkdir -p /etc/uinit.d/
	cp init sysfini sysinit startup shutdown task /etc/uinit.d/

update:	init sysinit sysfini
	cp sysfini sysinit /etc/uinit.d/
	cp init /etc/uinit.d/newinit

clean:
	rm -f *.o sys*.c

distclean:	clean
	rm -f init
