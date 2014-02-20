#!/bin/bash


#####################################################################################


# Script :copymri.sh
# Description:This script finds the DICOMs, copies them locally, and does surface reconstruction on the cluster
# Sheraz Khan : sheraz@nmr.mgh.harvard.edu
# Martinos Center
# Boston
#
# Rev 1, Manfred Kitzbichler: conversion to Bash, general cleanup, extended multi-session functionality, argument processing, cluster-processing


       
#####################################################################################


script_dir="/space/calvin/1/marvin/1/users/MRI/scripts"


echo " SCRIPT DIR :" $script_dir
echo " SCRIPT EXECUTED :" $0
echo " SCRIPT EXECUTED BY :" $(whoami)
echo " DATE EXECUTED :" $(date)
echo ""


visit=1


while getopts s:p:t:v:r:e:a: oarg ; do 
    case "$oarg" in
s) trpsubj="$OPTARG";;
p) pingsubj="$OPTARG";;
t) type="$OPTARG";;
v) visit="$OPTARG";;
r) run="$OPTARG";;
e) email="$OPTARG";;
a) altsubj="$OPTARG";;
[?]) echo -e "$0: For a usage description, run without arguments." >&2
exit 1;;
    esac
done


#if [ -z "$dcmsubj" -o -z "$type" -o -z "$visit" -o -z "$run" -o -z "$email" ]; then
if [ -z "$trpsubj" -o -z "$type" ]; then
    echo "[1mUsage:[0m $0 -s <transcend_id> [-p <ping_id>] -t <type> [-v <visit>] [-r <run(s)>] [-e <email>] [-a <scanner_subjectid>]"
    echo -e "\t<transcend_id> and <type> (td or asd) are obligatory arguments"
    echo -e "\t<ping_id> is optional (creates link in folder for ping subjects)"
    echo -e "\t<visit> defaults to 1, but may be 2 if rescan"
    echo -e "\t<run(s)> can be multiple comma separated numbers, defaults to 0 (all)"
    echo -e "\t<email> will be notified about errors, defaults to $USER"
    echo -e "\t<scanner_subjectid> change subject ID for findsession (optional)"
    echo -e "\t(useful if somebody messed up the subject ID fields during scanning)"
    exit 1
fi


shift $((OPTIND-1))




#save command line args in variables
if [ -n "$altsubj" ]
    then dcmsubj=$altsubj
elif [ -n "$pingsubj" ]; then
    dcmsubj=$pingsubj
else dcmsubj=$trpsubj
fi


if [ $visit -gt 1 ]
    then trpsubj=${trpsubj}_rescan
    pingsubj=${pingsubj}_rescan
    echo -e "# Note that the subject name was changed to ${trpsubj} because of visit > 1.\n"
fi


echo -e " SUBJECT: ${trpsubj}, TYPE: ${type}, VISIT: ${visit}, RUN: ${run:=0}, EMAIL: ${email:=$USER}\n"
if [ -n "$pingsubj" ]; then echo -e "# This is also a PING subject: $pingsubj \n"; fi


dcmdate=$(findsession ${dcmsubj} | sed -n -e 's/DATE   :  //gp' | uniq | sed -n -e "${visit}p")
dcmdate=$(date --date="${dcmdate}" +%Y-%m-%d)  # convert to YYYY-MM-DD
dcmdirs=($(findsession ${dcmsubj} -o ${dcmdate} | sed -n -e 's/PATH   :  //gp'))   # NB: an array


if [ ${#dcmdirs[@]} -eq 0 ]; then 
    echo -e "$0: No subject $dcmsubj found by findsession. Exiting." >&2
    exit 2
fi


mri_dir=/space/calvin/1/marvin/1/users/MRI/WMA
ping_mri_dir=/space/calvin/1/marvin/1/users/MRI/ping


if mkdir ${mri_dir}/DICOM/${trpsubj}; then 
    echo -n " Copying DICOMs (${#dcmdirs[@]} sessions) to ${mri_dir}/DICOM/${trpsubj} ... "
    for dcm_dir in ${dcmdirs[@]}; do
echo " DICOM path from findsession :" $dcm_dir
cp -rp ${dcm_dir}/* ${mri_dir}/DICOM/${trpsubj}/
    done
    echo "done"
else
    echo "Folder ${mri_dir}/DICOM/${trpsubj} exists already, skipping ..."
fi


if [ -n "$pingsubj" ]; then
    echo -e " Creating PING folder $pingsubj linked to ${mri_dir}/DICOM/${trpsubj}"
    echo -e " [1mPING path[0m: ${ping_mri_dir}/DICOM/${pingsubj}"
    ln -s -T "${mri_dir}/DICOM/${trpsubj}" "${ping_mri_dir}/DICOM/${pingsubj}"
fi


export SUBJECTS_DIR=${mri_dir}/recons/


echo -n " Running unpack ... "
${script_dir}/do_subj_unpack.csh ${trpsubj} ${type} ${mri_dir} >& ${mri_dir}/unpack/log/${trpsubj}_unpack.log
 echo "done"


COMMAND="${script_dir}/do_wma_fsrecon.csh ${trpsubj} ${type} ${mri_dir} ${run}"
echo -e " Sending this command to the cluster:\n\t" \"$COMMAND\"


ssh -i ${script_dir}/id_rsa_pbs_sheraz sheraz@launchpad pbsubmit -p -o "-j\ oe" -m ${email} -l nodes=1:ppn=3 -c \"$COMMAND\"


#ssh -i id_rsa_pbs_sheraz sheraz@launchpad pbsubmit -p -o "-j\ oe" -m ${email} -q GPU -l nodes=1:GPU:ppn=3 -c \"$COMMAND\"
#ssh -i id_rsa_pbs_santosh santosh@launchpad pbsubmit -p -o "-j\ oe" -m ${email} -l nodes=1:ppn=3 -c \"$COMMAND\"

