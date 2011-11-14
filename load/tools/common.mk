#
#
#
# Normally building a common target from the sources may be of
#    *) one phrase: all source files can be transform into the target directly
#    *) two phrases:
#	1) all source files must be transformed into a intermediate format
#	2) the target file can be generated from the intermediate files.
# 

sm.tool.common := true

## common languages and their suffixes
sm.tool.common.langs := web cweb noweb TeX
sm.tool.common.suffix.web := .web
sm.tool.common.suffix.cweb := .w
sm.tool.common.suffix.noweb := .nw
sm.tool.common.suffix.TeX := .tex
sm.tool.common.suffix.LaTeX := .latex

## Set intermediate langs for tangle, ctangle, notangle, etc.
## 
## Only if the transformation is possible, will the variable be assigned
## to the target languange, the empty value tells that the transformation
## is not possible.
sm.tool.common.langs.intermediate.web := pascal TeX LaTeX
sm.tool.common.langs.intermediate.cweb := c c++ TeX LaTeX
sm.tool.common.langs.intermediate.noweb := c c++ TeX LaTeX

## known intermediate suffixes list, empty if no intermediates
sm.tool.common.suffix.intermediate.web = $(error common toolset: undetermined intermediate language)
sm.tool.common.suffix.intermediate.web.pascal := .p
sm.tool.common.suffix.intermediate.web.TeX := .tex
sm.tool.common.suffix.intermediate.web.LaTeX := .latex
sm.tool.common.suffix.intermediate.cweb = $(error common toolset: undetermined intermediate language)
sm.tool.common.suffix.intermediate.cweb.c = .c
sm.tool.common.suffix.intermediate.cweb.c++ = .cpp
sm.tool.common.suffix.intermediate.cweb.TeX = .tex
sm.tool.common.suffix.intermediate.cweb.LaTeX = .latex
sm.tool.common.suffix.intermediate.noweb = $(error common toolset: undetermined intermediate language)
sm.tool.common.suffix.intermediate.noweb.c := .c
sm.tool.common.suffix.intermediate.noweb.c++ := .cpp
sm.tool.common.suffix.intermediate.noweb.TeX := .tex
sm.tool.common.suffix.intermediate.noweb.LaTeX := .latex
sm.tool.common.suffix.intermediate.TeX = $(or $(sm.args.docs_format),.dvi)
sm.tool.common.suffix.intermediate.LaTeX = $(or $(sm.args.docs_format),.dvi)

##################################################
## common commands
sm.tool.common.CXX = g++
sm.tool.common.CC = gcc
sm.tool.common.CP = cp
sm.tool.common.PERL = perl
sm.tool.common.GPERF = gperf
sm.tool.common.ASM = as
sm.tool.common.FLEX = flex
#sm.tool.common.YACC = yacc
sm.tool.common.YACC = bison
sm.tool.common.AWK = gawk
sm.tool.common.MKDIR = mkdir
sm.tool.common.SED = sed

##################################################
define sm.tool.common._mv
$(if $(findstring x$(strip $2)x,x$(strip $1)x),true,mv $(strip $1) $(strip $2))
endef #sm.tool.common._mv

##
##
##
define sm.tool.common.compile.web.pascal
tangle $(sm.args.sources) && \
$(call sm.tool.common._mv,\
    $(word 1,$(sm.args.sources:%.web=%.p)),\
    $(sm.args.target))
endef #sm.tool.common.compile.web.pascal

## Literal source generation(for documentation)
define sm.tool.common.compile.web.TeX
weave $(sm.args.sources) && \
$(call sm.tool.common._mv,\
    $(word 1,$(sm.args.sources:%.web=%.p)),\
    $(sm.args.target))
endef #sm.tool.common.compile.web.TeX

sm.tool.common.compile.web.LaTeX = $(sm.tool.common.compile.web.TeX)

##
##
## xxx.w -> xxx.c or xxx.cpp
define sm.tool.common.compile.cweb.c
cd $(dir $(word 1,$(sm.args.sources))) && \
ctangle \
  $(notdir $(word 1,$(sm.args.sources))) \
  $(or $(word 2,$(sm.args.sources)),-) \
  $(notdir $(sm.args.target)) && cd - && \
$(call sm.tool.common._mv,\
   $(dir $(word 1,$(sm.args.sources)))$(notdir $(sm.args.target)),\
   $(sm.args.target))
endef #sm.tool.common.compile.cweb.c

##
##
## xxx.w -> xxx.tex
define sm.tool.common.compile.cweb.TeX
cd $(dir $(word 1,$(sm.args.sources))) && \
cweave \
  $(notdir $(word 1,$(sm.args.sources))) \
  $(or $(word 2,$(sm.args.sources)),-) \
  $(notdir $(sm.args.target)) && cd - && \
mv \
  $(dir $(word 1,$(sm.args.sources)))$(notdir $(sm.args.target)) \
  $(dir $(word 1,$(sm.args.sources)))$(basename $(notdir $(sm.args.target))).idx \
  $(dir $(word 1,$(sm.args.sources)))$(basename $(notdir $(sm.args.target))).scn \
  $(dir $(sm.args.target))
endef #sm.tool.common.compile.cweb.TeX

sm.tool.common.compile.cweb.c++ = $(sm.tool.common.compile.cweb.c)
sm.tool.common.compile.cweb.LaTeX = $(sm.tool.common.compile.cweb.TeX)

##
##
##
define sm.tool.common.compile.noweb.private
notangle -$(sm.args.lang) $(sm.args.sources) && \
$(call sm.tool.common._mv,\
    $(word 1,$(sm.args.sources:%.nw=%.p)),\
    $(sm.args.target))
endef #sm.tool.common.compile.noweb.private

##
define sm.tool.common.compile.noweb.private
noweave -$(sm.args.lang) $(sm.args.sources) && \
$(call sm.tool.common._mv,\
    $(word 1,$(sm.args.sources:%.nw=%.p)),\
    $(sm.args.target))
endef #sm.tool.common.compile.noweb.private

sm.tool.common.compile.web   = $(error undetermined intermediate language for web)
sm.tool.common.compile.cweb  = $(error undetermined intermediate language for cweb)
sm.tool.common.compile.noweb = $(error undetermined intermediate language for noweb)

##################################################

define sm.tool.common.compile.TeX-LaTeX.private
cd $(dir $(word 1,$(sm.args.sources))) && \
$1 -interaction=nonstopmode $(notdir $(word 1,$(sm.args.sources))) && \
rm -vf $(basename $(notdir $(word 1,$(sm.args.sources)))).log && \
rm -vf $(basename $(notdir $(word 1,$(sm.args.sources)))).toc && \
cd - && \
[[ "$(dir $(word 1,$(sm.args.sources)))" == "$(dir $(sm.args.target))" ]] || \
mv \
   $(dir $(word 1,$(sm.args.sources)))$(basename $(notdir $(word 1,$(sm.args.sources)))).$2 \
   $(dir $(sm.args.target))
endef #sm.tool.common.compile.TeX-LaTeX.private

##
## Plain TeX compilation commands
## -> DVI output
define sm.tool.common.compile.TeX.dvi.private
$(call sm.tool.common.compile.TeX-LaTeX.private,tex,dvi)
endef #sm.tool.common.compile.TeX.dvi.private

## -> PDF output
define sm.tool.common.compile.TeX.pdf.private
$(call sm.tool.common.compile.TeX-LaTeX.private,pdftex,pdf)
endef #sm.tool.common.compile.TeX.pdf.private

##
## LaTeX compilation commands
## -> DVI output
define sm.tool.common.compile.LaTeX.dvi.private
$(call sm.tool.common.compile.TeX-LaTeX.private,latex,dvi)
endef #sm.tool.common.compile.LaTeX.dvi.private

## -> PDF output
define sm.tool.common.compile.LaTeX.pdf.private
$(call sm.tool.common.compile.TeX-LaTeX.private,pdflatex,pdf)
endef #sm.tool.common.compile.LaTeX.pdf.private

sm.tool.common.compile.TeX = $(sm.tool.common.compile.TeX$(sm.args.docs_format).private)
sm.tool.common.compile.LaTeX = $(sm.tool.common.compile.LaTeX$(sm.args.docs_format).private)

##################################################

define sm.tool.common.rm
$(error deprecated sm.tool.common.rm)\
$(if $1,rm -f $1)
endef #sm.tool.common.rm

define sm.tool.common.rmdir
$(error deprecated sm.tool.common.rmdir)\
$(if $1,rm -rf $1)
endef #sm.tool.common.rmdir

define sm.tool.common.mkdir
$(error deprecated sm.tool.common.mkdir)\
$(if $1,mkdir -p $1)
endef #sm.tool.common.mkdir

define sm.tool.common.cp
$(error deprecated sm.tool.common.cp)\
$(if $(and $1,$2),cp $1 $2,\
  $(error smart: copy command requires more than two args))
endef #sm.tool.common.cp

define sm.tool.common.mv
$(error deprecated sm.tool.common.mv)\
$(if $(and $1,$2),mv $1 $2,\
  $(error smart: move command requires more than two args))
endef #sm.tool.common.mv

define sm.tool.common.ln
$(error deprecated sm.tool.common.ln)\
$(if $(and $1,$2),ln -sf $1 $2)
endef #sm.tool.common.ln
