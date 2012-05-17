# Hi Emacs, this is a -*- Makefile -*-

# Let's start with things to configure:
# $MUPAD_DDKDIR should be imported from the environment.
# If you don't want that, you can set it in the following line instead:
MUPAD_DDKDIR?=/path/to/MuPAD/DDK/

# The name of your package, as used in the package() command.
PACKAGE=demoPack1

# This will become the name of the compiled file
LIB=numfuns

# Which languages do you have documentation for?
LANGUAGES=eng de


# end of configuration
#######################################################################################

ifeq ($(wildcard $(MUPAD_DDKDIR)),)
$(error Could not find MuPAD DDK, please set MUPAD_DDKDIR!)
endif

# This ugly stuff down here does about the same thing as 
# $(shell which bash), the difference being that it works and
# does not start a new subshell first.
# Make, please use
SHELL=$(firstword $(wildcard $(addsuffix /bash,$(subst :, ,$(PATH)) /usr/local/gnu/bin)))

CWD=$(shell pwd)

# space-separated PATH
SPATH=$(subst :, ,$(PATH))

# default value if not overridden on the command line
LANGUAGE=eng
# no subdirectories are possible
SOURCES?=$(wildcard *.mupdoc)

USELANG:=$(findstring $(LANGUAGE),$(LANGUAGES))
BUILDDIR:=$(LANGUAGE)/build
PICDIR:=$(BUILDDIR)
HTMLDIRPREFIX:=$(LANGUAGE)
HTMLDIR:=$(HTMLDIRPREFIX)/$(LIB)
ASCIIDIRPREFIX:=$(LANGUAGE)/ascii
ASCIIDIR:=$(ASCIIDIRPREFIX)/$(LIB)
MKDIR=mkdir -p

DTDDIR:=$(MUPAD_DDKDIR)/DTD

XSLDIR:=$(MUPAD_DDKDIR)/XSL
MUPJAR:=$(XSLDIR)/JAVA/mupdoc.jar
RESJAR:=$(XSLDIR)/JAVA/resolver.jar
MUPDOC2ANY:=$(XSLDIR)/MuPADdoc2whatever.xsl
MUPDOC2MN_SRC:=$(XSLDIR)/MuPADdoc2mn.xsl
MUPDOC2MN:=$(XSLDIR)/MuPADdoc2mn.sxx
MUPDOC2TEX_SRC:=$(XSLDIR)/MuPADdoc2texml.xsl
MUPDOC2TEX:=$(XSLDIR)/MuPADdoc2texml.sxx
MUPDOC2HTML:=$(XSLDIR)/MuPADdoc2html.xsl
MUPDOC2SUM:=$(XSLDIR)/MuPADdoc2summary.xsl
PREPHTML:=$(XSLDIR)/prepHTML.xsl
IDX2CONT:=$(XSLDIR)/index2content.xsl
IDX2SET:=$(XSLDIR)/index2settings.xsl
GETSTRUCT:=$(XSLDIR)/collectstructure.xsl

ifeq ($(wildcard $(MUPDOC2ANY)),)
$(error Could not find MuPAD DDK, please set MUPAD_DDKDIR!)
endif

CHECKSCRIPT:=$(MUPAD_DDKDIR)/TOOLS/checkInteractively.rb
BUILDCONT:=$(MUPAD_DDKDIR)/TOOLS/buildContent.rb
IDX2TOP:=$(MUPAD_DDKDIR)/TOOLS/index2topics.rb
READCONT:=$(MUPAD_DDKDIR)/TOOLS/readCont.pl
BUFFER:=$(MUPAD_DDKDIR)/TOOLS/bufferOutput $(MAKEFLAGS)
FIXHTML:=$(MUPAD_DDKDIR)/TOOLS/post-html.rb
SRCHIDX:=$(MUPAD_DDKDIR)/TOOLS/srchidx.rb

DOCBOOKCAT=/usr/share/xml/docbook/schema/dtd/4.3/catalog

SAXONJAR:=$(XSLDIR)/JAVA/saxon8.jar
SAXONCATALOGJAR:=$(XSLDIR)/JAVA/resolver.jar

SAXON=java -cp '$(DTDDIR):$(MUPJAR):$(SAXONCATALOGJAR):$(SAXONJAR)' \
  -Dxml.catalog.files=$(DOCBOOKCAT)\;$(DTDDIR)/catalog \
  net.sf.saxon.Transform \
  -r org.apache.xml.resolver.tools.CatalogResolver \
  -x org.apache.xml.resolver.tools.ResolvingXMLReader \
  -y org.apache.xml.resolver.tools.ResolvingXMLReader \
  -w0
SAXONCOMPILE=java -cp '$(DTDDIR):$(MUPJAR):$(SAXONCATALOGJAR):$(SAXONJAR)' \
  net.sf.saxon.Compile \
  -r org.apache.xml.resolver.tools.CatalogResolver


MUPKERN=$(firstword $(wildcard $(addsuffix /mupkern,$(SPATH))))
ifeq ($(MUPKERN),)
$(error Could not find MuPAD, please set MUPKERN=<path to mupkern>!)
endif
VERSION=$(shell $(MUPKERN) -V)
MUPADUI=$(firstword $(wildcard $(addsuffix /dmupad,$(SPATH)) $(addsuffix /mupad,$(SPATH))) mupad)
XSLARGS=libname=$(LIB) language=$(LANGUAGE) mupad=$(MUPKERN) builddir=$(CWD)/$(BUILDDIR) linktargets=$(CWD)/commands.xml options=$(CWD)/options.xml structure=$(CWD)/$(BUILDDIR)/index.structure topdir=.. version=$(VERSION) mupadui=$(MUPADUI)

CHECKSCRIPTARGS= --picdir $(PICDIR) --language $(LANGUAGE) --MuPAD $(MUPKERN) --initcmd 'package("$(PACKAGE)");'

MOREOPTIONFILES=

.PHONY:: default html check testinstall clean xmlclean testclean
ifeq ($(USELANG),)
# nothing to do for this language
install:

quick:

html:

prephtml:

ascii:

copypics:

check:

else
install:: $(LANGUAGE)/$(LIB).muphlp
	-mkdir -p ../../doc/`echo $(LANGUAGE) | cut -b1-2`
	cp $< ../../doc/`echo $(LANGUAGE) | cut -b1-2`

quick: $(BUILDDIR)
	touch $(BUILDDIR)/_*.xml
	[ -r $(BUILDDIR)/index.xml ] && touch $(BUILDDIR)/index.xml
	$(MAKE) default LANGUAGE=$(LANGUAGE)


SUMMARY_FILES=$(addprefix $(BUILDDIR)/,$(subst .mupdoc,.summary,$(SOURCES))) commands.xml options.xml

html: $(addprefix $(HTMLDIR)/,$(subst .mupdoc,.html,$(SOURCES))) $(HTMLDIR)/images

prephtml: $(addprefix $(HTMLDIR)/,$(subst .mupdoc,.mn,$(SOURCES))) $(HTMLDIR)/images

copypics:
	-@(echo -n Copying pictures ...; \
	 $(MKDIR) $(BUILDDIR) || true; \
	 $(MKDIR) $(BUILDDIR)/PICTURES || true; \
	 [ -d PICTURES ] && cp PICTURES/*.* $(BUILDDIR)/PICTURES/ || true; \
	 [ -d ../PICTURES ] && cp ../PICTURES/*.* $(BUILDDIR)/PICTURES/ || true; \
	 echo ' done') 2>&1 | $(BUFFER)


.PHONY:: ascii
ascii:: $(addprefix $(ASCIIDIR)/,$(subst .mupdoc,.help,$(SOURCES)))

check: $(addprefix $(BUILDDIR)/,$(subst .mupdoc,.check,$(SOURCES)))
endif

clean::
	-rm -rf eng de ja commands.xml options.xml

xmlclean::
	-rm */build/*.xml commands.xml options.xml

testclean::
	-rm */build/*.check

MUPHELP_EXTRA=_mimetype.txt _help_version.txt _help_content.xml \
	_help_topics.xml _content.xml _settings.xml _search_index.xml
MUPHELP_FILES=$(subst .mupdoc,.xml,$(SOURCES)) $(MUPHELP_EXTRA)


ifeq ($(USELANG),)
.PHONY:: $(LANGUAGE) $(LANGUAGE)/*
$(LANGUAGE):

$(LANGUAGE)/%:

else
$(LANGUAGE)/$(LIB).muphlp: $(SUMMARY_FILES) $(BUILDDIR)/index.structure $(addprefix $(BUILDDIR)/,$(MUPHELP_FILES))
	@(echo -n packing $(LIB).muphlp ...; \
	 rm -f $@ || true; \
	 cd $(BUILDDIR); zip -9 -q $(CWD)/$@ $(MUPHELP_EXTRA) \
	   `$(READCONT) _content.xml`; \
	 echo ' done.') 2>&1 | $(BUFFER)
endif

# to always rebuild:
.PHONY:: $(BUILDDIR)/_help_version.txt $(BUILDDIR)/_content.xml
$(BUILDDIR)/_help_version.txt: $(BUILDDIR)
	@perl -e 'print localtime, "\n"' > $@

$(BUILDDIR)/_content.xml: $(BUILDDIR) copypics $(addprefix $(BUILDDIR)/,$(subst .mupdoc,.xml,$(SOURCES)))
	@(set -e; echo -n Creating _content.xml ...; \
	cd $(BUILDDIR); $(BUILDCONT) $(LIB) > _content.xml; \
	echo ' done.') 2>&1 | $(BUFFER)

$(BUILDDIR)/_settings.xml:
	@(set -e; echo -n Creating _settings.xml ...; \
	$(MKDIR) $(BUILDDIR) || true; \
	 $(SAXON) -o $@ index.mupdoc $(IDX2SET) $(XSLARGS) || (rm $@; exit 1); \
	echo ' done.') 2>&1 | $(BUFFER)

$(BUILDDIR)/_help_content.xml: $(SUMMARY_FILES) $(IDX2CONT)
	@(set -e; echo -n Creating _help_content.xml ...; \
	$(MKDIR) $(BUILDDIR) || true; \
	 $(SAXON) -o $@ index.mupdoc $(IDX2CONT) $(XSLARGS) || (rm $@; exit 1); \
	echo ' done.') 2>&1 | $(BUFFER)

$(BUILDDIR)/_mimetype.txt:
	@$(MKDIR) $(BUILDDIR) || true; \
	 echo "application/x-mupad-help+zip" > $@

$(BUILDDIR)/_help_topics.xml: $(BUILDDIR)/index.structure $(IDX2TOP)
	@(set -e; echo -n Creating _help_topics.xml ...; \
	$(MKDIR) $(BUILDDIR) || true; \
	 ruby $(IDX2TOP) -l $(LANGUAGE) --filename $(LIB) $< > $@ || (rm $@; exit 1); \
	echo ' done.') 2>&1 | $(BUFFER)

$(BUILDDIR)/_search_index.xml: $(addprefix $(BUILDDIR)/,$(filter-out _search_index.xml,$(MUPHELP_FILES))) $(BUILDDIR)/_content.xml
	@(set -e; echo -n Creating search index ...; \
	  cd $(BUILDDIR); env LANG=$(LANGUAGE) $(SRCHIDX) _content.xml > _search_index.xml; \
	  echo ' done.') 2>&1 | $(BUFFER)

$(BUILDDIR)/index.structure: $(SUMMARY_FILES) $(GETSTRUCT)
	@(set -e; echo -n Creating index.structure ...; \
	cd $(BUILDDIR); $(SAXON) -o index.structure.new index.summary \
	  $(GETSTRUCT) $(XSLARGS) || (rm index.structure; exit 1); \
	  cmp -s index.structure.new index.structure || \
	    cp index.structure.new index.structure; \
	echo ' done.') 2>&1 | $(BUFFER)

$(BUILDDIR)/index.xml:: $(SUMMARY_FILES)

$(BUILDDIR)/%.xml:: %.mupdoc $(MUPDOC2MN) $(BUILDDIR)/index.structure
	@set -e; \
	(echo -n Compiling $< ...; \
	$(MKDIR) $(BUILDDIR) || true; \
	 ($(SAXON) -o $@ -c $< $(MUPDOC2MN) $(XSLARGS) self=$<) \
	 2>&1 | perl -pe 'print "\n" if 1..1' || (rm $@; exit 1); \
	echo " done.") 2>&1 | $(BUFFER)

$(MUPDOC2MN): $(MUPDOC2MN_SRC)  $(MUPDOC2ANY) $(XSLDIR)/plot2whatever.xsl $(SAXONJAR) $(SAXONCATALOGJAR)
	@cd $(XSLDIR); $(SAXONCOMPILE) MuPADdoc2mn.xsl MuPADdoc2mn.sxx

$(BUILDDIR)/%.summary: %.mupdoc $(MUPDOC2SUM)
	@(set -e; echo -n Summarizing $< ...; \
	 $(MKDIR) $(BUILDDIR) || true; \
	 $(SAXON) -o $@ $< $(MUPDOC2SUM) $(XSLARGS)\
	 2>&1 | perl -pe 'print "\n" if 1..1' || (rm $@; exit 1); \
	echo " done.") 2>&1 | $(BUFFER)


$(BUILDDIR):
	@$(MKDIR) $@ || true



############################################################

$(HTMLDIR)/images: $(TOPDIR)/WEB/images
	@$(MKDIR) $(HTMLDIR)/images || true;
	@cp -r $</* $(HTMLDIR)/images/

# for html generation, we must have individual notebooks:

$(HTMLDIR)/%.mn: $(HTMLDIR)/mntemplate.zip
	@ln -sf $(CWD)/$< $@

.PRECIOUS: $(HTMLDIR)/%.mn $(HTMLDIR)/mntemplate.zip

$(HTMLDIR)/%.xml: $(BUILDDIR)/%.xml
	@(set -e; $(MKDIR) $(HTMLDIR) || true; \
	$(SAXON) -o $@ $< $(PREPHTML))

$(HTMLDIR)/%.txt: $(BUILDDIR)/%.txt
	@(set -e; $(MKDIR) $(HTMLDIR) || true; \
	cp $< $@)

# must rm first because zip returns 
# an "error" code of 12 when it has nothing to do.   ARGH.
$(HTMLDIR)/mntemplate.zip: $(SUMMARY_FILES) $(BUILDDIR)/index.structure $(addprefix $(HTMLDIR)/,$(MUPHELP_FILES)) $(BUILDDIR)
	@(echo -n Packing mntemplate ...; \
	set -e; $(MKDIR) $(HTMLDIR) || true; \
	(cd $(HTMLDIR); \
	  find $(CWD)/$(BUILDDIR)/* -maxdepth 0 -type d \
	   -exec cp -r {} . \; ; \
	  (zip -9 -q mntemplate.zip _settings.xml _mimetype.txt _content.xml \
	    `$(READCONT) _content.xml`; \
	   ERR=$$?; if [ $$ERR -ne 12 ]; then exit $$ERR; fi)) ; \
	 echo " done.") 2>&1 | $(BUFFER)

$(HTMLDIR)/_content.xml: $(BUILDDIR)/_content.xml
	@set -e; $(MKDIR) $(HTMLDIR) || true; \
	  cp $< $@

$(HTMLDIR)/_mimetype.txt:
	$(MKDIR) $(HTMLDIR) || true; \
	 echo "application/x-mupad-notebook+zip" > $@


$(HTMLDIR)/%.html: $(HTMLDIR)/%.mn
	@(set -e; echo -n Converting $* to html ...; \
	cd $(HTMLDIR); $(MUPADUI) -convert-html -main-content $*.xml $*.mn 2>& 1 | \
	  grep -v 'Xlib:  extension "XFree86-DRI" missing on display' | \
	  grep -v 'libstd++.so.6: No version information available' | \
	  perl -ne 'print unless /X Error: BadDevice, invalid or uninitialized input device 169/../Failed to open device/' | \
	  perl -pe 'print "\n" if 1..1'; \
	$(FIXHTML) $*.html; \
	echo " done.") 2>&1 | $(BUFFER)

$(HTMLDIR):
	@$(MKDIR) $@ || true

############################################################

$(ASCIIDIR)/%.help:: $(BUILDDIR)/%.xml
	@(echo -n Converting $< to ascii ...; \
	 set -e; \
         $(MKDIR) $(ASCIIDIR) || true; \
	 (($(TOPDIR)/TOOLS/mn2ascii.rb -m $(MUPKERN) $<) | \
	  grep -v -- ' → Examples' | \
	  grep -v -- ' → Beispiele'  > $@) || rm $@; \
	 echo " done.") 2>&1 | $(BUFFER)


$(ASCIIDIR):
	$(MKDIR) $@ || true

############################################################

$(BUILDDIR)/%.check: %.mupdoc $(CHECKSCRIPT)
	@(echo -n Checking $< ...; \
	$(MKDIR) $(BUILDDIR) || true; \
	 $(MKDIR) $(BUILDDIR)/$* || true; \
	 env LANG=en_US.utf8 ruby $(CHECKSCRIPT) --no $(CHECKSCRIPTARGS) \
	    $< > $@ || (rm $@; exit 1); \
	 echo " done.") 2>&1 | $(BUFFER)

############################################################

.PHONY:: accept-changes %.accept

accept-changes: $(subst .mupdoc,.accept,$(SOURCES))

%.accept:
	-@$(MKDIR) $(BUILDDIR)/$*
	env LANG=en_US.utf8 ruby $(CHECKSCRIPT) $(CHECKSCRIPTARGS) $*.mupdoc

############################################################

$(BUILDDIR)/%.options: %.mupdoc $(XSLDIR)/collectOptions.sxx
	@(set -e; echo -n Collecting options used in $* ...; \
	$(MKDIR) $(BUILDDIR) || true; \
	 $(SAXON) -o $@ -c $< $(XSLDIR)/collectOptions.sxx \
	 $(XSLARGS) self=$< 2>&1 | perl -pe 'print "\n" if 1..1'; \
	echo ' done.') 2>&1 | $(BUFFER)

$(XSLDIR)/collectOptions.sxx: $(XSLDIR)/collectOptions.xsl $(SAXONJAR) $(SAXONCATALOGJAR)
	@cd $(XSLDIR); $(SAXONCOMPILE) collectOptions.xsl collectOptions.sxx

options.xml: $(addprefix $(BUILDDIR)/,$(subst .mupdoc,.options,$(SOURCES)) $(MOREOPTIONFILES))
	@(set -e; echo -n Collecting options ...; \
	echo '<wrapper>' > $@; \
	for file in $(BUILDDIR)/*.options; do grep 'option' $$file >> $@ || true; done; \
	echo '</wrapper>' >> $@; \
	echo ' done.') 2>&1 | $(BUFFER)


############################################################

commands.xml: $(filter-out commands.xml,$(SUMMARY_FILES)) $(XSLDIR)/collectcmds.xsl
	@(set -e; echo -n Collecting documented commands ...; \
	echo '<wrapper>' > $@; \
	$(SAXON) index.mupdoc $(XSLDIR)/collectcmds.xsl\
	 $(XSLARGS) >> $@ || (rm $@; exit 1); \
	echo >>$@; \
	echo '</wrapper>' >> $@; \
	echo ' done.') 2>&1 | $(BUFFER)

############################################################

view: $(LANGUAGE)/$(LIB).muphlp
	$(MUPADUI) -help-file $<


##################################################

.PHONY:: help

help::
	@echo
	@echo "Targets"
	@echo ""
	@echo " default:        create $(LANGUAGE)/$(LIB).muphlp"
	@echo "   and copy it to ../../doc/$(LANGUAGE), its final place"
	@echo " html:           create $(HTMLDIR) and its files"
	@echo "   to create individual files, use 'make $(HTMLDIR)/foo.html'"
	@echo " check:          check inputs/outputs, creating images along the way"
	@echo "   to check individual files, use 'make $(BUILDDIR)/foo.check'"
	@echo " accept-changes: check inputs/outputs, interactively"
	@echo "   to check individual files, use 'make foo.accept'"
	@echo " validate:       check XML syntax against DTD"
	@echo "   output is sent to filename.errors"
	@echo "   to validate individual files, use 'make foo.errors'"
	@echo " view:           create $(LANGUAGE)/$(LIB).muphlp and open MuPAD on it"
	@echo "   note: this won't work properly if MuPAD is already up and running"
	@echo
	@echo "Options"
	@echo
	@echo " LANGUAGE=de     create German version"
	@echo " LANGUAGE=ja     create Japanese version"
	@echo " MUPKERN=/path/to/mupkern  use other MuPAD version"
	@echo

##################################################

.PHONY:: validate validate-output
validate: $(subst .mupdoc,.errors,$(SOURCES))

FORCE:

%.errors: %.mupdoc FORCE
	-xmllint --noout --nonet \
	   --dropdtd --dtdvalid $(TOPDIR)/DTD/MuPADdoc.dtd $< \
	   >$@ 2>&1 && rm $@


