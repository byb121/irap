#; -*- mode: Makefile;-*-
# =========================================================
# Copyright 2012,  Nuno A. Fonseca (nuno dot fonseca at gmail dot com)
#
# This file is part of iRAP.
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with iRAP.  If not, see <http://www.gnu.org/licenses/>.
#
#
#    $Id: 0.1.3 Nuno Fonseca Fri Dec 21 11:56:56 2012$
# =========================================================
# Rules for creating the reports

BROWSER_DIR=jbrowse

# useful functions
define mapping_dirs=
$(shell ls -d -1 $(1)/*/*.hits.bam 2>/dev/null  | sed "s|/[^/]*.bam||" | sort -u| grep -E "($(shell echo $(SUPPORTED_MAPPERS)| sed 's/ /|/g'))")
endef

define bam_files=
$(shell ls -d -1 $(1)/*/*.hits.bam 2>/dev/null | sort -u)
endef

define de_dirs=
$(shell ls -d -1 $(1)/*/*/* 2>/dev/null| grep -E "($(shell echo $(SUPPORTED_DE_METHODS)| sed 's/ /|/g'))$$")
endef

define quant_dirs=
$(shell ls -d -1 $(1)/*/* 2>/dev/null| grep -E "($(shell echo $(SUPPORTED_QUANT_METHODS)| sed 's/ /|/g'))$$")
endef

# 1 - exp name
define de_html_files=
$(subst $(name)/,$(name)/report/,$(foreach d,$(call de_dirs,$(1)),$(subst .tsv,.html,$(call quiet_ls,$(d)/*_de.tsv))))
endef

#1 HTML FILE 
#2 OUTDIR
#3 cuffdiff files
#	$(if $(3),irap_cuffdiff_plots.R $(annot_tsv) $(2) $(1).tmp "$(3)" && mv $(1).tmp $(1),)
define  gen_cuffdiff1_report=
	$(info TODO: cuffdiff report)
endef

#1 HTML FILE 
#2 OUTDIR
#3 TSV files
define  gen_deseq_reports=
	$(foreach tsv,$(3),$(call DE_tsv2html,deseq,$(3),$(2),$(subst .tsv,.html,$(basename $(tsv)))))
endef

# 1 metric
# 2 TSV file
# 3 out dir
# 4 out file
# 5 title
# --anotation ....
#
define DE_tsv2html=
	tsvDE2html --flavour $(1) --tsv $(2) --out $(3)/$(4) --cut-off $(de_pvalue_cutoff) --species $(species) --feature $(call DEfilename2AL,$(2)) --browser ../../../$(BROWSER_DIR)/ --css ../../../irap.css --title "$(5)" -a $(annot_tsv) -m $(de_num_genes_per_table)
endef


# 1 metric
# 2 TSV file
# 3 out dir
# 4 out file
# 5 title
# 6 feature
# --anotation ....
define GE_tsv2html=
	tsvGE2html -m $(1) --tsv $(2) --out $(3)/$(4) --species $(species) --feature $(call DEfilename2AL,$(2)) --browser ../../../../$(BROWSER_DIR)/ --css ../../../../irap.css --title "$(5)" -a $(annot_tsv)  --gdef "$(call groupsdef2str)" --gnames "$(call groups2str)" -f $(6)
endef

#-x min value
#-r replicates
#-f feature (gene,exon,CDS)

#1 DEST FILE
#2 OUTDIR
#3 TSV FILE
define  gen_htseq_report=
	$(if $(3),irap_htseq_report.R $(2) $(3) $(de_min_count) && touch $(1),)
endef

# 1- pat
define quiet_ls=
$(shell ls -1 $(1) 2>/dev/null)
endef

ifndef IRAP_REPORT_MAIN_OPTIONS
IRAP_REPORT_MAIN_OPTIONS=
endif
# 
ifdef reuse_menu
IRAP_REPORT_MAIN_OPTIONS += --reuse-menu
endif


##############################################################################
# Produce a HTML report
#report: $(name)/report/index.html mapping_report quant_report de_report
phony_targets+=report_setup


report_setup: $(name)/report/ $(name)/report/mapping/ $(name)/report/de/ $(name)/report/quant/ $(call rep_browse,report_browser_setup)

$(name)/report/:
	mkdir -p $@

$(name)/report/mapping/:
	mkdir -p $@

$(name)/report/de/:
	mkdir -p $@

$(name)/report/quant/:
	mkdir -p $@


#########################
#mapping_report de_report
# TODO: remove/fix this in the future (currently necessary to update the menu)
end_report: report_setup $(conf) $(name)/report/mapping/comparison.html
	irap_report_main $(IRAP_REPORT_MAIN_OPTIONS) --conf $(conf) --rep_dir $(name)/report -m "$(call mapping_dirs,$(name))" -q "$(call quant_dirs,$(name))" -d "$(call de_dirs,$(name))"

$(name)/report/index.html: report_setup $(conf) 
	irap_report_main $(IRAP_REPORT_MAIN_OPTIONS) --conf $(conf) --rep_dir $(name)/report -m "$(call mapping_dirs,$(name))" -q "$(call quant_dirs,$(name))" -d "$(call de_dirs,$(name))" && \
	cp $(name)/report/info.html $@


phony_targets+=mapping_report quant_report

mapping_report_targets=$(foreach m,$(call mapping_dirs,$(name)), $(name)/report/mapping/$(shell basename $(m)).html) $(name)/report/mapping/comparison.html 

mapping_report_files:
	echo $(mapping_report_targets)

mapping_report: report_setup $(mapping_report_targets)


$(name)/report/mapping/%.html: $(name)/%/  $(foreach p,$(pe),$(name)/%/$(p).pe.hits.bam) $(foreach s,$(se),$(name)/%/$(s).se.hits.bam)
	irap_report_mapping $@.tmp $* "$(foreach p,$(pe),;$(name)/$*/$(p).pe.hits.bam)" "$(foreach s,$(se),;$(name)/$*/$(s).se.hits.bam)"  "$(foreach p,$(pe),;$(p))" "$(foreach s,$(se),;$(s))"  && \
	mv $@.tmp.html $(name)/report/mapping/$*.html 


#$(name)/report/mapping/%/align_overall_comparison.png.tsv: 
#	$(call p_error, BAM files missing? Unable to generate $(name)/report/mapping/$*.html)

$(name)/report/mapping/%/align_overall_comparison.png.tsv: $(name)/report/mapping/%.html


# M
# 
define only_existing_files=
$(foreach f,$(1),$(if $(realpath $(f)),$(f) ,))
endef

define mappersFromReportPath=
$(subst /align_overall_comparison.png.tsv,,$(subst $(name)/report/mapping/,,$(1)))
endef

# only perform the comparison on the existing TSV files
$(name)/report/mapping/comparison.html: $(call only_existing_files,$(foreach m,$(call mapping_dirs,$(name)), $(name)/report/mapping/$(shell basename $(m))/align_overall_comparison.png.tsv))
	mappers_comp_sum.R --tsv "$^" --labels "$(foreach f,$^, $(call mappersFromReportPath,$(f)))" --out $(@D)/comparison --css  ../../irap.css && touch $@
#	mappers_comp_sum.R --tsv "$^" --labels "$(foreach m,$(call mapping_dirs,$(name)), $(shell basename $(m)))" --out $(@D)/comparison --css  ../irap.css && touch $@


# detailed info per bam
$(name)/report/mapping/$(mapper)/%/index.html: FORCE
	bam_report.R $(name)/$(mapper)/$(call bam_file_for_lib,$*) $(@D) "$(call libname2fastq,$*)"

########################
phony_targets+=quant_report quant_report_files
silent_targets+=quant_report quant_report_files

quant_html_files=$(foreach m,$(call quant_dirs,$(name)), $(if $(call quiet_ls,$(m)/genes.raw.*.tsv),$(name)/report/quant/$(subst /,_x_,$(subst $(name)/,,$(m))).html,))

quant_report: report_setup $(quant_html_files)

quant_report_files: 
	echo $(quant_html_files)

#######################################
# Quant. at gene level
$(name)/report/quant/%/gene.raw.html: 
	$(call GE_tsv2html,"raw",$(call quiet_ls,$(name)/$(subst _x_,/,$*)/genes.raw.$(shell echo $*|sed "s/.*_x_//").tsv),$(@D),gene.raw.t,$(subst _x_, x ,$*),"gene") && \
	cp $(subst .html,,$@).t.html $@

$(name)/report/quant/%/gene.rpkm.html: 
	$(call GE_tsv2html,"rpkm",$(call quiet_ls,$(name)/$(subst _x_,/,$*)/genes.rpkm.$(shell echo $*|sed "s/.*_x_//").tsv),$(@D),gene.rpkm.t,$(subst _x_, x ,$*),"gene") && \
	cp $(subst .html,,$@).t.html $@

# TODO: nlib
# TODO: level: exon+transcript

##########################
# one rule by quant option
$(name)/report/quant/%_x_htseq1.html: $(name)/report/quant/%_x_htseq1/gene.raw.html
	touch $@

$(name)/report/quant/%_x_htseq2.html: $(name)/report/quant/%_x_htseq2/gene.raw.html
	touch $@

$(name)/report/quant/%_x_flux_cap.html: $(name)/report/quant/%_x_flux_cap/gene.raw.html
	touch $@

$(name)/report/quant/%_x_basic.html: $(name)/report/quant/%_x_basic/gene.raw.html
	touch $@

$(name)/report/quant/%_x_cufflinks1_nd.html: $(name)/report/quant/%_x_cufflinks1_nd/gene.raw.html
	touch $@

$(name)/report/quant/%_x_cufflinks1.html: $(name)/report/quant/%_x_cufflinks1/gene.raw.html
	touch $@

$(name)/report/quant/%_x_cufflinks2.html: $(name)/report/quant/%_x_cufflinks2/gene.raw.html
	touch $@

$(name)/report/quant/%_x_cufflinks2_nd.html: $(name)/report/quant/%_x_cufflinks2/gene.raw.html
	touch $@

$(name)/report/quant/%_x_scripture.html: 
	$(info TODO: complete $@)
	touch $@

############################
# DE
phony_targets+=de_report de_report_files
silent_targets+=de_report_files

de_report: report_setup $(call de_html_files,$(name))
# just print the name of the files that will be produced
de_report_files:
	echo $(call de_html_files,$(name))
#############################
# Report

$(name)/report/%.genes_de.html: $(name)/%.genes_de.tsv $(annot_tsv)
	mkdir -p $(@D)
	$(call DE_tsv2html,$(subst _nd,,$(call DEfilepath2demethod,$@)),$<,$(@D),$(subst .html,,$(shell basename $@)),$(subst /, x ,$*))
