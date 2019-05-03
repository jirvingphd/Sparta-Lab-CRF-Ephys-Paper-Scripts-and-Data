%%% nexPrepAll_forNormFiringFigsSpliByDeltaRate.m
% James M. Irving  edited 10-03-18
% Performs all matrix-creating prep, analysis, and plotting for the
% normalized firing rate data, and %SiB data. Needed to produce output data
% to paste into Graphpad tempalte bar and line graph files. (using "copyPaste..." scripts)

% Creates COUNTStoPlot and RATEScut and SORTtracker/SORTtrackerByLight, PLOTdata data structures
% For Graphpad Prism data, you can use copyPaste script to export to excel,
% but the numbers used ultimately come from SORTtracker (or PLOTdata,
% double check).


%% User must edit these variables to customize the resutls:
% Uncomment ONE drinkToProcess
% fprintf('This new version is made for all units, not just CRF.\n');
% drinkToProcess='ethanol';
% drinkToProcess='water';
drinkToProcess='sucrose';

%Change binsize (sec) for firing rates if need be
binsize=300;

%% Generate COUNTStoPlot structure:
% Extract the COUNTS/indices every lightLick type (not just light or just lick) and RATEScut structure
% %CRFcounts.all=COUNTS.light.CRF;
% if exist('COUNTS','var')==0
%     fprintf('COUNTS var not found.\nRunning count_unit_responses_for_table.\n');
%     count_unit_responses_for_table; %Changed nexDATAcountUnits to Final on 10-03-18
% end
count_unit_responses_for_table;
%% Loop through COUNTS.lightLick.(lightType).(lickType) to create new COUNTStoPlot structure.
COUNTStoPlot=struct();

lightList=fieldnames(COUNTS.lightLick);
for i=1:length(lightList)
    
    currLightType=lightList{i};
    lickList=fieldnames(COUNTS.lightLick.(currLightType).count);
    
    for j=1:length(lickList)
        currLickType=lickList{j};
        COUNTStoPlot.(currLightType).count.(currLickType)=COUNTS.lightLick.(currLightType).count.(currLickType);
        [COUNTStoPlot.(currLightType).index.(currLickType)]=cell2mat(COUNTS.lightLick.(currLightType).index.(currLickType));
    end
end



%% Use COUNTStoPlot to create create firing rate structure, RATEScut,
%  Its a structure (1 x #units) sized array that has one row for every unit of all types.
RATEScut=struct();
lightList=fieldnames(COUNTStoPlot);

r=1; %index for filling in RATEScut later in script

%for each type of light response
for c=1:length(lightList)
    
    currLightType=lightList{c}; %select current response
    
    lickList=fieldnames(COUNTStoPlot.(currLightType).count); %Get the names of the sub-fields (the lickResponses)
    
    %for each lick type
    for i=1:length(lickList)
        
        currLickType=lickList{i};
        
        %If there are units of currentLight-Lick type, save their Q,u index ( DATA(Q).units(u) ) as COUNTSindex
        if COUNTStoPlot.(currLightType).count.(currLickType)>0
            if isfield(COUNTStoPlot.(currLightType).count,currLickType)==0
                COUNTStoPlot.(currLightType).count.(currLickType)=[NaN];
                COUNTStoPlot.(currLightType).index.(currLickType)=[NaN];
            end
            COUNTSindex=COUNTStoPlot.(currLightType).index.(currLickType);
        else %if there are 0 units, skip.
            continue
        end
        
        %% Use DIDSession Intervals to make and cut timebins using cutTimesGoodInts
        % Goes through index, Q/u pair at a time and checks for DIDSesionInts, and
        % defines goodInts = DIDSessionInts
        k=1;
        Q=[];
        u=[];
        idxUnits=COUNTSindex;
        while k<=(size(idxUnits,1))
            
            Q=idxUnits(k,1);
            u=idxUnits(k,2);
            
            %find DIDSessionInts matrix in DATA.fileinfo
            goodInts=[];
            for j=1:length(DATA(Q).fileinfo.intervals)
                checkCurrInt=DATA(Q).fileinfo.intervals(j);
                if strcmp(checkCurrInt.intName,'DIDSessionInts')>0
                    goodInts=DATA(Q).fileinfo.intervals(j).intTimes;
                end
            end
            
            if isempty(goodInts)
                error(sprintf('Could not find DIDSessionInts at Q=%d u=%d',Q,u));
            end
            %
            
            %%send timestamps and intervals to cutBinTimesGoodInts to produce RATEScut.
            timestamps=DATA(Q).units(u).ts;
            currLightType=DATA(Q).units(u).finalLightResponse;
            currLickType=DATA(Q).units(u).finalLickResponse;
            
            
            %% [i] THIS SECTION RIGHT HERE WILL DETERMINE WHICH FIRING RATE DATA
            %        WILL BE USED FOR THE NORMALIZED FIRING RATE ANALYSIS. 
            %        MAKE SURE THE SOURCE OF THE cutData, etc IS THE VERSION YOU WANT TO USE.

            %Send in current cells ts, the binsize in seconds, and the intervals to
            %[cutData, cutBins, binnedData, timebins]= cutBinTimesGoodInts(timestamps, binsize, goodInts);
            
            cutData=DATA(Q).units(u).spikeRate.ratesClean;
            cutBins=DATA(Q).units(u).spikeRate.binsRaw;
            timebins=cutBins; %was []
            binnedData=DATA(Q).units(u).spikeRate.ratesRaw;
            
            
            %% Quick way to search through subfields to find text
            %%Get the correct DIDSessionInts interval variable from DATA.fileinfo
            searchFor='DIDSessionInts';
            currTestInt=cell2mat( arrayfun(@(x)  strcmp(x.intName,searchFor), DATA(Q).fileinfo.intervals,'UniformOutput',false));
            goodInts=DATA(Q).fileinfo.intervals(currTestInt==1).intTimes;
            
            %% Save the results in a new RATEScut structure
            RATEScut(r).index=[Q,u];
            RATEScut(r).lightType=currLightType;
            RATEScut(r).lickType=currLickType;
            RATEScut(r).goodInts=goodInts;
            
            RATEScut(r).cutData=cutData;
            RATEScut(r).cutBins=cutBins;
            
            RATEScut(r).rawData=binnedData;
            RATEScut(r).timebins=timebins;
            
            RATEScut(r).zScoreCutData = calcOutlierZscoresV2(cutData);
            RATEScut(r).zScoreRawData = calcOutlierZscoresV2(binnedData);

            
            r=r+1;
            k=k+1;
        end
        clearvars Q u neuronType COUNTSindex idxQU*
        %     clearvars curr* i ii num* goodInts idx* cutBins cutData c COUNTSindex Q u timebins timestamps
    end
end
clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* cluster* LICK* CORR* SPIKE* light* lick* RESULT* quick*

fprintf('Running rates_table_to_excel.m\n')
rates_table_to_excel

% fprintf('Next, run prep_data_for_norm_firing_fig.m\n')