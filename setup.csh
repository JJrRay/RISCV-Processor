#!/usr/bin/env tcsh
#-----------------------------------------------------------------------------
# Project    : Tutoriels - Conception de circuits intégrés analogiques
#-----------------------------------------------------------------------------
# File       : setup.csh
# Authors    : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
#            : Erika Miller-Jolicoeur <erika.miller-jolicoeur@polymtl.ca>
# Lab        : GRM - Polytechnique Montréal
# Date       : <2019-09-09 Mon>
# Date       : <2024-03-27> modification par Rejean Lepage
#-----------------------------------------------------------------------------
# Description: Script de configuration de l'environnement
#              + Environnement CMC
#              + kit GPDK045
#              + Outils Cadence pour l'électronique analogique
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# CONFIGURATION
#-----------------------------------------------------------------------------

setenv CMC_CONFIG   "/CMC/scripts/cmc.2023.1.csh"
setenv PROJECT_HOME `pwd`

# setup.csh doit être lancé depuis la racine du projet
if ( ! -f ${PROJECT_HOME}/setup.csh ) then
    echo "ERROR: setup.csh doit être lancé depuis la racine du projet"
    exit 1
endif

# Vérification de l'environnment CMC
if ( ! -f ${CMC_CONFIG} ) then
    echo "ERROR: L'environnement n'est pas configuré pour les outils de CMC"
    exit 1
endif

source ${CMC_CONFIG}

#-----------------------------------------------------------------------------
# OUTILS & KIT GPDK045
#-----------------------------------------------------------------------------

# Kit
setenv KIT_HOME ${CMC_HOME}/kits/GPDK45

# CADENCE
source ${CMC_HOME}/scripts/cadence.2014.12.csh

if (! -e /export/tmp/$user) then
     mkdir -p /export/tmp/$user
endif

setenv DRCTEMPDIR           /export/tmp/$user
setenv CDS_LOAD_ENV         addCWD   # .cdsenv
setenv CDS_AUTO_64BIT       ALL
setenv CDS_USE_PALETTE      true
setenv CDS_Netlisting_Mode  Analog
setenv DD_DONT_DO_OS_LOCKS  set
setenv DD_USE_LIBDEFS       no

# VIRTUOSO
# source ${CMC_HOME}/scripts/cadence.ic06.18.020.csh
source /CMC/scripts/cadence.ic06.18.320.csh
alias virtuoso "virtuoso -log virtuoso.log"

# MMSIM (spectre)
# source ${CMC_HOME}/scripts/cadence.mmsim15.10.518.csh
source  /CMC/scripts/cadence.spectre21.10.716.csh

# PVS
source ${CMC_HOME}/scripts/cadence.pvs16.15.000.csh

# QUANTUS QRC
source ${CMC_HOME}/scripts/cadence.ext19.10.000.csh
