all:	init sysinit sysfini

init:	init.o
	ld -s $< -o $@

%.o:	%.asm
	nasm -felf $< -o $@

sys%:	sys%.c
	$(CC) $(CFLAGS) $< -o $@

sys%.c:	sys%.sh make_sys_c.py
	python make_sys_c.py $<

install:	init sysinit sysfini
	mkdir -p /etc/efninit.d/
	cp -uv init sysfini sysinit default/* /etc/efninit.d/

clean:
	rm -f *.o sys*.c

distclean:	clean
	rm -f init
