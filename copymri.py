#
# Script: copymri.py
#
# Description: This script finds the DICOMs from our MRI scans, copies them locally, and does surface reconstruction on the cluster
# HOW IT DOES IT: calls already-existing scripts 
#Sheraz Khan: sheraz@nmr.mgh.harvard.edu
# Martinos Center
# Boston
#
# Rev 1, Manfred Kitzbichler: conversion to Bash, general cleanup, extended multi-session functionality, argument processing, cluster-processing
# Rev 2, Keri Garel: conversion to Python
#
# Keri Garel: kgarel@mgh.harvard.edu
# TRANSCEND Research Group
# Athinoula A. Martinos Center, Massachusetts General Hospital
# Boston, MA

# We're calling a bunch of shell scripts in Python. I'm going to use sh (a python subprocess interface/replacement) to do so, as it abstracts away some of the stuff we don't care about so much:
##pip install sh

# Set location of scripts being called here
##script_dir = 
##
##print 'SCRIPT_DIR: ' + script_dir
##print 'SCRIPT EXECUTED: ' + #see copymri.sh: what's this doing?
##print 'SCRIPT EXECUTED BY: ' +

### required and optional parameters (subject ID, etc.) for us to grab the DICOMs
trpsubj = str(raw_input('Enter TRP subject ID (if none, type "none"): '))
pingsubj = str(raw_input('Enter PING subject ID (if none, type "none"): '))
if trpsubj.lower() == 'none' and pingsubj.lower() == 'none': #edit to account for leaving them blank
    print "You need either a TRP or a PING subject number. Please try again."
    trpsubj = str(raw_input('Enter TRP subject ID (if none, type "none"): '))
    pingsubj = str(raw_input('Enter PING subject ID (if none, type "none"): '))
subject_type = str(raw_input('TD or ASD? '))
visit = int(raw_input('Enter MRI visit number (1, 2...): '))
run = int(raw_input('Enter run number: '))
altsubj = str(raw_input('Enter alternate subject ID (if none, type "none"): ')) #for subject numbers mistyped during scans
executor_email = str(raw_input('Enter your email address: ')) #to send message upon completion of script

#may want to change this to single subject input, with type determination from there (see notes)
if altsubj.lower != 'none':
    dcmsubj = altsubj
elif pingsubj.lower() != 'none':
    dcmsubj = pingsubj
else:
    dcmsubj = trpsubj
print dcmsubj #currently printing none, figure out why
##if subject_type.lower() != 'td' and subject_type.lower() != 'asd':
##    print "Please only enter 'TD' or 'ASD' for subject type."
##    subject_type = str(raw_input('TD or ASD? '))
##
          
#set up command-line parser (WIP: will include all arguments from above)
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--trpsubj", help="TRP subject number")
args = parser.parse_args()
if args.trpsubj:
    print("TRP subject number exists")
          
##def copymri(subject, visit, run, othervars): #might change the input to something other than subject; we'll see how this turns out
    ##from sh import Command
    ##run = Command ("copymri.sh")
    ##run()
    
    
    
##copymri (dcmsubj, visit, run, othervars)
