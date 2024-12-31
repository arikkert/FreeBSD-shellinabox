.PHONY: configure distclean patch unpatch install clean remove start stop
USER=nobody
GROUP=nobody
PORT=4200

all: shellinabox shellinabox/Makefile shellinabox/Makefile.org shellinabox/shellinaboxd shellinabox/shellinaboxd /usr/local/bin/shellinaboxd

shellinabox:
	git clone https://github.com/shellinabox/shellinabox

shellinabox/Makefile configure:
	cd shellinabox; \
	autoreconf -i; \
	./configure

distclean:
	cd shellinabox; \
	make $@;

shellinabox/Makefile.org patch:
	cd shellinabox; \
	if ! test -f Makefile.org; \
	then \
		cp -p Makefile Makefile.org; \
		sed -E 's/(^LIBS.*)/\1-lssl -lcrypto /' Makefile.org > Makefile; \
	fi;

unpatch:
	rm -f shellinabox/Makefile.org
	rm -f shellinabox/Makefile

# build
shellinabox/shellinaboxd:
	cd shellinabox; \
	make;

/usr/local/bin/shellinaboxd install:
	cd shellinabox; \
	sudo make install;

clean:
	cd shellinabox; \
	make $@;

uninstall:
	cd shellinabox; \
	sudo make $@;

remove:
	rm -rf shellinabox

start:
	/usr/local/bin/shellinaboxd --user=$(USER) --group=$(GROUP) --port=$(PORT) --background=/var/run/shellinaboxd.pid

stop:
	kill $$(cat /var/run/shellinaboxd.pid)
