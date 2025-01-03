.PHONY: clone configure distclean patch unpatch install man clean remove start stop

USER=nobody
GROUP=nobody
PORT=4200
PID=$$(cat $(PIDFILE))
HOSTNAME=$$(hostname)
REPO=shellinabox
PROGRAM=shellinabox
DAEMON=$(PROGRAM)d
PIDFILE=/var/run/$(DAEMON).pid

all: build

$(REPO) clone:
	git clone https://github.com/shellinabox/$(REPO)

$(REPO)/Makefile configure: $(REPO)
	@cd $(REPO); \
	autoreconf -i; \
	./configure

distclean: $(REPO)
	cd $(REPO); \
	make $@

$(REPO)/Makefile.org patch: $(REPO)/Makefile
	@cd $(REPO); \
	if ! test -f Makefile.org; \
	then \
		cp -p Makefile Makefile.org; \
		sed -E 's/(^LIBS.*)/\1-lssl -lcrypto /' Makefile.org > Makefile; \
	fi

unpatch:
	@if test $(REPO)/Makefile.org; \
	then \
		mv $(REPO)/Makefile.org $(REPO)/Makefile; \
	fi

$(REPO)/$(DAEMON) build: $(REPO)/Makefile.org
	@cd $(REPO); \
	make

/usr/local/bin/$(DAEMON) install: $(REPO)/Makefile.org
	@cd $(REPO); \
	sudo make install

man: /usr/local/bin/$(DAEMON)
	@man $(DAEMON)

clean:
	@if test -f $(REPO)/Makefile; \
	then \
		cd $(REPO); \
		sudo make $@; \
	fi

uninstall: $(REPO)
	@cd $(REPO); \
	sudo make $@

start: /usr/local/bin/$(DAEMON)
	@if ! test -f $(PIDFILE); \
	then \
		echo "INFO Starting $(PROGRAM)"; \
		sudo /usr/local/bin/$(DAEMON) --user=$(USER) --group=$(GROUP) --port=$(PORT) --background=$(PIDFILE); \
		echo URL: http://$(HOSTNAME):$(PORT); \
	else \
		echo "WARN: $(PROGRAM) already running on URL: http://$(HOSTNAME):$(PORT) as process $(PID)"; \
	fi

stop:
	@if test -f $(PIDFILE); \
	then \
		echo "INFO: Stopping $(PROGRAM)"; \
		sudo kill $(PID); \
		sudo rm $(PIDFILE); \
	else \
		echo "WARN: $(PROGRAM) not running"; \
	fi

status:
	@if test -f $(PIDFILE); \
	then \
		ps ax | grep $(PIDFILE) | grep -vw grep | grep -vw test; \
	else \
		if ps ax | grep -w $(DAEMON) | grep -vw test | grep -vw grep ; \
		then \
			echo "No pidfile $(PIDFILE) found but proces found"; \
		else \
			echo "INFO: $(PROGRAM) not running"; \
		fi; \
	fi

remove rm: clean
	rm -rf $(REPO)
