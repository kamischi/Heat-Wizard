PREFIX ?= /usr/local/bin
LANGUAGES = en de fi

.PHONY: cli gui all clean install uninstall release

LAZARUS_OPTIONS=

ThisSystem:=$(shell uname)

ifeq ($(ThisSystem), Linux)
  LAZARUS_OPTIONS=--ws=gtk2
endif

all: cli gui

cli: heatwizard.pp
	fpc -O3 -CX -XX -OWall -FWheatwizard.wpo heatwizard.pp
	fpc -O3 -CX -XX -Owall -Fwheatwizard.wpo heatwizard.pp
	strip heatwizard

gui: HeatWizard.lpr *.pas version.inc *.lfm *.lrs *.lrt
ifneq "`which lazbuild`" ""
ifeq ($(ThisSystem), Darwin)
	lazbuild $(LAZARUS_OPTIONS) HeatWizard-MacOSX.lpi
else
	lazbuild $(LAZARUS_OPTIONS) HeatWizard-Linux.lpi
endif
else
	echo Lazarus not found. Please install lazarus and try again.
endif
ifneq "`which msgfmt`" ""
	make -C languages
else
	echo msgfmt not found. Please install gettext and try again.
endif

clean:
	rm -f *.ppu *.o *.exe *.rc *.wpo HeatWizard heatwizard HeatWizard.compiled

install:
	install -m 755 heatwizard $(PREFIX)

	@for language in $(LANGUAGES); do \
	  install -d                                    ~/.heatwizard/languages/$$language/LC_MESSAGES               ; \
	  install -v languages/heatwizard.$$language.mo ~/.heatwizard/languages/$$language/LC_MESSAGES/heatwizard.mo ; \
	done

uninstall:
	rm -rf $(PREFIX)/heatwizard
	rm -rf ~/.heatwizard

release: release-linux release-macosx

release-linux:
	tar -cz -f HeatWizard.tar.gz  README "GPL Header" COPYING Makefile HeatWizard.lpr version.inc *.lpi *.lrs *.lrt *.lfm *.pas languages/heatwizard.*.po languages/Makefile
	tar -cj -f HeatWizard.tar.bz2 README "GPL Header" COPYING Makefile HeatWizard.lpr version.inc *.lpi *.lrs *.lrt *.lfm *.pas languages/heatwizard.*.po languages/Makefile

release-macosx: macosx-app macosx-dmg

macosx-app: all
	strip Heat\ Wizard
	rm -f Heat\ Wizard.app/Contents/MacOS/Heat\ Wizard
	cp -f Heat\ Wizard            Heat\ Wizard.app/Contents/MacOS/Heat\ Wizard
	cp -f Heat\ Wizard\ Icon.icns Heat\ Wizard.app/Contents/Resources/Heat\ Wizard\ Icon.icns
	cp -f PkgInfo                 Heat\ Wizard.app/Contents/PkgInfo
	cp -f Info.plist              Heat\ Wizard.app/Contents/Info.plist

	@for language in $(LANGUAGES); do \
	  install -d                                    Heat\ Wizard.app/Contents/Resources/languages/$$language/LC_MESSAGES               ; \
	  install -v languages/heatwizard.$$language.mo Heat\ Wizard.app/Contents/Resources/languages/$$language/LC_MESSAGES/heatwizard.mo ; \
	done

macosx-dmg: Heat\ Wizard.app
	hdiutil create -type SPARSE -size 20m -fs HFS+ -volname Heat\ Wizard -ov Heat\ Wizard.sparseimage
	hdiutil attach Heat\ Wizard.sparseimage

	cp -fR Heat\ Wizard.app /Volumes/Heat\ Wizard
	rm -f Heat\ Wizard.app/Contents/MacOS/Heat\ Wizard

	./CreateApplicationFolderAlias.sh

	hdiutil detach /Volumes/Heat\ Wizard
	rm -f  Heat\ Wizard.dmg
	hdiutil convert Heat\ Wizard.sparseimage -format UDBZ -o Heat\ Wizard.dmg

	rm -f Heat\ Wizard.sparseimage