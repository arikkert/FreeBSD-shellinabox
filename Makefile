.PHONY: clone configure distclean patch unpatch install clean remove start stop
USER=nobody
GROUP=nobody
PORT=4200
PIDFILE=/var/run/shellinaboxd.pid
PID=$$(cat $(PIDFILE))
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
	if test shellinabox/Makefile.org; \
	then \
		mv shellinabox/Makefile.org shellinabox/Makefile; \
	fi

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
	@if ! test -f $(PIDFILE); \
	then \
		echo "INFO Starting shellinabox"; \
		sudo /usr/local/bin/shellinaboxd --user=$(USER) --group=$(GROUP) --port=$(PORT) --background=$(PIDFILE); \
		echo URL: http://$(HOSTNAME):$(PORT); \
	else \
		echo "WARN: Shellinabox already running on URL: http://$(HOSTNAME):$(PORT) as process $(PID)"; \
	fi

stop:
	@if test -f $(PIDFILE); \
	then \
		echo "INFO: Stopping shellinabox"; \
		sudo kill $(PID); \
		sudo rm $(PIDFILE); \
	else \
		echo "WARN: Shellinabox not running"; \
	fi

remove:
	rm -rf shellinabox
