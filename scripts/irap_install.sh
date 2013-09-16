#!/bin/env bash
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
#   $Id: 0.1.3 Nuno Fonseca Fri Dec 21 17:18:21 2012$
# =========================================================
install=all
IRAP_DIR1=
SRC_DIR=

USE_CACHE=y
#############
function pinfo {
    echo "[INFO] $*"
}

function usage {
    echo "Usage: irap_install.sh  -s irap_toplevel_directory [ -c dir -a dir -a -u -m -r -p -q -b]  ";
    echo " -s dir : toplevel irap clone directory";
    echo " -c dir : install/update IRAP core files only to directory 'dir'. If dir is not given the value of IRAP_DIR will be used (if available).";
    echo " -a dir : install/update all files (core and 3rd party software) to directory 'dir' (default)";
    echo " -u : update IRAP_core files (alias to -c $IRAP_DIR).";
    echo " -m : update mappers.";
    echo " -r : update R packages.";
    echo " -p : update Perl packages.";
    echo " -q : update quantifiers.";
    echo " -b : update jbrowser.";
    echo " Advanced options:";
    echo " -d : only download all software and libraries (except R and Perl packages).";
    echo " -x software: install/update software.";
}

function download {
    FILE2DOWNLOAD=$1
    FILE2=$2
    
    if [ "$FILE2-" == "-" ]; then
	FILE2=`basename $FILE2DOWNLOAD`
    fi
    
    if [ "$USE_CACHE-" == "y-" ]; then
	# avoid copying
	rm -f $FILE2
	ln -s $SRC_DIR/download/$FILE2 .
    else
	set +e
	if [ $OS == "linux" ]; then	    
	    wget  --no-check-certificate -c -nc -L "$FILE2DOWNLOAD" -O $FILE2
	else
	    curl $FILE2DOWNLOAD
	fi
	set -e
    fi
}
############################################
# download everything to the download folder
function download2cache {

    USE_CACHE=n
    mkdir -p $SRC_DIR/download
    pushd $SRC_DIR/download
    PACKAGES2DOWNLOAD=`set  | grep _URL=|sed "s/_URL.*//"|grep -v "PACKAGES"|uniq`
    echo $PACKAGES2DOWNLOAD > /dev/stderr
    for p in $PACKAGES2DOWNLOAD; do
	URL=${p}_URL
	FILE=${p}_FILE
	pinfo "Downloading ($p)  ${!URL}"
	download_software $p
	if [ ! -e ${!FILE} ]; then
	    echo "Failed downloading $p ${!URL}" > /dev/stderr
	    exit 1
	else
	    ls -lh ${!FILE}
	fi
    done
    pinfo "Downloaded files in $SRC_DIR/download"
}
#################################
# VERSIONS, SRC file and URL
BFAST_VERSION=0.7.0a
BFAST_FILE=bfast-$BFAST_VERSION.tar.gz
BFAST_URL=http://sourceforge.net/projects/bfast/files/bfast/0.7.0/$BFAST_FILE

bowtie1_VERSION=0.12.9
bowtie1_FILE=bowtie-${bowtie1_VERSION}-linux-x86_64.zip
bowtie1_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie/$bowtie1_VERSION/$bowtie1_FILE

bowtie2_VERSION=2.1.0
bowtie2_FILE=bowtie2-${bowtie2_VERSION}-linux-x86_64.zip
bowtie2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/$bowtie2_VERSION/$bowtie2_FILE

GEM_VERSION=1.6-i3
GEM_FILE=GEM-gemtools-${GEM_VERSION}.tar.gz
GEM_URL=http://barnaserver.com/gemtools/$GEM_FILE
#GEM_VERSION=20121106-022124
#GEM_FILE=GEM-binaries-Linux-x86_64-core_i3-$GEM_VERSION.tbz2
#GEM_URL=http://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%202/$GEM_FILE/download


tophat1_VERSION=1.4.1
tophat1_FILE=tophat-${tophat1_VERSION}.Linux_x86_64.tar.gz
tophat1_URL=http://tophat.cbcb.umd.edu/downloads/$tophat1_FILE

tophat2_VERSION=2.0.8
tophat2_FILE=tophat-${tophat2_VERSION}.Linux_x86_64.tar.gz
tophat2_URL=http://tophat.cbcb.umd.edu/downloads/$tophat2_FILE

SMALT_VERSION=0.6.4
SMALT_FILE=smalt-$SMALT_VERSION.tgz
SMALT_URL=ftp://ftp.sanger.ac.uk/pub4/resources/software/smalt/$SMALT_FILE

SOAPsplice_VERSION=1.10
SOAPsplice_FILE=SOAPsplice-v$SOAPsplice_VERSION.tar.gz
SOAPsplice_URL=http://soap.genomics.org.cn/down/$SOAPsplice_FILE

SOAP2_VERSION=2.21
SOAP2_FILE=soap${SOAP2_VERSION}release.tar.gz
SOAP2_URL=http://soap.genomics.org.cn/down/$SOAP2_FILE

STAR_VERSION=2.2.0
STAR_FILE=STAR_${STAR_VERSION}c.Linux_x86_64.gz
STAR_URL=ftp://ftp2.cshl.edu/gingeraslab/tracks/STARrelease/$STAR_VERSION/$STAR_FILE

GSNAP_VERSION=2012-07-20
GSNAP_FILE=gmap-gsnap-${GSNAP_VERSION}.tar.gz
GSNAP_URL=http://research-pub.gene.com/gmap/src/$GSNAP_FILE

bwa_VERSION=0.6.2
bwa_FILE=bwa-${bwa_VERSION}.tar.bz2
bwa_URL=http://sourceforge.net/projects/bio-bwa/files/$bwa_FILE

osa_VERSION=2.0.1
osa_FILE=OSAv$osa_VERSION.zip
osa_URL=http://www.omicsoft.com/osa/software/$osa_FILE

EMBAM_VERSION=0.1.10
EMBAM_FILE=emBAM_${EMBAM_VERSION}.tar.gz
EMBAM_URL=http://embam.googlecode.com/files/$EMBAM_FILE

RUBY_VERSION=1.9.3-p448
RUBY_FILE=ruby-${RUBY_VERSION}.tar.gz
RUBY_URL=http://ftp.ruby-lang.org/pub/ruby/1.9/$RUBY_FILE

PERL_VERSION=5.16.3
PERL_FILE=perl-$PERL_VERSION.tar.gz
PERL_URL=http://www.cpan.org/src/5.0/$PERL_FILE

BOOST_VERSION=1.52.0
BOOST_FILE=boost_`echo $BOOST_VERSION|sed "s/\./_/g"`.tar.bz2
BOOST_URL=http://sourceforge.net/projects/boost/files/boost/$BOOST_VERSION/$BOOST_FILE

gnuplot_VERSION=4.6.0   
gnuplot_FILE=gnuplot-$gnuplot_VERSION.tar.gz
gnuplot_URL=http://sourceforge.net/projects/gnuplot/files/gnuplot/$gnuplot_VERSION/$gnuplot_FILE

R_VERSION=2.15.2
R_FILE=R-${R_VERSION}.tar.gz 
R_URL=http://cran.r-project.org/src/base/R-2/$R_FILE

SAMTOOLS_VERSION=0.1.18
SAMTOOLS_FILE=samtools-$SAMTOOLS_VERSION.tar.bz2
SAMTOOLS_URL=http://sourceforge.net/projects/samtools/files/samtools/$SAMTOOLS_VERSION/$SAMTOOLS_FILE

BEDTOOLS_VERSION=2.17.0
BEDTOOLS_FILE=BEDTools.v$BEDTOOLS_VERSION.tar.gz
BEDTOOLS_URL=http://bedtools.googlecode.com/files/$BEDTOOLS_FILE
   
cufflinks1_VERSION=1.3.0
cuffdiff1_VERSION=1.3.0
cufflinks1_FILE=cufflinks-${cufflinks1_VERSION}.Linux_x86_64.tar.gz
cufflinks1_URL=http://cufflinks.cbcb.umd.edu/downloads/$cufflinks1_FILE

cufflinks2_VERSION=2.1.1
cuffdiff2_VERSION=2.1.1
cufflinks2_FILE=cufflinks-${cufflinks2_VERSION}.Linux_x86_64.tar.gz
cufflinks2_URL=http://cufflinks.cbcb.umd.edu/downloads/$cufflinks2_FILE

#IReckon_VERSION=1.0.6
#IReckon_FILE=IReckon-$IReckon_VERSION.jar
#IReckon_URL=http://compbio.cs.toronto.edu/ireckon/$IReckon_FILE

#SAVANT_VERSION=2.0.3
#SAVANT_FILE=Savant-${SAVANT_VERSION}-Linux-x86_64-Install 
#SAVANT_URL=http://genomesavant.com/savant/dist/v`echo $SAVANT_VERSION|sed "s/./_/g"`/$SAVANT_FILE

BitSeq_VERSION=0.4.3
BitSeq_FILE=BitSeq-$BitSeq_VERSION.tar.gz
BitSeq_URL=http://bitseq.googlecode.com/files/$BitSeq_FILE

MMSEQ_VERSION=1.0.0-beta2
MMSEQ_FILE=mmseq_${MMSEQ_VERSION}.zip
MMSEQ_URL=http://www.bgx.org.uk/software/$MMSEQ_FILE

htseq_VERSION=0.5.3p9
htseq_FILE=HTSeq-${htseq_VERSION}.tar.gz
htseq_URL=http://pypi.python.org/packages/source/H/HTSeq/$htseq_FILE

FLUX_CAPACITOR_VERSION=1.2.3-20121215021902
FLUX_CAPACITOR_FILE=flux-capacitor-$FLUX_CAPACITOR_VERSION.tgz
FLUX_CAPACITOR_URL=http://sammeth.net/artifactory/barna-nightly/barna/barna.capacitor/$FLUX_CAPACITOR_VERSION/$FLUX_CAPACITOR_FILE

NURD_VERSION=1.08
NURD_FILE=NURD_v${NURD_VERSION}.tar.gz
NURD_URL=http://bioinfo.au.tsinghua.edu.cn/software/NURD/share/$NURD_FILE

SCRIPTURE_VERSION=beta2
SCRIPTURE_FILE=scripture-${SCRIPTURE_VERSION}.jar 
SCRIPTURE_URL=ftp://ftp.broadinstitute.org/pub/papers/lincRNA/$SCRIPTURE_FILE

IGV_VERSION=2.1.24
IGV_FILE=IGV_$IGV_VERSION.zip
IGV_URL=http://www.broadinstitute.org/igv/projects/downloads/$IGV_FILE

IGV_TOOLS_VERSION=2.1.24
IGV_TOOLS_FILE=igvtools_nogenomes_$IGV_TOOLS_VERSION.zip
IGV_TOOLS_URL=http://www.broadinstitute.org/igv/projects/downloads/$IGV_TOOLS_FILE

FASTX_VERSION=0.0.13
FASTX_FILE=fastx_toolkit_${FASTX_VERSION}_binaries_Linux_2.6_amd64.tar.bz2
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/$FASTX_FILE

FASTQC_VERSION=0.10.1
FASTQC_FILE=fastqc_v${FASTQC_VERSION}.zip
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/$FASTQC_FILE

JBROWSE_VERSION=1.7.5
JBROWSE_FILE=download.php?id=35
JBROWSE_URL=http://jbrowse.org/wordpress/wp-content/plugins/download-monitor/$JBROWSE_FILE
JBROWSE_EXTRA_UTILS="hgGcPercent bedGraphToBigWig wigCorrelate bigWigInfo bigWigSummary faToNib faToTwoBit hgWiggle"
JBROWSE_EXTRA_UTILSURL=http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/

NEW_JBROWSE_VERSION=1.9.8
NEW_JBROWSE_FILE=download.php?id=59
NEW_JBROWSE_URL=http://jbrowse.org/wordpress/wp-content/plugins/download-monitor/$JBROWSE_FILE
NEW_JBROWSE_EXTRA_UTILS="hgGcPercent bedGraphToBigWig wigCorrelate bigWigInfo bigWigSummary faToNib faToTwoBit hgWiggle"
NEW_JBROWSE_EXTRA_UTILSURL=http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/

MONO_VERSION=2.10.8
MONO_FILE=mono-${MONO_VERSION}.tar.gz    
MONO_URL=http://download.mono-project.com/sources/mono/$MONO_FILE

MAKE_VERSION=3.82
MAKE_FILE=make-${MAKE_VERSION}.tar.gz
MAKE_URL=http://ftp.gnu.org/gnu/make/$MAKE_FILE
##################################
function download_software {
    name=$1
    case $name in
	bfast ) download $BFAST_URL $BFAST_FILE;;
	star ) download $STAR_URL $STAR_FILE;;
	gsnap ) download $GSNAP_URL $GSNAP_FILE;;
	smalt ) download $SMALT_URL $SMALT_FILE;;
	soap_splice ) download $SOAPsplice_URL;;
	soap2 ) download $SOAP2_URL;download http://soap.genomics.org.cn/down/soap2sam.tar.gz;;
	SOAP2 ) download $SOAP2_URL;download http://soap.genomics.org.cn/down/soap2sam.tar.gz;;
	JBROWSE ) download $JBROWSE_URL $JBROWSE_FILE; for f in $JBROWSE_EXTRA_UTILS; do  download $JBROWSE_EXTRA_UTILSURL/$f $f; done ;;
	NEW_JBROWSE ) download $NEW_JBROWSE_URL $NEW_JBROWSE_FILE; for f in $NEW_JBROWSE_EXTRA_UTILS; do  download $NEW_JBROWSE_EXTRA_UTILSURL/$f $f; done ;;
	* ) url=${name}_URL; file=${name}_FILE; download ${!url} ${!file};;
    esac
}

# install all program files (binaries, libraries,...) in a folder of the bin directory
# 
function install_binary {
    PROGNAME=$1
    SRCDIR=$2
    TDIR=$BIN_DIR/$PROGNAME/bin
    shift 2
    FILES=$*

    pushd $SRCDIR
    mkdir -p $TDIR    
    chmod +x $FILES
    cp -rf $FILES $TDIR
    popd
}

function gen_setup_irap {
    cat <<EOF > $1
export IRAP_DIR=$IRAP_DIR
export PATH=\$IRAP_DIR/bin/bowtie1/bin:\$IRAP_DIR/bin:\$IRAP_DIR/scripts:\$PATH
export LD_LIBRARY_PATH=\$IRAP_DIR/lib:\$LD_LIBRARY_PATH:/usr/local/lib
export CFLAGS="-I\$IRAP_DIR/include -I\$IRAP_DIR/include/bam -I\$IRAP_DIR/include/boost \$CFLAGS"
export CXXFLAGS="-I\$IRAP_DIR/include -I\$IRAP_DIR/include/bam -I\$IRAP_DIR/include/boost -L\$IRAP_DIR/lib \$CXXFLAGS"
export PERL5LIB=\$IRAP_DIR/perl/lib/perl5:\$IRAP_DIR/lib/perl5:\$IRAP_DIR/lib/perl5/x86_64-linux:\$IRAP_DIR/lib/perl5/$PERL_VERSION
export PYTHONUSERBASE=\$IRAP_DIR/python
#export PYTHONPATH=\$IRAP_DIR/python:\$PYTHONPATH
#export IRAP_LSF_GROUP=/irap
EOF
}


####################################
# Mappers
function bfast_install {
    MAPPER=bfast
    pinfo "Starting $MAPPER source installation..."
    download_software $MAPPER
    tar xzvf $BFAST_FILE
    pushd bfast-$BFAST_VERSION
    ./configure --prefix=$BIN_DIR/$MAPPER
    make clean
    make
    make install
    pinfo "$MAPPER installation complete."
    popd
}

function bowtie1_install {
    MAPPER=bowtie1
    pinfo "Starting $MAPPER source installation..."
    download_software $MAPPER
    unzip $bowtie1_FILE
    pushd bowtie-$bowtie1_VERSION
    #export BITS=64
    #make clean
    #make -j 4 all
    FILES="bowtie bowtie-build bowtie-inspect"
    install_binary $MAPPER . $FILES 
    install_binary $MAPPER scripts \*
    pinfo "$MAPPER installation complete."
    popd
}

function bowtie2_install {
    MAPPER=bowtie2
    pinfo "Starting $MAPPER source installation..."
    download_software $MAPPER
    unzip $bowtie2_FILE
    pushd `echo $bowtie2_FILE|sed "s/-linux-x86_64.zip//"`
    #export BITS=64
    #make clean
    #make -j $J all
    FILES="bowtie2 bowtie2-build bowtie2-inspect bowtie2-align"
    install_binary $MAPPER . $FILES 
    install_binary $MAPPER scripts \*
    pinfo "$MAPPER installation complete."
    popd
}

function tophat1_install {
    MAPPER=tophat1
    pinfo  "Starting $MAPPER binary installation..."
    download_software $MAPPER
    tar xzvf $tophat1_FILE
    mkdir -p $BIN_DIR/tophat1
    pushd `echo $tophat1_FILE|sed "s/.tar.gz//"`
    install_binary $MAPPER . \*
    pinfo "$MAPPER installation complete."    
    popd
}

function tophat2_install {
    MAPPER=tophat2
    pinfo  "Starting $MAPPER binary installation..."
    download_software $MAPPER
    tar xzvf $tophat2_FILE
    pushd `echo $tophat2_FILE|sed "s/.tar.gz//"`
    install_binary $MAPPER . \*
    cp $IRAP_DIR/bin/tophat2/bin/gtf_juncs $IRAP_DIR/bin/tophat2_gtf_juncs
    pinfo "$MAPPER installation complete."    
    popd
}

function smalt_install {
    MAPPER=smalt
    pinfo "Starting $MAPPER binary installation..."
    download_software $MAPPER
    tar xzvf $SMALT_FILE
    pushd `echo $SMALT_FILE|sed "s/.tgz//"`
    install_binary $MAPPER .  smalt_x86_64
    pinfo "$MAPPER installation complete."    
    popd
}

function soap_splice_install {
    MAPPER=soap_splice
    SRCDIR=$2    
    pinfo "Starting $MAPPER binary installation..."
    download_software $MAPPER
    tar xzvf $SOAPsplice_FILE
    pushd `echo $SOAPsplice_FILE|sed "s/.tar.gz//"`
    install_binary $MAPPER bin  \*
    pinfo "$MAPPER installation complete."    
    popd
}

function soap2_install {
    MAPPER=soap2
    pinfo "Starting $MAPPER binary installation..."
    download_software $MAPPER
    tar xzvf $SOAP2_FILE
    pushd `echo $SOAP2_FILE|sed "s/.tar.gz//"`
    install_binary $MAPPER .  2bwt-builder  soap
    popd
    #download http://soap.genomics.org.cn/down/soap2sam.tar.gz
    tar xzvf soap2sam.tar.gz
    chmod +x soap2sam.pl
    sed "s.^#\!/usr/bin/perl.*.#\!/bin/env perl." -i soap2sam.pl
    cp soap2sam.pl $BIN_DIR
    pinfo "$MAPPER installation complete."    
}

function gem_install {
    MAPPER=GEM
    pinfo "Starting $MAPPER binary installation..."
    download_software $MAPPER
    tar xjvf $GEM_FILE
    # deps: requires ruby
    pushd `echo $GEM_FILE|sed "s/.tbz2//"`
    install_binary $MAPPER . \*
#    sed -i "s/^#!/.*ruby/#!/bin/env ruby/" $BIN_DIR/$MAPPER/bin/gem*
    pinfo "$MAPPER  installation complete."    
    popd
}


function gem2_install {
    MAPPER=GEM
    GEM_VERSION="1.6-i3"
    pinfo "Starting $MAPPER binary installation..."
    download_software $MAPPER
    # do not install gemtools - only the gem binaries
    tar xzvf $GEM_FILE
    install_binary $MAPPER . gem-* gtf* splits* compute* transcri*
    pinfo "$MAPPER  installation complete."    
    #git clone git://github.com/gemtools/gemtools
    #pushd gemtools
    #python setup.py install --user
    #python setup.py install --user
    #--prefix=$IRAP_DIR
    # http://barnaserver.com/gemtools//GEM-gemtools-1.6-i3.tar.gz to /home/nf/Research/Projects/WIP/IRAP/irap_install/tmp/gemtools/downloads/GEM-gemtools-1.6-i3.tar.gz
    # $HOME/usr/gemtools/bin/homes/nf/.local/lib/python2.6/site-packages/gem/gembinaries
    #FILES=`python -m gem.__main__ 2> /dev/stdout | cut -f 2 -d\: | grep gem`
    # TODO: copy to install folder
    #pushd $IRAP_DIR/lib64/python*/site-packages/gem/gembinaries
    #popd
    #popd
}

function star_install {
    MAPPER=star
    pinfo  "Starting $MAPPER binary installation..."
    download_software $MAPPER
    EXECF=`echo $STAR_FILE|sed "s/.gz//"`
    gunzip -c $STAR_FILE > $EXECF
    mkdir -p $BIN_DIR/star/bin
    chmod +x $EXECF
    rm -f star
    ln -s $EXECF star
    cp $EXECF star $BIN_DIR/star/bin
    pinfo "$MAPPER installation complete."    
}

function gsnap_install {
    # gmap/gsnap
    MAPPER=gsnap
    pinfo "Starting $MAPPER source installation..."
    # latest stable version
    download_software $MAPPER
    tar xzvf $GSNAP_FILE
    pushd `echo $GSNAP_FILE|sed "s/.tar.gz//"|sed "s/-gsnap//"`
    ./configure --prefix=$BIN_DIR/$MAPPER --with-samtools=$IRAP_DIR
    make clean
    make -j $J
    make install
    pinfo "$MAPPER installation complete."    
    popd
}

function bwa_install {
    MAPPER=bwa
    pinfo "Starting $MAPPER source installation..."
    download_software $MAPPER
    tar xjvf $bwa_FILE
    pushd `echo $bwa_FILE|sed "s/.tar.bz2//"`
    make clean
    make -j $J
    install_binary $MAPPER . bwa
    pinfo "$MAPPER installation complete."    
    popd
}

function osa_install {
    MAPPER=osa
    pinfo "Starting $MAPPER source installation..."
    osa_VERSION=2.0.1
    #osa_oldVERSION=1.13.3
    #install mono
    download_software MONO
    tar xzvf $MONO_FILE
    pushd mono-$MONO_VERSION
    ./configure --with-large-heap=yes --prefix=$IRAP_DIR
    make
    make install
    popd    
    download_software $MAPPER
    unzip $osa_FILE
    pushd OSAv$osa_VERSION
    install_binary $MAPPER . \*
    popd
    pinfo "$MAPPER installation complete."    
}

function irap_install_mappers {
   bwa_install
   bowtie1_install
   bowtie2_install
   tophat1_install
   tophat2_install
   bfast_install
   smalt_install
   soap_splice_install
   soap2_install
#   gem_install
   gem2_install
   gsnap_install 
   osa_install
   star_install
}

########################
function embam_install {

    pinfo "Starting emBAM source installation..."
    download_software EMBAM
    $IRAP_DIR/bin/R  CMD INSTALL $EMBAM_FILE
    pinfo "Starting emBAM source installation...done."
}

######################################################
#                   Dependencies
######################################################

######################################################
# Make
# Utility determining automatically which pieces of a large program need to be recompiled, and issues commands to recompile them
function make_install {
    pinfo "Installing make..."
    download_software MAKE
    tar xzvf $MAKE_FILE
    pushd `echo $MAKE_FILE|sed "s/.tar.gz//"`
    ./configure 
    make -j $J
    cp make $IRAP_DIR/bin
    popd
    pinfo "Installing make...done."
}
    
######################################################
# Ruby    
# Programming language (mmseq includes several scripts in ruby)
function ruby_install {
    pinfo "Installing ruby..."
    # previous 1.9.3-p125
    download_software RUBY
    tar xzvf $RUBY_FILE
    pushd ruby-${RUBY_VERSION}
    ./configure --prefix=$IRAP_DIR
    make 
    make install
    popd
    pinfo "Installing ruby...done."
}
######################################################
# Perl 
# To ensure that there are no version issues...
function perl_install {
    pinfo "Installing perl..."
    if [ -e  ~/.cpan ]; then
	cp -arb ~/.cpan ~/.cpan.bak
	rm -fr ~/.cpan
    fi
    download_software PERL
    tar -xzf $PERL_FILE
    pushd perl-$PERL_VERSION
    ./Configure -des -Dprefix=$IRAP_DIR
    make -j $J
    # skip tests...
    set +e
    make test
    set -e
    make install 
    popd
    pinfo "Installing perl...done."
}
######################################################
# BOOST
function boost_install {
    pinfo "Installing boost..."
    download_software BOOST
    tar xvjf $BOOST_FILE
    pushd `echo $BOOST_FILE|sed "s/.tar.bz2//"`
    ./bootstrap.sh --prefix=$IRAP_DIR
    ./b2
    ./b2 install
    popd
    pinfo "Installing boost...done."
}

######################################################
# gnuplot 4.4
# Utility the for visual display of scientific data
function gnuplot_install {
    pinfo "Installing gnuplot..."
    download_software gnuplot
    tar xzvf $gnuplot_FILE
    pushd `echo $gnuplot_FILE|sed "s/.tar.gz//"`
    ./configure --prefix=`pwd` --without-readline --without-lisp-files
    make
    make install
    cp bin/gnuplot $IRAP_DIR/bin
    popd
    pinfo "Installing gnuplot...done."
}

######################################################
# R
function R_install {
    pinfo "Installing R..."
    download_software R
    tar xzvf $R_FILE
    pushd R-${R_VERSION}
    ./configure --prefix=$IRAP_DIR
    make clean
    make -j $J
    make -j $J check
    make install
    popd
    pinfo "Installing R...done."
}
######################################################
# Yap 
function YAP_install {
    pinfo "Installing YAP..."
    rm -rf mainline
    git clone git://gitorious.org/yap-git/mainline.git
    pushd mainline
    ./configure --prefix=$IRAP_DIR --disable-myddas
    make
    make install
    popd
    pinfo "Installing YAP...done."
}

function install_deps {
    make_install
    perl_install
    ruby_install
    boost_install
    gnuplot_install
    R_install
    YAP_install
    # 
    samtools_install
    bedtools_install
}

######################################################
# Samtools
# Utilities for manipulating alignments in the SAM format
function samtools_install {
    pinfo "Downloading, compiling, and installing SamTools..."
    download_software SAMTOOLS
    tar xvjf $SAMTOOLS_FILE
    pushd samtools-${SAMTOOLS_VERSION}
    make -j $J
    make -j $J razip
    cp samtools razip bcftools/bcftools $BIN_DIR
    cp libbam.a $LIB_DIR
    mkdir -p $INC_DIR/bam
    cp *.h $INC_DIR/bam
    cp libbam.a $INC_DIR/bam
    popd
    pinfo "Downloading, compiling, and installing SAMTools...done."
}

######################################################
# Bedtools
function bedtools_install {
    pinfo "Installing BEDTOOLS..."
    BEDTOOLS=BEDTools.v$BEDTOOLS_VERSION
    download_software BEDTOOLS
    tar xzvf $BEDTOOLS_FILE
    pushd bedtools-$BEDTOOLS_VERSION
    make
    cp bin/* $IRAP_DIR/bin
    popd
    pinfo "Installing BEDTOOLS...done."
}

######################################################
# Perl packages
# TODO: move from cpan to cpanm
function perl_cpan_install {
    pinfo "Initializing CPAN..."
    if  [ ! -e ~/.cpan/ ]; then
	unset PERL5LIB
    else
	cp -rab ~/.cpan  ~/.orig.cpan
	rm -rf ~/.cpan
    fi
    (echo y;) | perl -MCPAN -e shell
    # if myConfig.pm existed the previous command would not change it therefore force its creation
    ( echo mkmyconfig; ) | perl -MCPAN -e shell 
    (echo o conf init urllist;echo y;echo o conf commit;) | perl -MCPAN -e shell 
#    (echo o conf init urllist;echo y;echo 3;echo 31; echo 1 2 3 4 5 6;echo o conf commit;) | perl -MCPAN -e shell 
    pinfo "Initializing CPAN...done."
    pinfo "Configuring CPAN..."
    # extra configuration
    #PREFIX=$IRAP_DIR/perl
    export INSTALL_BASE=$IRAP_DIR
    export PREFIX=$IRAP_DIR
    perl -MCPAN -e shell<<EOF
o conf makepl_arg  INSTALL_BASE=$IRAP_DIR PREFIX=$IRAP_DIR
o conf mbuildpl_arg "--install_base $IRAP_DIR/perl"
o conf prerequisites_policy follow
o conf mbuild_install_arg "--install_base $IRAP_DIR/perl"
o conf build_requires_install_policy yes
o conf commit
q
EOF
# 
    # 
    cpan App::cpanminus
    # set permissions 
    chmod +w $IRAP_DIR/bin/*
    pinfo "Configuring CPAN...done."
}
function perl_packages_install {
    mkdir -p $IRAP_DIR/perl
    #
    perl_cpan_install
    pinfo "Installing perl packages..."
    perl -MCPAN -e shell<<EOF
fforce install  Algorithm::Munkres
fforce install  Array::Compare
fforce install  Math::Random
fforce install  Sort::Naturally
fforce install List::MoreUtils
fforce install Math::Round
EOF
#fforce install Bio::SeqIO
    #    # SAMTOOLS needs to be recompiled :(
    mkdir -p $IRAP_DIR/tmp
    pushd $IRAP_DIR/tmp
    download_software SAMTOOLS
    tar xvjf $SAMTOOLS_FILE
    #svn export https://samtools.svn.sourceforge.net/svnroot/samtools/tags/samtools-0.1.7/;
    perl -i -pe 's/^CFLAGS=\s*/CFLAGS=-fPIC / unless /\b-fPIC\b/' samtools-${SAMTOOLS_VERSION}/Makefile;
    make -C samtools-${SAMTOOLS_VERSION} -j3 lib;
    export SAMTOOLS="$PWD/samtools-${SAMTOOLS_VERSION}";    
    #export SAMTOOLS=$IRAP_DIR/lib/ 
    cpan -fi CJFIELDS/BioPerl-1.6.1.tar.gz   <<EOF
n
n
n
EOF
    # be sure to have make in path
    export PATH=$IRAP_DIR/bin:$PATH
    cpan -i YAML  < /dev/null
    cpan -i JSON  < /dev/null
    cpan -i ExtUtils::MakeMaker
    cpan -f -i Hash::Merge 
    cpan -f -i Devel::Size
    #pan -i  Bio::DB::Sam < /dev/null
    cpanm  --force -l $IRAP_DIR Heap::Simple::Perl
    popd
    pinfo "Installing perl packages...done."
}

##################################
# R and R packages
# Software environment for statistical computing and graphics
#R=R-2.15.0
#download http://cran.ma.imperial.ac.uk/src/base/R-2/$R.tar.gz
#tar xzvf $R.tar.gz
function install_R_packages {
    export PATH=$IRAP_DIR/bin:$PATH
    pinfo "Installing R packages..."
    R --no-save <<EOF
repo<-"$CRAN_REPO"
install.packages("multicore",repos=repo)
install.packages("gclus",repo=repo)
install.packages('R2HTML',repo=repo)
install.packages("agricolae",repo=repo)
install.packages("optparse",repo=repo)
install.packages("brew",repo=repo)
install.packages("reshape",repo=repo)
# gplots not available - manual install
install.packages("gtools",repo=repo)
install.packages("gdata",repo=repo)
install.packages("caTools",repo=repo)
install.packages("sfsmisc",repo=repo)
download.file("http://cran.r-project.org/src/contrib/Archive/gplots/gplots_2.11.0.tar.gz","gplots_2.11.0.tar.gz")
install.packages("gplots_2.11.0.tar.gz",type="source",repos=NULL)
#install.packages("gplots",repo=repo)

source("http://bioconductor.org/biocLite.R")
biocLite("Rsamtools",ask=FALSE, suppressUpdates=FALSE)
#biocLite('cummeRbund',ask=FALSE, suppressUpdates=FALSE)
biocLite('edgeR',ask=FALSE, suppressUpdates=FALSE)
biocLite('DESeq',ask=FALSE, suppressUpdates=FALSE)
#biocLite('DESeq2',ask=FALSE, suppressUpdates=FALSE)
biocLite('DEXSeq',ask=FALSE, suppressUpdates=FALSE)
biocLite('baySeq',ask=FALSE, suppressUpdates=FALSE)
biocLite('limma',ask=FALSE, suppressUpdates=FALSE)

biocLite("org.Hs.eg.db",ask=FALSE, suppressUpdates=FALSE)
biocLite('GO.db',ask=FALSE, suppressUpdates=FALSE)
#biocLite("topGO",ask=FALSE, suppressUpdates=FALSE)
#biocLite("biomaRt",ask=FALSE, suppressUpdates=FALSE)

biocLite('goseq',ask=FALSE, suppressUpdates=FALSE)

species2db<-matrix(c('org.Ag.eg.db','Anopheles',
'org.At.tair.db','Arabidopsis',
'org.Bt.eg.db','Bovine',
'org.Ce.eg.db','Worm',
'org.Cf.eg.db','Canine',
'org.Dm.eg.db','Fly',
'org.Dr.eg.db','Zebrafish',
'org.EcK12.eg.db','E coli strain K12',
'org.Gg.eg.db','Chicken',
'org.Hs.eg.db','Human',
'org.Mm.eg.db','Mouse',
'org.Mmu.eg.db','Rhesus',
'org.Pf.plasmo.db','Malaria',
'org.Pt.eg.db','Chimp',
'org.Rn.eg.db','Rat',
'org.Sc.sgd.db','Yeast',
'org.Sco.eg.db','Streptomyces coelicolor',
'org.Ss.eg.db','Pig',
'org.Tgondii.eg.db','Toxoplasma gondii',
'org.Xl.eg.db','Xenopus'),byrow=T,ncol=2)
colnames(species2db)<-c("db","species")
for (p in species2db[,'db']) {
biocLite(p,ask=FALSE)
}

q()
EOF
    pinfo "Installing R packages...done."
}
# biocLite('DEXSeq',ask=FALSE, suppressUpdates=FALSE)
# requires libcurl installed in the system

######################################################
# Cufflinks1
function cufflinks1_install {

# Short reads - Transcript assembly, abundance and differential expression estimations
    pinfo "Downloading and installing CuffLinks..."
    download_software cufflinks1
    tar xzvf $cufflinks1_FILE
    # file name conflict with cufflinks2
    mkdir -p $BIN_DIR/cufflinks1
    cp cufflinks-${cufflinks1_VERSION}*/* $BIN_DIR/cufflinks1
    pinfo "Downloading and installing conflinks1...done."
}

######################################################
# Cufflinks2
function cufflinks2_install {
# Short reads - Transcript assembly, abundance and differential expression estimations     
    pinfo "Downloading and installing CuffLinks 2..."
    download_software cufflinks2
    tar xzvf $cufflinks2_FILE
    # file name conflict with cufflinks1
    mkdir -p $BIN_DIR/cufflinks2
    cp `echo $cufflinks2_FILE|sed "s/.tar.gz//"`/* $BIN_DIR/cufflinks2
    pinfo "Downloading and installing cufflinks2...done."
}
#######################################################
#bitseq
#Bayesian Inference of Transcripts from Sequencing Data
function bitseq_install {
    pinfo "Installing BitSeq..."
    download_software BitSeq
    tar xzvf $BitSeq_FILE
    pushd BitSeq-$BitSeq_VERSION
    make
    PROGS=`grep "^PROGRAMS =" Makefile| cut -f 2 -d=`
    mkdir -p $IRAP_DIR/bin/bitseq  
    mv $PROGS $IRAP_DIR/bin/bitseq/
    popd
    pinfo "Installing BitSeq...done."
}

######################################################
# mmseq
# Haplotype and isoform specific expression estimation using multi-mapping RNA-seq reads
function mmseq_install {
    pinfo "Installing mmseq..."
    download_software MMSEQ
    unzip $MMSEQ_FILE
    pushd mmseq_${MMSEQ_VERSION}/
    rm -f *Darwin*
    cp *.rb *-x86_64 *.sh  $IRAP_DIR/bin
    # remove version from the name of the executables
    rename -- "-${MMSEQ_VERSION}*-Linux-x86_64" "" $IRAP_DIR/bin/*-$MMSEQ_VERSION*
    popd
    pinfo "Installing mmseq...done."
}

######################################################
# HTSeq
function htseq_install {
    pinfo "Installing HTSeq..."
    download_software htseq
    tar xzvf $htseq_FILE
    pushd `echo $htseq_FILE|sed "s/.tar.gz//"`
# python version needs to be equal or greater than  (2.6)
    . ./build_it
    python setup.py install --user
    chmod +x scripts/*
    cp scripts/* $IRAP_DIR/bin
    popd
    pinfo "Installing HTSeq...done."
}

######################################################
# Flux capacitor
function flux_capacitor_install {
    pinfo "Installing Flux_capacitor..."
# stable version
# download http://sammeth.net/artifactory/barna/barna/barna.capacitor/1.2.2/flux-capacitor-$FLUX_VERSION.tgz
# devel version
    download_software FLUX_CAPACITOR
#
    tar xzvf $FLUX_CAPACITOR_FILE
    pushd `echo $FLUX_CAPACITOR_FILE|sed "s/.tgz//"`
    mv bin/* $IRAP_DIR/bin
    mv lib/* $IRAP_DIR/lib
    # note: $IRAP_DIR/lib/ must be in the LD_LIBRARY_PATH variable? maybe not...
    popd
    pinfo "Installing Flux_capacitor...done."
}

######################################################
# Scripture
function scripture_install {
#download ftp://ftp.broadinstitute.org/pub/papers/lincRNA/scripture.jar
    pinfo "Installing scripture..."
    download_software SCRIPTURE
    mv scripture-$SCRIPTURE_VERSION.jar $IRAP_DIR/bin/scripture.jar
    cat <<EOF > $IRAP_DIR/scripts/scripture
#!/bin/env bash
java -Xmx8000m -jar \$IRAP_DIR/bin/scripture.jar \$*
EOF
    chmod +x $IRAP_DIR/scripts/scripture
    
# scripture requires IGVTools
# IGV 2.1 requires Java 6 or greater. 
    download_software IGV
    unzip $IGV_FILE
    cp IGV_$IGV_VERSION/* $IRAP_DIR/bin/
    chmod +x $IRAP_DIR/bin/igv*
    rm -rf IGV_$IGV_VERSION $IGV.zip
    
    cat <<EOF > $IRAP_DIR/bin/igv.sh
#!/bin/env bash
java -Dapple.laf.useScreenMenuBar=true -Xmx750m -jar $IRAP_DIR/bin/igv.jar $*
EOF
    
    IGVTOOLS=igvtools_nogenomes_$IGV_TOOLS_VERSION
    download_software IGV_TOOLS
    unzip $IGV_TOOLS_FILE
    cp IGVTools/* $IRAP_DIR/bin/
    echo "exit 0" >> $IRAP_DIR/bin/igvtools
    pinfo "Installing scripture...done"
}

function quant_install {
    cufflinks1_install
    cufflinks2_install
    mmseq_install
    htseq_install
    flux_capacitor_install
    scripture_install
    #ireckon_install
}

######################################################
# Fastq QC
function fastq_qc_install { 
    ###############
    # Fastx toolkit
    # Collection of command line tools for Short-Reads FASTA/FASTQ files preprocessing.
    pinfo "Downloading and installing FASTX toolkit..."
    download_software FASTX
    tar xvjf $FASTX_FILE
    mv bin/* $BIN_DIR
    pinfo "Downloading and installing FASTX toolkit...done."
    
    ########
    # fastqc
    # Quality control tool for high throughput sequence data
    pinfo "Installing fastqc..."
    download_software FASTQC
    unzip $FASTQC_FILE
    rm -rf $IRAP_DIR/bin/FastQC  $IRAP_DIR/bin/fastqc
    mv FastQC $IRAP_DIR/bin
    pushd $IRAP_DIR/bin/FastQC
    chmod 755 fastqc
    sed "s.^#\!/usr/bin/perl.#\!/bin/env perl." -i fastqc
    ln -s `pwd`/fastqc $IRAP_DIR/bin
    popd
    pinfo "Installing fastqc...done."
}
######################################
function install_core {

    pinfo "*******************************************************"
    pinfo "IRAP_INSTALL_TOPLEVEL_DIRECTORY=$IRAP_DIR"
    pinfo "IRAP_SRC_TOPLEVEL_DIR=$SRC_DIR"
    pinfo "*******************************************************"

    gen_setup_irap $SETUP_FILE
    pinfo "Created setup file $SETUP_FILE"
    source $SETUP_FILE
    pinfo "Loaded $SETUP_FILE"

    #############
    #
    pinfo "Installing irap files..."
    if [ -h $IRAP_DIR/scripts ]; then
	pinfo "$IRAP_DIR/scripts is a symbolic link...skipping update."
    else
	if [ ! -e $IRAP_DIR/scripts ]; then
	    mkdir -p $IRAP_DIR/scripts
	fi
	cp -r $SRC_DIR/scripts/* $IRAP_DIR/scripts
	# install should always be ran from the source 
	rm -f $IRAP_DIR/scripts/irap_install.sh
    fi

    if [ -h $IRAP_DIR/aux ]; then
	pinfo "$IRAP_DIR/aux is a symbolic link...skipping update."
    else
	cp -r $SRC_DIR/aux $IRAP_DIR
    fi
    pinfo "Installing irap files...done."

    pinfo "Installing EMBAM..."
    embam_install    
    pinfo "installing EMBAM...done."

    pinfo "Collecting software versions..."
    irap_gen_version_mk.sh
    pinfo "Collecting software versions...done."

    #############
    # fastq utils
    # Fastq processing utilities
    pinfo "Compiling and installing fastq/bam processing programs..."
    pushd $SRC_DIR/src/fastq_utils
    make -j $J -B
    TARGETS=`grep "^TARGETS=" Makefile| cut -f 2 -d=`
    cp $TARGETS $BIN_DIR
    popd
    pushd $SRC_DIR/src/bamutils
    make -B
    cp bam_pe_insert bam_fix_NH bam_fix_se_flag  $BIN_DIR
    popd
    pinfo "Compiling and installing fastq/bam processing programs...done."

    pinfo "Core installation complete."
}
###############################################
# may be useful...but requires a web server
function jbrowse_install {
    pinfo "Installing jbrowse..."
    download_software JBROWSE
    mv $JBROWSE_FILE $IRAP_DIR/aux/jbrowse.zip
    unzip $IRAP_DIR/aux/jbrowse.zip
    # TODO: install deps
    pinfo "Uncompressing and installing jbrowse..."
    pushd JBrowse-*
    sed -i "s|-l extlib/| -l $IRAP_DIR|" setup.sh
    sed -i "s|bin/cpanm|cpanm|" setup.sh

    pinfo "Uncompressing and installing jbrowse...extra PERL packages"
    perl_packages_install
    cpan -i ExtUtils::MakeMaker
    cpan -i Module::CoreList
    cpan -i GD
    #
    download_software SAMTOOLS
    tar xvjf $SAMTOOLS_FILE
    export SAMTOOLS="$PWD/samtools-${SAMTOOLS_VERSION}";    
    #svn export https://samtools.svn.sourceforge.net/svnroot/samtools/tags/samtools-0.1.7/;
    perl -i -pe 's/^CFLAGS=\s*/CFLAGS=-fPIC / unless /\b-fPIC\b/' samtools-${SAMTOOLS_VERSION}/Makefile;
    make -C samtools-${SAMTOOLS_VERSION} -j3 lib;
    ln -s samtools-${SAMTOOLS_VERSION} samtools
    # It is necessary to clean .cpan 
    # yes, weird!
    rm -rf $IRAP_DIR/.cpan.bak2
    mv ~/.cpan $IRAP_DIR/.cpan.bak2
    #unset INSTALL_BASE
    cpanm -f -l $IRAP_DIR local::lib < /dev/null    
    set +e
    # cpanm -v --notest -l $IRAP_DIR --installdeps . < /dev/null;
    cpanm -f -v -l $IRAP_DIR --installdeps . < /dev/null;
    set -e
    rm -rf ~/.cpan
    mv $IRAP_DIR/.cpan.bak2 ~/.cpan 
    # cpanm -v --notest -l $IRAP_DIR --installdeps . < /dev/null;
    pinfo "Uncompressing and installing jbrowse...extra PERL packages (done)"
    pinfo "Uncompressing and installing jbrowse...compiling wig2png"
    pushd src/wig2png
    ./configure
    make    
    popd
    pinfo "Uncompressing and installing jbrowse...compiling wig2png (done)"
    ./setup.sh < /dev/null
    make 
    pinfo "Uncompressing and installing jbrowse...copying binaries and libs "
    cp -rf src $IRAP_DIR    
    #cp -rf extlib $IRAP_DIR
    # fix permissions
    chmod 755 bin/*
    cp bin/* $IRAP_DIR/bin 
    echo `pwd`   
    chmod 755 blib/script/*
    cp blib/script/* $IRAP_DIR/bin    
    #cp -rf blib $IRAP_DIR
    pinfo "Uncompressing and installing jbrowse...copying binaries and libs (done)"
    pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs"
    # get some required utilities
    for f in $JBROWSE_EXTRA_UTILS; do
	pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs ($f)"
	download $JBROWSE_EXTRA_UTILS_URL/$f
	chmod +x $f
	cp $f $IRAP_DIR/bin
	pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs (done)"
    done
    pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs (done)"    
    popd
    pinfo "jbrowse installation complete."
}
function new_jbrowse_install {
    pinfo "Installing new jbrowse..."
    download_software NEW_JBROWSE
    mv $NEW_JBROWSE_FILE $IRAP_DIR/aux/jbrowse.zip
    unzip $IRAP_DIR/aux/jbrowse.zip
    # TODO: install deps
    pinfo "Uncompressing and installing jbrowse..."
    pushd JBrowse-*
    sed -i "s|-l extlib/| -l $IRAP_DIR|" setup.sh
    sed -i "s|bin/cpanm|cpanm|" setup.sh

    pinfo "Uncompressing and installing jbrowse...extra PERL packages"
    perl_packages_install
    cpan -i ExtUtils::MakeMaker
    cpan -i Module::CoreList
    cpan -i GD
    #
    download_software SAMTOOLS
    tar xvjf $SAMTOOLS_FILE
    export SAMTOOLS="$PWD/samtools-${SAMTOOLS_VERSION}";    
    #svn export https://samtools.svn.sourceforge.net/svnroot/samtools/tags/samtools-0.1.7/;
    perl -i -pe 's/^CFLAGS=\s*/CFLAGS=-fPIC / unless /\b-fPIC\b/' samtools-${SAMTOOLS_VERSION}/Makefile;
    make -C samtools-${SAMTOOLS_VERSION} -j3 lib;
    ln -s samtools-${SAMTOOLS_VERSION} samtools
    # It is necessary to clean .cpan 
    # yes, weird!
    rm -rf $IRAP_DIR/.cpan.bak2
    mv ~/.cpan $IRAP_DIR/.cpan.bak2
    #unset INSTALL_BASE
    cpanm -f -l $IRAP_DIR local::lib < /dev/null    
    set +e
    # cpanm -v --notest -l $IRAP_DIR --installdeps . < /dev/null;
    cpanm -f -v -l $IRAP_DIR --installdeps . < /dev/null;
    set -e
    rm -rf ~/.cpan
    mv $IRAP_DIR/.cpan.bak2 ~/.cpan 
    # cpanm -v --notest -l $IRAP_DIR --installdeps . < /dev/null;
    pinfo "Uncompressing and installing jbrowse...extra PERL packages (done)"
    pinfo "Uncompressing and installing jbrowse...compiling wig2png"
    pushd src/wig2png
    ./configure
    make    
    popd
    pinfo "Uncompressing and installing jbrowse...compiling wig2png (done)"
    ./setup.sh < /dev/null
    make 
    pinfo "Uncompressing and installing jbrowse...copying binaries and libs "
    cp -rf src $IRAP_DIR    
    #cp -rf extlib $IRAP_DIR
    # fix permissions
    chmod 755 bin/*
    cp bin/* $IRAP_DIR/bin 
    echo `pwd`   
    chmod 755 blib/script/*
    cp blib/script/* $IRAP_DIR/bin    
    #cp -rf blib $IRAP_DIR
    pinfo "Uncompressing and installing jbrowse...copying binaries and libs (done)"
    pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs"
    # get some required utilities
    for f in $NEW_JBROWSE_EXTRA_UTILS; do
	pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs ($f)"
	download $NEW_JBROWSE_EXTRA_UTILS_URL/$f
	chmod +x $f
	cp $f $IRAP_DIR/bin
	pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs (done)"
    done
    pinfo "Uncompressing and installing jbrowse... downloading and installing extra programs (done)"    
    popd
    pinfo "jbrowse installation complete."
}
#############################################
# WIP
function ireckon_install {
    pinfo "Installing Ireckon...deprecated"
    exit
    download_software IReckon
    mkdir -p $IRAP_DIR/bin/ireckon
    cat <<EOF > $IRAP_DIR/bin/ireckon/ireckon
#!/bin/bash
if [ "$MEM-" = "-" ] ; then
MEM=15000M
fi
#Requirements:
# - iReckon works on linux. You need to have at least java-1.6 and the latest version of BWA installed and added to the PATH.
# - For large datasets and genomes, anticipate an important memory cost and running time (It is usually around 16G and 24 hours on 8 processors for human RNA-Seq with 60M read pairs).
#   The working directory (output directory) should have enough memory space (>100Go for the previous example). 
java -Xmx${MEM}M  -jar $IRAP_DIR/bin/IReckon-1.0.6.jar $* 
EOF
    chmod +x $IRAP_DIR/bin/ireckon
    mv IReckon-$IReckon_VERSION.jar $IRAP_DIR/bin/ireckon
    rm -f $IRAP_DIR/bin/ireckon/bwa
    ln -s  $IRAP_DIR/bin/bwa/bin/bwa  $IRAP_DIR/bin/ireckon/ 
    # deps
    download_software SAVANT
    chmod +x $SAVANT_FILE
    cat <<EOF > savant_responses
CreateDesktopShortcut: No
CreateQuickLaunchShortcut: Yes
InstallDir: $IRAP_DIR
InstallMode: Standard
InstallType: Typical
LaunchApplication: No
ProgramFolderName: Savant
SelectedComponents: Default Component
ViewReadme: No
EOF
    ./SAVANT_FILE -prefix $IRAP_DIR/bin --response-file savant_responses -mode silent
    #
    download http://genomesavant.com/savant/dist/v2_0_2/FormatTool.sh
    chmod +x FormatTool.sh
    mv FormatTool.sh $IRAP_DIR/bin/
    # requires BWA
    pinfo "Installing Ireckon...done."
}
######################################
#function soap_fusion_install {
#     MAPPER=soap_fusion
#      soap_fusion_VERSION=1.1
#      download ftp://public.genomics.org.cn/BGI/soap/Soapfusion/SOAPfusion_all_in_one_package.zip
#     unzip SOAPfusion_all_in_one_package.zip
#     pinfo "$MAPPER installation complete."    
#}
function NURD_install {
    download_software NURD
    tar xzvf $NURD_FILE
    pushd release_v$NURD_VERSION
    make
    cp NURD $IRAP_DIR/bin
    popd
}
function miso_install {
    # deps problems
    download http://sourceforge.net/projects/numpy/files/latest/download
    tar xzvf download
    pushd numpy-1.6.2
    python setup.py build
    python setup.py install --user
    popd
    
    download http://sourceforge.net/projects/scipy/files/scipy/0.11.0/scipy-0.11.0.tar.gz
    tar xzvf scipy-0.11.0.tar.gz
    pushd scipy-0.11.0
    python setup.py build
    python setup.py install   --user
    popd

    download https://github.com/downloads/matplotlib/matplotlib/matplotlib-1.2.0.tar.gz
    tar xzvf matplotlib-1.2.0.tar.gz
    pushd matplotlib
    python setup.py build
    python setup.py install   --user
    popd

    download https://nodeload.github.com/yarden/MISO/legacy.zip/fastmiso
    unzip fastmiso  
    pushd yarden-MISO-*
    python setup.py build
    python setup.py install   --user
}

###############################
OPTERR=0
while getopts "s:c:a:x:gmqpruhbd"  Option
do
    case $Option in
# update/reinstall
        a ) install=all;IRAP_DIR1=$OPTARG;;# send all output to a log file
	b ) install=browser;IRAP_DIR1=$IRAP_DIR;;
	c ) install=core;IRAP_DIR1=$OPTARG;;  # run irap up to the given stage
	d ) USE_CACHE=n;install=download;IRAP_DIR1=$IRAP_DIR;; # download all the source packages
	m ) install=mappers;IRAP_DIR1=$IRAP_DIR;;
	p ) install=p_pack;IRAP_DIR1=$IRAP_DIR;;
	q ) install=quant;IRAP_DIR1=$IRAP_DIR;;
	r ) install=r_pack;IRAP_DIR1=$IRAP_DIR;;
        s ) SRC_DIR=$OPTARG;;# send all output to a log file
	u ) install=core;IRAP_DIR1=$IRAP_DIR;; # update
	x ) install=software_install;IRAP_DIR1=$IRAP_DIR;SOFTWARE=$OPTARG;;
        h ) usage; exit;;
    esac
done


if [ "$IRAP_DIR1-" != "-" ]; then
    export IRAP_DIR=$IRAP_DIR1
fi

if [ "$IRAP_DIR-" = "-" ]; then
    usage
    exit 1    
fi

if [ "$SRC_DIR-" = "-" ]; then
    usage
    exit 1    
fi

if [ "`uname 2>/dev/null`-" = "Linux-" ]; then
    OS=linux
else
    # dual world :)
    OS=mac
    pinfo " WARNING: This script will install binaries for Linux."
fi


# Full path
pinfo "Checking paths..."
IRAP_DIR=$(readlink -f "$IRAP_DIR")
SRC_DIR=$(readlink -f "$SRC_DIR")
pinfo "IRAP_DIR=$IRAP_DIR"
pinfo "SRC_DIR=$SRC_DIR"
pinfo "Checking paths...done."
#
BIN_DIR=$IRAP_DIR/bin
TMP_DIR=$IRAP_DIR/tmp
LIB_DIR=$IRAP_DIR/lib
INC_DIR=$IRAP_DIR/include

SETUP_FILE=$IRAP_DIR/irap_setup.sh

if [ "$CRAN_REPO-" == "-" ]; then
    #CRAN_REPO=http://cran.ma.imperial.ac.uk/
    CRAN_REPO=http://www.stats.bris.ac.uk/R/
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_DIR
J=8
set -e

#################
# Setup directories
mkdir -p $TMP_DIR
mkdir -p $BIN_DIR
mkdir -p $LIB_DIR
mkdir -p $INC_DIR
mkdir -p $IRAP_DIR/scripts
# Python
export PYTHONUSERBASE=$IRAP_DIR/python
mkdir -p $PYTHONUSERBASE
mkdir -p $PYTHONUSERBASE/lib/python2.7/site-packages $PYTHONUSERBASE/lib/python2.6/site-packages
######################################
cd $TMP_DIR
# clean up before proceeding
pinfo "Cleaning up $TMP_DIR..."
rm -rf *
pinfo "Cleaning up $TMP_DIR...done."

# Keep a log file
mkdir -p $IRAP_DIR/install_logs
logfile=$IRAP_DIR/install_logs/`date "+%d%m%y%H%M"`.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

# ensure that all files can be modified
pinfo "Fixing permissions..."
chmod -R +w $IRAP_DIR
pinfo "Fixing permissions...done."


#if [  "$install" == "all"   &&  ! -e $IRAP_DIR  ]; then
#    echo "Directory $IRAP_DIR already exists. Please delete it before proceeding with the installation"
#    exit 1
#fi
if [ "$install" == "download" ]; then
    download2cache
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "software_install" ]; then
    # TODO check if software exists
    ${SOFTWARE}_install
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "core" ]; then
    # TODO: check if IRAP is installed (otherwise it will fail)
    install_core
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "mappers" ]; then
    irap_install_mappers
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "r_pack" ]; then
    install_R_packages    
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "p_pack" ]; then
    perl_packages_install
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "quant" ]; then
    quant_install
    pinfo "Log saved to $logfile"
    exit 0
fi

if [ "$install" == "browser" ]; then
    jbrowse_install
    pinfo "Log saved to $logfile"
    exit 0
fi

#############
# all
install_deps
install_R_packages
install_core
pinfo "Loading environment $SETUP_FILE..."
source $SETUP_FILE
pinfo "PATH=$PATH"
pinfo "IRAP_DIR=$IRAP_DIR"
env |  grep IRAP_DIR
pinfo "Loading environment $SETUP_FILE...done."
irap_install_mappers
quant_install
fastq_qc_install
perl_packages_install
# report
jbrowse_install

pinfo "Installation complete."
pinfo "Log saved to $logfile"
exit 0
