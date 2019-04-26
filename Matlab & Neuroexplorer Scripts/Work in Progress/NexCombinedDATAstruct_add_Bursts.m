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



[batchfnames, fpath]=uigetfile({'*.plx; *.pl2 ; *.nex5','ephys files(*.plx,*.pl2,*.nex5,*.nex)'},'MultiSelect','on','Select your data files');
cd(fpath);
if ischar(batchfnames)
	batchfnames=cellstr(batchfnames);
end

nex = actxserver('NeuroExplorer.Application');
Q=1;
numFiles=length(batchfnames);
DATA(numFiles).fileinfo=[];
for Q=1:numFiles
	%%%Selects file Q from list of files and saves parts of filename to fill in info.
	%runTime{2}=clock;
	filename=batchfnames{Q};
	fullname=strcat(fpath,filename);
    fprintf('\nProcessing file:\n %s',fullname)
	
	doc = nex.OpenDocument(fullname);
    doc.DeselectAll();
    res = nex.RunNexScript('_MakeDIDEventNamesFixed.nsc');
%    disp('Running script D:\Users\James\Dropbox\Ephys Analysis\Nex Scripts\_MakeDIDEventNamesFixed.nsc')

    %%Reset file-specific variables 
    NEURON=struct();
  	clearvars neuronName* curr* regRes SPK sortedNeuronList currNeuronName WFs nexColumnNames nexColumnUnits 
    recIntervals={};
    DIDSessionInts=[];		

    %%get variable counts
	neuronCount=doc.NeuronCount;
	intCount=doc.IntervalCount;
	waveCount=doc.WaveCount;


%%%%%%%%% Craete and define DATA(Q).fileinfo
	DATA(Q).fileinfo.fullname=fullname;
	DATA(Q).fileinfo.filename=filename;

    DATA(Q).fileinfo.neuronCount=neuronCount;
    DATA(Q).fileinfo.intervals=[];
	DATA(Q).fileinfo.events=[];
	DATA(Q).fileinfo.mouse=[];
    DATA(Q).fileinfo.drink=[]; %Water, Ethanol, Sucrose
    DATA(Q).fileinfo.include=true;


%%%%Fill in intervals
	intervals=struct();

	for i=1:intCount
		currIntVals=[];
		currInt=doc.Interval(i);
		currIntName=currInt.Name;

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

%%%%Fill in events
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
addBURSTS=struct();

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
	
	%%%Fill in addDATA neuron info
    for m=1:length(sortedNeuronList)
		currNeuronName=char(sortedNeuronList{m});
		currNeuron=doc.Variable(currNeuronName);
        doc.Variable(currNeuronName).Select();
        nexColumnUnits{m}=currNeuronName;

        addDATA.units(m).name=currNeuronName;
        addDATA.units(m).ts=currNeuron.Timestamps();
	end


	%%%%%%%%%%%%%%%%%%RUN ANALYSES HERE FOR SPIKE RATES
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
	%%

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
	    %            Bin (sec) = 0.01
	    %            XMin = -0.2
    	%			 XMax= 0.2
    	%			Normalized: spikes/sec
	    %            Select Data = All
	    
		nex_PEH_LickRAW_spksec=doc.GetNumericalResults;
	    nexBinTimes=nex_PEH_LickRAW_spksec(:,1);
	    %Verify that the first column of nexRates is a time bins axis
		if nexBinTimes(2)==0
			error('nexRates first column is not time')
			else if abs((nexBinTimes(3)-nexBinTimes(2)))==abs(nexBinTimes(2))
				nexColumnNames={'Bin Left',nexColumnUnits{:}};
			end
		end
		addDATA.results.PEH_lickRAW.nex_PEH_LickRAW_spksec=nex_PEH_LickRAW_spksec;
		addDATA.results.PEH_lickRAW.nex_PEH_LickRAW_spksecColNames=nexColumnNames;

        
        %%%% ADDING BURST ANALYSIS 04-23-19 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        doc.ModifyTemplate('_CRFburstsParamA','Add Burst Interval Vars.','True')
        doc.ModifyTemplate(doc,"_CRFburstsParamA","Send to Matlab","False")
        doc.ApplyTemplate('_CRFburstsParamA')
        addBURSTS.results=doc.GetNumericalResults;
        
        for m=1:length(sortedNeuronList)
            currNeuronName=char(sortedNeuronList{m});
            currNeuron=doc.Variable(currNeuronName);
            doc.Variable(currNeuronName).Select();
            
            doc[currNeuronName+"_BurstSpikes"] = doc.IntervalFilter(doc[currNeuronName], doc[currNeuronName+" bursts"])    
            doc[currNeuronName+"_IntNonBurst"] = doc.IntOpposite(doc, doc[currNeuronName+" bursts"])
            doc[currNeuronName+"_NonBurstSpikes"] = doc.IntervalFilter(doc[currNeuronName], doc[currNeuronName+"IntNonBurst"])
            
            addDATA.units(m).name=currNeuronName;
            addDATA.units(m).ts=currNeuron.Timestamps();
        end

%%%%%WAVEFORM ANALYSIS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    for m=1:length(sortedWaveList)
		currWaveName=char(sortedWaveList{m});
		currWave=doc.Variable(currWaveName);
        currWaveValues=currWave.WaveformValues();
        currWaveTimes=currWave.Timestamps();
        doc.Variable(currWaveName).Select();

        WFs(m).name=currWaveName;
        WFs(m).waves=currWaveValues;
        WFs(m).times=currWaveTimes;

        addDATA.units(m).waves=currWaveValues;
        addDATA.units(m).filteredWaves=[];
        addDATA.units(m).lightResponse.tests=[];
        % addDATA.units(m).lightResponse.testExcited=[];
        % addDATA.units(m).lightResponse.testExcited=[];
		% addDATA.units(m).lightResponse.tests.CRFtests=[];
		% addDATA.units(m).lightResponse.tests=[];
        addDATA.units(m).lightResponse.type=[];
    	addDATA.units(m).lickResponse.tests=[];
    	addDATA.units(m).lickResponse.type=[];
    	addDATA.units(m).include=true;
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%calcWFcorrelationNexTrigd.m
	
	% sendWFs=WFs;
	sendIntervals=intervals;
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

%% Repalced call to nexDATA_splitSpikeRate with the code itself on 04/23/19
%disp('running nexDATA_splitSPikeRate')
%nexDATA_splitSpikeRate;
for Q = 1:length(DATA)
    for u=1:length(DATA(Q).units)
        if length(DATA(Q).units)== length(DATA(Q).results.spikeRate.nexCutRateHisto)
            DATA(Q).units(u).spikeRate = DATA(Q).results.spikeRate.nexCutRateHisto(u);
        end
    end
end
%% Run final script, dispaly directions to user and clearvars
nexOptionsCriteria;
clearvars -except DATA options* criteria*
savefilename='extracted_nex_DATA_only.mat'
save(savefilename,'-v7.3')
disp('Completed. Run nexDATAclassificationFixWIP2')
