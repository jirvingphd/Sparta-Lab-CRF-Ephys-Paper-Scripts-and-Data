Sparta-Lab-CRF-Ephys-Paper-Scripts-and-Data
===========================================
<img src="Documentation\Sparta Lab Logo for RSA 2016.png" width=400>

The collection of Matlab and NeuroExplorer scripts and templates used for our
analysis, plus figure files.

Updated Original Email Re: Contents
-----------------------------------

See below for important file locations and my contributions for the rebuttal
that are complete as of today 02/06/19.

1.  LOCATION FOR REBUTTAL / RESUBMISSION FILES: I've been saving my files in a
    folder called [REBUTTAL][This RepoCRF NPP EPHYS PAPER]

2.  MY CONTRIBUTIONS FOR THE REBUTTAL READY TO BE USED: (as of 02/06/19)

    -   I have a doc "Answers for Reviewer 1.docx" which discusses the questions
        from reviewer 1 about figure 2B.

    -   I have a .AI with new version of figure 2A with ethanol intake (g/kg)
        instead of licks.

    -   I have a References to Add.docx that has 3 references asked for by the
        reviewers (for phototagging and DID)

    -   I have a .docx called CRF Manuscript Submitted \_to
        update_JMI_02-06-19.docx which contains updated text, highlighted in
        blue.

    -   Additional phototagging details, plus reference.

    -   Location for DID references to be added to.

3.  LOCATION OF RAW PLEXON & NEUROEXPLORER DATA FILES FROM THE ORIGINAL EPHYS
    RECORDINGS:

    -   In Dropbox (Sparta Lab) Electrophysiology Data BackupCRF FINAL DATA SETS

    -   Note: I no long have access to these files on Dropbox so I cannot update
        them or maintain them or re-create any links to the foder.

4.  LOCATION OF ARCHIVE OF MY MATLAB & NEUROEXPLORER SCRIPTS

    -   [This Repo\\ Matlab & Neuroexplorer Scripts]

    -   Documentation:

        -   Original Workflow Docs are in the Documentation Folder

        -   Excel Spreadsheet containing the original and new simplified script
            names;

5.  INSTALLATION - To Use the Matlab Workflow You Must: 
    1. In Matlab,  click ```Set Path``` from Menu Bar \> ```Add With Subfolders:``` 
         - Select: [This Repo\Matlab & Neuroexplorer
    Scripts\ Matlab Scripts] <br>
    <br>
    2. In NeuroExplorer, click VIew \> Options -\>
    Scripts Tab and Template Tab:
        -  On Scripts Tab: 
        select folder - [This Repo&
    Neuroexplorer ScriptsNex Files] 
        - On Templates Tab: select fodler - [This
    Repo& Neuroexplorer ScriptsNex Files]

6.  PRE-MATLAB WORKFLOW INSTRUCTIONS.
    1.  Make sure all nex files have a DIDSessionInts interval.
        - Pick an interval without phototagging. 
        - Generally if PT done post-session and no problems:
            - DIDSessionInts=0 14400
    2.  Edit the filenames so they include 'ethanol','sucrose', or 'water'.
        - If ethanol, add day## as well. 
    3. Put all nex files in the same folder and launch Matlab. 
7.  MATLAB WORKFLOW:

| Run By User 	| Order 	|          Simplified Script Name          	|                                             Description                                            	| Changed 	|
|:-----------:	|:-----:	|:----------------------------------------:	|:--------------------------------------------------------------------------------------------------:	|:-------:	|
|      Y      	|   1   	|   import_nex_files_spikes_and_bursts.m   	|      Saves all units, neurons, intervals into DATA, calculates BURSTunits. Runs Nex templates.     	|    x    	|
|      Y      	|   2   	|      calculate_light_lick_responses      	|            Process each unit's timestamps to calssify its lick and light-responsiveness            	|    x    	|
|      Y      	|   3   	| calc_spike_binned_data_remove_outliers.m 	| Uses rolling window to calculate outlier-removed binned data. Runs counts_unit_responses_for_table 	|    x    	|
|      Y      	|   4   	|      print_results_table_to_excel.m      	|                              prints out a table of all unit's results                              	|    x    	|
|      Y      	|   5   	|       prep_data_for_norm_firing_fig      	|               Calculates normalized firing data and creates structures for color plot              	|    x    	|
|      Y      	|   6   	| plot_normalized_firing_CRF_by_lick_types 	|                               Generates normalized firing rate figure                              	|    x    	|
|      Y      	|   7   	|             copyPasteSORTdata            	|                               Prints out grouped data for Prism/Excel                              	|         	|
|      Y      	|   8   	|       copyPasteSORTdata_EarlyVsLate      	|                               Prints out grouped data for Prism/Excel                              	|         	|
|      Y      	|   9   	|    copyPasteSORTdata_EarlyVsLateSPLITS   	|                               Prints out grouped data for Prism/Excel                              	|         	|
