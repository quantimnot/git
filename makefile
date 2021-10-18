build:
	tup

test-pre-commit:
	shellcheck *.sh etc/git/hooks/*.sh bin/*.sh

format:
	shfmt -w *.sh etc/git/hooks/*.sh bin/*.sh

install: install.sh
	sh install.sh

uninstall: uninstall.sh
	sh uninstall.sh
