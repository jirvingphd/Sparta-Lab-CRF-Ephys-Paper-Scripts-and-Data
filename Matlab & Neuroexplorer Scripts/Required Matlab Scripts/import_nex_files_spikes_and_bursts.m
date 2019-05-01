%%nexCombinedDATAstruct.m
%Has user select multiple ephys data files and creates DATA structure containing:
% DATA(Q).fileinfo:
%	filename - filename
%	fullname
%	events
%		EventPulse
%		EventLick
%		Etc.
%	intervals
%		...
% DATA(Q).units(u):
%	name
%	ts
%	waves
%	filteredWaves.[intervals]:
%		filtTimes
%		filtWaves
%	lightResponse
%	lickResponse
% DATA(Q).results:
%	spikeRate
%	PEH_pulse
%	PEH_lick
%	PEH_lickAW
%REQUIRES:
% 	nexCutRateHisto.m	   %%%%%%NexTrigd.m
%	calcWFcorrelationMLTrigd.m
%	nexUnitResponses.m
%		JMI_spkMatFun.m

%runTime{1}=clock;


%% Select files and connect to Nex
[batchfnames, fpath]=uigetfile({'*.plx; *.pl2 ; *.nex5','ephys files(*.plx,*.pl2,*.nex5,*.nex)'},'MultiSelect','on','Select your data files');
cd(fpath);
if ischar(batchfnames)
    batchfnames=cellstr(batchfnames);
end

nex = actxserver('NeuroExplorer.Application');
Q=1;
numFiles=length(batchfnames);
DATA(numFiles).fileinfo=[];
BURSTS=struct();

for Q=1:numFiles
    %%%Selects file Q from list of files and saves parts of filename to fill in info.
    %runTime{2}=clock;
    filename=batchfnames{Q};
    fullname=strcat(fpath,filename);
    fprintf('\nProcessing file:\n %s',fullname)
    
    doc = nex.OpenDocument(fullname);
    doc.DeselectAll();
    res = nex.RunNexScript('_MakeDIDEventNamesFixed.nsc');
    
    %%Reset file-specific variables
    NEURON=struct();
    clearvars neuronName* curr* regRes SPK sortedNeuronList currNeuronName WFs nexColumnNames nexColumnUnits
    recIntervals={};
    DIDSessionInts=[];
    
    %%get variable counts
    neuronCount=doc.NeuronCount;
    intCount=doc.IntervalCount;
    waveCount=doc.WaveCount;
    
    
    %% Create and define DATA(Q).fileinfo
    DATA(Q).fileinfo.fullname=fullname;
    DATA(Q).fileinfo.filename=filename;
    
    DATA(Q).fileinfo.neuronCount=neuronCount;
    DATA(Q).fileinfo.intervals=[];
    DATA(Q).fileinfo.events=[];
    DATA(Q).fileinfo.mouse=[];
    DATA(Q).fileinfo.drinkType=[]; %Water, Ethanol, Sucrose
    DATA(Q).fileinfo.drinkDay=[];
    DATA(Q).fileinfo.include=true;
    
    
    %% %%Fill in intervals
    intervals=struct();
    
    for i=1:intCount
        currIntVals=[];
        currInt=doc.Interval(i);
        currIntName=currInt.Name;
        if strcmpi(currIntName,'burst')
            continue
        end
        
        
        currIntStart=currInt.IntervalStarts();
        currIntEnd=currInt.IntervalEnds();
        currIntVals(:,1)=currIntStart;
        currIntVals(:,2)=currIntEnd;
        
        intervals(i).intName=currIntName;
        intervals(i).intTimes=currIntVals;
        
        if strcmp(currIntName,'DIDSessionInts')
            DIDSessionInts=currIntVals;
        end
    end
    DATA(Q).fileinfo.intervals=intervals;
    
    %% %%Fill in events
    % res = nex.RunNexScript('D:\Users\James\Dropbox\Ephys Analysis\Nex Scripts\_MakeDIDEventNamesFixed.nsc');
    EventLick=doc.Variable('EventLick').Timestamps();
    EventLickRAW=doc.Variable('EventLickRAW').Timestamps();
    EventPulse=doc.Variable('EventPulse').Timestamps();
    EventPulseRAW=doc.Variable('EventPulseUNFILT').Timestamps();
    EventTrain=doc.Variable('EventTrain').Timestamps();
    
    DATA(Q).fileinfo.events.EventPulse=EventPulse;
    DATA(Q).fileinfo.events.EventLick=EventLick;
    DATA(Q).fileinfo.events.EventPulseRAW=EventPulseRAW;
    DATA(Q).fileinfo.events.EventLickRAW=EventLickRAW;
    DATA(Q).fileinfo.events.EventTrain=EventTrain;
    
    %%%%%%%%%%%%%
    
    
    addDATA=struct();
    
    
    %%%%%%%%%%%Select and save sorted neurons
    neuronList=[];
    for n=1:neuronCount
        currNeuron=doc.Neuron(n);
        currNeuronName=currNeuron.Name;
        neuronNames{n}=currNeuronName;
    end
    
    %%%Select sorted neurons
    regRes=cellfun(@(x)regexpi(x,'(sig0|SPK)\d{2,}.?[a-g]','match'),neuronNames,'UniformOutput',0);
    empty=cellfun(@isempty,regRes);
    regRes(empty)=[];
    sortedNeuronList=regRes;
    
    %%Deselect clearvars
    doc.DeselectAll();
    clearvars NeuronName* curr* regRes NexColumnNames  %@now
    
    %% Fill in the unit timestamps and names
    for u=1:length(sortedNeuronList)
        currNeuronName=char(sortedNeuronList{u});
        currNeuron=doc.Variable(currNeuronName);
        doc.Variable(currNeuronName).Select();
        nexColumnUnits{u}=currNeuronName;
        
        addDATA.units(u).name=currNeuronName;
        addDATA.units(u).ts=currNeuron.Timestamps();
    end
    
    %% %%%%%%%%%%%%%%%%RUN ANALYSES HERE FOR SPIKE RATES
    
    % res=nex.RunNexScriptCommands('doc=GetActiveDocument() \n ApplyTemplate(doc,"OA_rateHist_DIDSessionInts")')
    doc.ApplyTemplate('OA_rateHist_DIDSessionInts')
    %        % %TEMPLATE DEFAULTS:
    %			Normalized=spk/sec
    %            Bin (sec) = 5
    %            XMin/XMax type = Auto
    %            Select Data = All
    %            Interval Filter = DIDSessionInts
    %            Smooth = None!
    %            Sm. Width = 5
    %clearvars nexRates nexBinTimes nexColumnNames %@now
    
    nexRates=doc.GetNumericalResults;
    [numBins, numCols]=size(nexRates);
    nexBinTimes=nexRates(:,1);
    
    
    %Verify that the first column of nexRates is a time bins axis
    if nexBinTimes(2)==0
        error('nexRates first column is not time')
    else if abs((nexBinTimes(3)-nexBinTimes(2)))==abs(nexBinTimes(2))
            nexColumnNames={'Bin Left',nexColumnUnits{:}};
        end
    end
    addDATA.results.spikeRate.nexRatesRAWcolNames=nexColumnNames;
    addDATA.results.spikeRate.nexRatesRAW=nexRates;
    
    %%Run matlab program to remove data outside DIDSessionInts
    %tic
    disp('Running nexCutRateHistoNexTrigdFUN')
    %Cut out non-good session times and then recomhined for a new matrix
    [SPK]=nexCutRateHistoNexTrigdFUN(nexRates, nexColumnNames);
    % toc
    addDATA.results.spikeRate.nexCutRateHisto=SPK;
    
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%% RUN PEH FOR LICKS AND PULSES TO JUDGE CRF
    doc.ApplyTemplate('SL_PEH_Pulse_spksec_ML')
    %        % %TEMPLATE DEFAULTS:
    %            Bin (sec) = 0.01
    %            XMin = -0.02
    %			 XMax= 0.08
    %			Normalized: spikes/sec
    %            Select Data = All
    
    %%import numerical results into ML and re-produce nexColumnNames manually
    nex_PEH_Pulse_spksec=doc.GetNumericalResults;
    nexBinTimes=nex_PEH_Pulse_spksec(:,1);
    %Verify that the first column of nexRates is a time bins axis
    if nexBinTimes(2)==0
        error('nexRates first column is not time')
    else if abs((nexBinTimes(3)-nexBinTimes(2)))==abs(nexBinTimes(2))
            nexColumnNames={'Bin Left',nexColumnUnits{:}};
        end
    end
    
    addDATA.results.PEH_pulse.nex_PEH_Pulse_spksec=nex_PEH_Pulse_spksec;
    addDATA.results.PEH_pulse.nex_PEH_Pulse_spksecColNames=nexColumnNames;
    
    %%%%%%%%%%%%%%%%%% RUN PEH FOR LICKS
    doc.ApplyTemplate('SL_PEH_Lick_spksec_ML')
    %        % %TEMPLATE DEFAULTS:
    %            Bin (sec) = 0.01
    %            XMin = -0.1
    %			 XMax= 0.1
    %			Normalized: spikes/sec
    %            Select Data = All
    
    nex_PEH_Lick_spksec=doc.GetNumericalResults;
    nexBinTimes=nex_PEH_Lick_spksec(:,1);
    %Verify that the first column of nexRates is a time bins axis
    if nexBinTimes(2)==0
        error('nexRates first column is not time')
    else if abs((nexBinTimes(3)-nexBinTimes(2)))==abs(nexBinTimes(2))
            nexColumnNames={'Bin Left',nexColumnUnits{:}};
        end
    end
    addDATA.results.PEH_lick.nex_PEH_Lick_spksec=nex_PEH_Lick_spksec;
    addDATA.results.PEH_lick.nex_PEH_Lick_spksecColNames=nexColumnNames;
    
    %%%%%%%%%%%%%%%%%% RUN PEH FOR LICKS
    doc.ApplyTemplate('SL_PEH_LickRAW_spksec_ML')
    %        % %TEMPLATE DEFAULTS:
    %            Bin (sec) = 0.01 , XMin = -0.2 , XMax= 0.2, Normalized: spikes/sec, Select Data = All
    
    nex_PEH_LickRAW_spksec=doc.GetNumericalResults;
    nexBinTimes=nex_PEH_LickRAW_spksec(:,1);
    %Verify that the first column of nexRates is a time bins axis
    if nexBinTimes(2)==0
        error('nexRates first column is not time')
    elseif abs((nexBinTimes(3)-nexBinTimes(2)))==abs(nexBinTimes(2))
        nexColumnNames={'Bin Left',nexColumnUnits{:}};
    end
    addDATA.results.PEH_lickRAW.nex_PEH_LickRAW_spksec=nex_PEH_LickRAW_spksec;
    addDATA.results.PEH_lickRAW.nex_PEH_LickRAW_spksecColNames=nexColumnNames;
    
    %% %%%%%%%%%%%%        %% ADDING BURST ANALYSIS BOOKMARK
    nex_Burst_cols={};
    nex_Burst_results={};
    
    doc.ApplyTemplate('_CRFburstsParamA');
    %         res = nex.RunNexScript('minimal_bursting_analysis.nsc');
    nex_Burst_cols = doc.GetNumericalResultsColumnNames';
    nex_Burst_results = doc.GetNumericalResults;
    
    test_results = num2cell(nex_Burst_results,1);
    
    [nex_Burst_results_cell] = remove_nan_rows(test_results);
    
    %     % make anyonymous function for finding nan
    % %     nancheck=@(x) any(isnan(x),x);
    %     % apply nancheck to x
    %     nanidx = cellfun(nancheck, test_results,'UniformOutput',false);
    % %     nex_Burst_results_cell(cellfun(@(x) isnan(x),x)) = [];
    %     % combine into nexBurstResults
    nexBurstResults = [nex_Burst_cols; nex_Burst_results_cell ];
    BURSTS(Q).results = nexBurstResults;
    
    %     %%% Process the numerical results
    %     % Extract the name of the units from the results columns
    %     [nexColNameUnits]=cellfun(@(x)regexpi(x,'(SPK\d\d[a-h])\s(\w*)','tokens'),nex_Burst_cols,'UniformOutput',false);
    %     nexCols_unit_data = {};
    %     % Extract the unit name and then data-analysis-name into nexCols_unit_data
    %     for n=1:length(nexColNameUnits)
    %         nexCols_unit_data{n,1}=nexColNameUnits{n}{1}{1}';
    %         nexCols_unit_data{n,2}=nexColNameUnits{n}{1}{2}';
    %     end
    %
    %     nexBurstResults=cell(2,length(nex_Burst_cols));
    %     for i=1:length(nex_Burst_cols)
    %         nexBurstResults{1,i}=nex_Burst_cols{i};
    %         nexBurstResults{2,i}=num2cell(nex_Burst_results(:,i));
    %     end
    %
    %%% Process The Burst Spikes and Interval
    % combined results and headers into BURSTcells
    
    
    %% Getting the interval variables from Nex
    res=nex.RunNexScript('make_burst_intervals_ML.nsc');
    %% Search Nex's Interval Names to Select Int_list
    int_list = {};
    ii=1;
    for i=1:doc.IntervalCount
        int_name = doc.Interval(i).Name;
        if (contains(int_name,'burst','IgnoreCase',true)==1) && (contains(int_name,'lick','IgnoreCase',true)==0)
            int_list{ii,1} = int_name;
            int_start = [doc.Interval(i).IntervalStarts];
            int_end = [doc.Interval(i).IntervalEnds];
            int_list{ii,2} = [int_start;int_end];
            ii=ii+1;
        else
%             fprintf('%s is a non-burst interval and was excluded\n',int_name)
        end
    end
    BURSTS(Q).intervals = int_list;
%     fprintf('The missing unit data for BURSTS happens below\n  Units above a certain point do not have BurstSpikes and nonBurstSpikes in Nex.\n')
%     fprintf('The issue is also that the intervals for IntNonBurst are not being generated for those same # of cells')
    %% Search Nex's Event Names to Select Evt_List
    evt_list = {};
    ii=1;
    for i=1:doc.EventCount
        evt_name = doc.Event(i).Name;
        disp(evt_name)
        if contains(evt_name,'burst','IgnoreCase',true)
            evt_list{ii,1} = evt_name;
            evt_obj = doc.Event(i);
            evt_ts = evt_obj.Timestamps();
            evt_list{ii,2} = [evt_ts];
            ii=ii+1;
        end
    end
    BURSTS(Q).filtered_spikes = evt_list;
    
    %% %%%WAVEFORM ANALYSIS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    doc.DeselectAll();
    %%%%%%%%%%select and save sorted wfs
    waveList=[];
    for w=1:waveCount
        currWave=doc.Wave(w);
        currWaveName=currWave.Name;
        waveList{w}=currWaveName;
    end
    
    %%%Select sorted waves
    % regRes=cellfun(@(x)regexpi(x,'(sig0|SPK)\d{2,}.?[a-g](+_wf)','match'),neuronNames,'UniformOutput',0);
    regRes=cellfun(@(x)regexpi(x,'(sig0|SPK)\d{2,}[^i]+(_wf)','match'),waveList,'UniformOutput',0);
    empty=cellfun(@isempty,regRes);
    regRes(empty)=[];
    sortedWaveList=regRes;
    
    WFs=struct();
    
    for u=1:length(sortedWaveList)
        currWaveName=char(sortedWaveList{u});
        currWave=doc.Variable(currWaveName);
        currWaveValues=currWave.WaveformValues();
        currWaveTimes=currWave.Timestamps();
        doc.Variable(currWaveName).Select();
        
        WFs(u).name=currWaveName;
        WFs(u).waves=currWaveValues;
        WFs(u).times=currWaveTimes;
        
        addDATA.units(u).waves=currWaveValues;
        addDATA.units(u).filteredWaves=[];
        addDATA.units(u).lightResponse.tests=[];
        % addDATA.units(m).lightResponse.testExcited=[];
        % addDATA.units(m).lightResponse.testExcited=[];
        % addDATA.units(m).lightResponse.tests.CRFtests=[];
        % addDATA.units(m).lightResponse.tests=[];
        addDATA.units(u).lightResponse.type=[];
        addDATA.units(u).lickResponse.tests=[];
        addDATA.units(u).lickResponse.type=[];
        addDATA.units(u).include=true;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%calcWFcorrelationNexTrigd.m
    
    % sendWFs=WFs;
    k=1;
    sendIntervals=struct();
    for s=1:length(intervals)
        if contains(intervals(s).intName,'burst','IgnoreCase',true)
            continue
        else
            sendIntervals(k).intName=intervals(s).intName;
            sendIntervals(k).intTimes=intervals(s).intTimes;
            k=k+1;
        end
    end
    
    send_figTitle=filename;
    
    calcWFcorrelationMLTrigd;
    % plot_calcWFcorrelationMLTrigd;
    
    
    %%%%%%%%%%%%%%%%%%
    
    doc.DeselectAll();
    
    %%%%%%%%
    %%Removed on 02-25-17
    %res = nex.RunNexScript('D:\Users\James\Dropbox\Ephys Analysis\Nex Scripts\SL_GetPeriZScores.nsc');
    % % res = nex.RunNexScript('D:\Users\James\Dropbox\Ephys Analysis\nex scripts\SL_DID_overview-postGetPeri.nsc');
    
    DATA(Q).units=addDATA.units;
    DATA(Q).results=addDATA.results;
    doc.Close();
    clearvars WFs
    
end
%runTime{3}=clock;
release(nex);
%% Run the minimal_burst_analysis script
minimal_burst_analysis
fprintf('minimal_burst_analysis complete.')
%% Repalced call to nexDATA_splitSpikeRate with the code itself on 04/23/19
for Q = 1:length(DATA)
    for u=1:length(DATA(Q).units)
        if length(DATA(Q).units)== length(DATA(Q).results.spikeRate.nexCutRateHisto)
            DATA(Q).units(u).spikeRate = DATA(Q).results.spikeRate.nexCutRateHisto(u);
        end
    end
end
%% Run final script, dispaly directions to user and clearvars
% nexOptionsCriteria;
% clearvars -except DATA options* criteria*
clearCRFdata
%% Save
saveQ = input('Nex analysis compelte.\nSave DATA file now?(y/n):\n','s');
if contains(saveQ,'y','IgnoreCase',true)
    savefilename='extracted_nex_DATA_only.mat';
    
    if isfile(savefilename)
        user_choice=[];
        msg = sprintf('%s already exists.\n Overwrite(y), rename output(r), or cancel(n)?: (y/r/n)\n',savefilename);
        user_choice = input(msg,'s');
        
        if strcmpi(user_choice,'y')
            save(savefilename, '-v7.3')
            fprintf('Data was saved as:\n %s\n',savefilename)
            
        elseif strcmpi(user_choice, 'r')
            newname = input('Enter new filename (must end with .mat):\n','s');
            save(newname,'-v7.3')
            fprintf('Data was saved as:\n %s\n',newname)
        else
            fprintf('Analysis complete. Results not saved.\n')
        end
    else
        save(savefilename, '-v7.3')
        fprintf('Data was saved as:\n %s\n',savefilename)
    end
end
%     save(savefilename,'-v7.3')
disp('Completed. Run calculate_light_lick_responses')
clearCRFdata
