.PHONY: clone configure distclean patch unpatch install clean remove start stop
USER=nobody
GROUP=nobody
PORT=4200
HOSTNAME=$$(hostname)

all: shellinabox shellinabox/Makefile shellinabox/Makefile.org shellinabox/shellinaboxd shellinabox/shellinaboxd

shellinabox clone:
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

shellinabox/shellinaboxd build:
	cd shellinabox; \
	make;

/usr/local/bin/shellinaboxd install:
	cd shellinabox; \
	sudo make install;

man:
	man shellinaboxd

clean:
	cd shellinabox; \
	make $@;

uninstall:
	cd shellinabox; \
	sudo make $@;

start:
	@if ! test -f /var/run/shellinaboxd.pid; \
	then \
		echo "INFO Starting shellinabox"; \
		sudo /usr/local/bin/shellinaboxd --user=$(USER) --group=$(GROUP) --port=$(PORT) --background=/var/run/shellinaboxd.pid; \
		echo URL: http://$(HOSTNAME):$(PORT); \
	else \
		echo "WARN: Shellinabox already running on URL: http://$(HOSTNAME):$(PORT)"; \
	fi

stop:
	@if test -f /var/run/shellinaboxd.pid; \
	then \
		echo "INFO: Stopping shellinabox"; \
		sudo kill $$(cat /var/run/shellinaboxd.pid); \
		sudo rm /var/run/shellinaboxd.pid; \
	else \
		echo "WARN: Shellinabox not running"; \
	fi

remove:
	rm -rf shellinabox
