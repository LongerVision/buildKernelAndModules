#!/bin/bash
# Get the kernel source for NVIDIA Jetson Nano Developer Kit, L4T
# Copyright (c) 2016-19 Jetsonhacks 
# MIT License

JETSON_MODEL="jetson-nano"
L4T_TARGET="32.1.0"
SOURCE_TARGET="/usr/src"
KERNEL_RELEASE="4.9"

# < is more efficient than cat command
# NULL byte at end of board description gets bash upset; strip it out
JETSON_BOARD=$(tr -d '\0' </proc/device-tree/model)

JETSON_L4T=""
if [ -f /etc/nv_tegra_release ]; then
    # L4T string
    JETSON_L4T_STRING=$(head -n 1 /etc/nv_tegra_release)

    # Load release and revision
    JETSON_L4T_RELEASE=$(echo $JETSON_L4T_STRING | cut -f 1 -d ',' | sed 's/\# R//g' | cut -d ' ' -f1)
    JETSON_L4T_REVISION=$(echo $JETSON_L4T_STRING | cut -f 2 -d ',' | sed 's/\ REVISION: //g' )
    # unset variable
    unset JETSON_L4T_STRING
    
    # Write Jetson description
    JETSON_L4T="$JETSON_L4T_RELEASE.$JETSON_L4T_REVISION"
fi
echo "Jetson Model: "$JETSON_BOARD
echo "Jetson L4T: "$JETSON_L4T

function usage
{
    echo "usage: ./buildPatchedKernel.sh [[-d directory ] | [-h]]"
    echo "-h | --help  This message"
}

# Iterate through command line inputs
while [ "$1" != "" ]; do
    case $1 in
        -d | --directory )      shift
				SOURCE_TARGET=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
# e.g. echo "${red}The red tail hawk ${green}loves the green grass${reset}"

LAST="${SOURCE_TARGET: -1}"
if [ $LAST != '/' ] ; then
   SOURCE_TARGET="$SOURCE_TARGET""/"
fi

INSTALL_DIR=$PWD

# Error out if something goes wrong
set -e

# Check to make sure we're installing the correct kernel sources
# Determine the correct kernel version
# The KERNEL_BUILD_VERSION is the release tag for the JetsonHacks buildKernel repository
KERNEL_BUILD_VERSION=master
if [ "$JETSON_BOARD" == "$JETSON_MODEL" ] ; then 
  if [ $JETSON_L4T == "$L4T_TARGET" ] ; then
     KERNEL_BUILD_VERSION=$L4T_TARGET
  else
   echo ""
   tput setaf 1
   echo "==== L4T Kernel Version Mismatch! ============="
   tput sgr0
   echo ""
   echo "This repository is for modifying the kernel for a L4T "$L4T_TARGET "system." 
   echo "You are attempting to modify a L4T "$JETSON_MODEL "system with L4T "$JETSON_L4T
   echo "The L4T releases must match!"
   echo ""
   echo "There may be versions in the tag/release sections that meet your needs"
   echo ""
   exit 1
  fi
else 
   tput setaf 1
   echo "==== Jetson Board Mismatch! ============="
   tput sgr0
    echo "Currently this script works for the $JETSON_MODEL."
   echo "This processor appears to be a $JETSON_BOARD, which does not have a corresponding script"
   echo ""
   echo "Exiting"
   exit 1
fi

# Check to see if source tree is already installed
PROPOSED_SRC_PATH="$SOURCE_TARGET""kernel/kernel-"$KERNEL_RELEASE
echo "Proposed source path: ""$PROPOSED_SRC_PATH"
if [ -d "$PROPOSED_SRC_PATH" ]; then
  tput setaf 1
  echo "==== Kernel source appears to already be installed! =============== "
  tput sgr0
  echo "The kernel source appears to already be installed at: "
  echo "   ""$PROPOSED_SRC_PATH"
  echo "If you want to reinstall the source files, first remove the directories: "
  echo "  ""$SOURCE_TARGET""kernel"
  echo "  ""$SOURCE_TARGET""hardware"
  echo "then rerun this script"
  exit 1
fi

export SOURCE_TARGET
# -E preserves environment variables
sudo -E ./scripts/getKernelSources.sh

exit 0






source scripts/jetson_variables.sh
#Print Jetson version
echo "$JETSON_DESCRIPTION"
#Print Jetpack version
echo "Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"

# Check to make sure we're installing the correct kernel sources
L4TTarget="28.2.1"
if [ $JETSON_L4T == $L4TTarget ] ; then
   echo "Getting kernel sources"
   sudo ./scripts/getKernelSourcesNoGUI.sh
else
   echo ""
   tput setaf 1
   echo "==== L4T Kernel Version Mismatch! ============="
   tput sgr0
   echo ""
   echo "This repository branch is for installing the kernel sources for L4T "$L4TTarget 
   echo "You are attempting to use these kernel sources on a L4T "$JETSON_L4T "system."
   echo "The kernel sources do not match their L4T release.!"
   echo ""
   echo "Please git checkout the appropriate kernel sources for your release"
   echo " "
   echo "You can list the tagged versions."
   echo "$ git tag -l"
   echo "And then checkout the latest version: "
   echo "For example"
   echo "$ git checkout v1.0-L4T"$JETSON_L4T
   echo ""
fi

