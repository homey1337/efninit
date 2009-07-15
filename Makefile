init:	init.c sysinit.c sysfini.c
	${CC} ${CFLAGS} init.c -o init

sys%.c:	sys%.sh make_sys_c.py
	python make_sys_c.py $<

install:
	mkdir -p /etc/uinit.d/
	cp init startup shutdown task /etc/uinit.d/

clean:
	rm -f *.o sys*.c

distclean:	clean
	rm -f init
