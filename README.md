transcend-copymri
=================

This script finds the DICOMs from TRANSCEND's MRI scans, copies them locally, and does surface reconstruction on the cluster

What we're doing
=================
copymri is currently a shell script; one we're converting to Python. It's a relatively simple parser that calls upon other bash scripts, so as we're converting it, we'll need to continue calling upon those scripts before we have the opportunity to convert them as well.

Things you'll need
==================
* sh (https://github.com/amoffat/sh)
