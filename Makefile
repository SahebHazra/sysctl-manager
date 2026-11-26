PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib/sysman/lib
DESTDIR ?=

.PHONY: all install uninstall

all:
	@echo "Sysman is a Bash application. Use 'make install' to install it."

install:
	@command -v systemctl >/dev/null 2>&1 || { echo "Error: systemctl is required." >&2; exit 1; }
	install -d "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(LIBDIR)"
	install -m 755 bin/sysman "$(DESTDIR)$(BINDIR)/sysman"
	install -m 644 lib/config.sh lib/services.sh "$(DESTDIR)$(LIBDIR)/"
	@echo "Sysman installed to $(BINDIR)/sysman"
	@echo "Run it with: sysman"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/sysman"
	rm -f "$(DESTDIR)$(LIBDIR)/config.sh" "$(DESTDIR)$(LIBDIR)/services.sh"
	-rmdir "$(DESTDIR)$(LIBDIR)" "$(DESTDIR)$(PREFIX)/lib/sysman" 2>/dev/null
	@echo "Sysman uninstalled."
