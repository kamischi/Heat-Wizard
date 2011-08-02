#
# Makefile to make the internationalization files for Heat Wizard
# Add a 2 letter code when adding a language
#

LANGUAGES=en de fi fr es

#
# No need to add after this line.
#

OBJECTS=$(addprefix heatwizard.,$(LANGUAGES))
MOOBJECTS=$(addsuffix .mo,$(OBJECTS))

.SUFFIXES: .mo .po

%.mo: %.po
	msgfmt -o $@ $?

all: $(MOOBJECTS)
