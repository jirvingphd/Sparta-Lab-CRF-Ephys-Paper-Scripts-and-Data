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
fprintf('This new version is made for all units, not just CRF.\n');
drinkToProcess='ethanol';
% drinkToProcess='water';
% drinkToProcess='sucrose';

%Change binsize (sec) for firing rates if need be
binsize=300;

%% Generate COUNTStoPlot structure:
% Extract the COUNTS/indices every lightLick type (not just light or just lick) and RATEScut structure
COUNTStoPlot=struct();
%CRFcounts.all=COUNTS.light.CRF;

fprintf('Running nexDATAcountUnitsFinal.\n');
nexDATAcountUnitsFinal; %Changed nexDATAcountUnits to Final on 10-03-18

%% Loop through COUNTS.lightLick.(lightType).(lickType) to create new COUNTStoPlot structure.
lightList=fieldnames(COUNTS.lightLick);
for i=1:length(lightList)
    
    currLightType=lightList{i};
    lickList=fieldnames(COUNTS.lightLick.(currLightType));
    
    for j=1:length(lickList)
        currLickType=lickList{j};
        COUNTStoPlot.(currLightType).(currLickType).count=COUNTS.lightLick.(currLightType).(currLickType).count;
        [COUNTStoPlot.(currLightType).(currLickType).index]=cell2mat(COUNTS.lightLick.(currLightType).(currLickType).index);
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
    
    lickList=fieldnames(COUNTStoPlot.(currLightType)); %Get the names of the sub-fields (the lickResponses)
    
    %for each lick type
    for i=1:length(lickList)
        
        currLickType=lickList{i};
        
        %If there are units of currentLight-Lick type, save their Q,u index ( DATA(Q).units(u) ) as COUNTSindex
        if COUNTStoPlot.(currLightType).(currLickType).count>0
            COUNTSindex=COUNTStoPlot.(currLightType).(currLickType).index;
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
        while k<=(size(idxUnits,1));
            
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
                error(sprintf('Could not find DIDSessionInts at Q=%d u=%d',Q,u))
            end
            %
            
            %% send timestamps and intervals to cutBinTimesGoodInts to produce RATEScut.
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
            %%
            
            %% Save the results in a new RATEScut structure
            RATEScut(r).index=[Q,u];
            RATEScut(r).lightType=currLightType;
            RATEScut(r).lickType=currLickType;
            
            RATEScut(r).cutData=cutData;
            RATEScut(r).cutBins=cutBins;
            
            RATEScut(r).rawData=binnedData;
            %         RATEScut(r).rawBins=timebins;
            RATEScut(r).timebins=timebins;
            
            RATEScut(r).goodInts=goodInts;
            
            r=r+1;
            k=k+1;
        end
        clearvars Q u neuronType COUNTSindex idxQU*
        %     clearvars curr* i ii num* goodInts idx* cutBins cutData c COUNTSindex Q u timebins timestamps
    end
end
clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* cluster* LICK* CORR* SPIKE* light* lick* RESULT* quick*

%% Use RATEScut(r) structure to fill in clusterMats structure (grouped by light, lick types)
for r=1:length(RATEScut)
    
    % Create and pre-fill clusterMats
    listLickTypes={RATEScut(:).lickType};
    listUniqueLickTypes=unique(listLickTypes)';
    listLightTypes={RATEScut(:).lightType};
    listUniqueLightTypes=unique(listLightTypes)';
    clusterMats=struct();
    
    %     listLightTypes={RATEScut(:).lightType};
    %     listUniqueLightTypes=unique(listLightTypes);
    
    for l=1:length(listUniqueLightTypes)
        currLightType=listUniqueLightTypes{l};
        
        for j=1:length(listUniqueLickTypes)
            currLickType=listUniqueLickTypes{j};
            
            clusterMats.(currLightType).(currLickType).idx=[];
            clusterMats.(currLightType).(currLickType).rawRatesCleaned=[];
        end
    end
end


combRawRatesCleaned=[];
combCurrRATES_QU=[];
combCurrRATEScut=[];

for r=1:length(RATEScut)
    
    %Get current RATES data
    currRATEScut=RATEScut(r).cutData; %take single vector of firing rates (from RATEScut.cutData)
    currRATES_QU=RATEScut(r).index;
    currLightType=RATEScut(r).lightType;
    currLickType=RATEScut(r).lickType;
    currTimebins=RATEScut(r).timebins;
    
    %Get and combine indices
    %     if isfield(clusterMats,'currLightType')==0
    %         continue
    %     elseif isfield(clusterMats.(currLightType),'currLickType')==0
    %         continue
    %     end
    combCurrRATES_QU=clusterMats.(currLightType).(currLickType).idx;
    combCurrRATES_QU=[combCurrRATES_QU;currRATES_QU];
    clusterMats.(currLightType).(currLickType).idx=combCurrRATES_QU;
    
    %get and combine cleaned data
    combRawRatesCleaned=clusterMats.(currLightType).(currLickType).rawRatesCleaned;
    combRawRatesCleaned=[combRawRatesCleaned;currRATEScut];
    clusterMats.(currLightType).(currLickType).rawRatesCleaned=combRawRatesCleaned;
    
end
% end

clearvars comb* curr*
% dbstop if error

%% calculate Z-scores
lightTypeList=fieldnames(clusterMats);

for l=1:length(lightTypeList)
    currLightType=lightTypeList{l};
    lickTypeList=fieldnames(clusterMats.(currLightType));
    
    for k=1:length(lickTypeList)
        currLickType=lickTypeList{k};
        currData=clusterMats.(currLightType).(currLickType).rawRatesCleaned;
        
        if isempty(currData)==1
            fprintf('currData for %s: %s units is empty.\n',currLightType,currLickType)
            continue
        end
        %calculate baseline calculated z-scores
        [zScoredCleanData]=calcOutlierZscoresV2( currData);
        clusterMats.(currLightType).(currLickType).zMatCalcByBl=zScoredCleanData;
    end
end
clearvars comb* curr*

%% FOR EACH TYPE OF UNIT LICK RESPONSE, SPLIT INTO 2 CLUSTERS AND SORT THE UNITS BY TYPE AND FILL IN ORIGINAL INDICES IN SORTtracker
ERRshortPercBursts=[];
SORTtracker=struct();
lightTypeList=fieldnames(clusterMats);
for j=1:length(lightTypeList)
    clearvars curr* idx*
    
    currLightType=lightTypeList{j};
    
    lickTypeList=fieldnames(clusterMats.(currLightType));
    for k=1:length(lickTypeList)
        
        currLickType=lickTypeList{k};
        tempData=struct();    tempCurrDataSplit=[];     idxQU_currSplit=[];    dataSplit=struct();
        
        %%% Fill in SORTtracker.preSortData
        currDataIdxQU=clusterMats.(currLightType).(currLickType).idx;
        currDataRAW=clusterMats.(currLightType).(currLickType).rawRatesCleaned; %DONT HAVE YET!
        if isfield(clusterMats.(currLightType).(currLickType),'zMatCalcByBl')==0
            continue
        end
        currZdataCalcByBl=clusterMats.(currLightType).(currLickType).zMatCalcByBl;
        
        % SORTtracker.(currLightType).(currLickType).preSortData.rawRatesUnclean=clusterMats.(currLightType).(currLickType).rawRates;
        % SORTtracker.(currLightType).(currLickType).preSortData.dataPreSortBlSub= currZdataCalcByBl; %currDataSubZ;
        SORTtracker.(currLightType).(currLickType).preSortData.idxQUPreSort=currDataIdxQU;
        SORTtracker.(currLightType).(currLickType).preSortData.rawRatesCleaned=clusterMats.(currLightType).(currLickType).rawRatesCleaned;
        SORTtracker.(currLightType).(currLickType).preSortData.dataPreSortCalcByBl=currZdataCalcByBl;
        
        
        %% SPLIT AND SORTING ANALYSIS START
        
        currData=currZdataCalcByBl;% REAL CODE
        %     currData=clusterMats.inhibited.zMatCalcByBl; %TEST CODE
        
        numCols=size(currData,2); %number of timebins/cols
        quartTimes=floor(numCols/4); %figure out how many time bins covers 1/4 of time
        
        %FILL IN currDataAvg_Change: a vector of firing rate in final
        %quarter of session - first quart of session for each unit (row)
        currDataAvgQuarters=[];    currDataAvg_Change=[]; currDataSlopes=[];currDataIntercepts=[]; currDataAvgHour4=[];
        binsize=300;
        for i=1:size(currData,1) %for each row/unit...
            
            currDataRow=(currData(i,:));
            currDataRowQU=currDataIdxQU(i,:);
            
            %% New slope calculation
            slope=[]; intercept=[];p=[];testX=[]; testY=[];
            currTimebinsCalc=[0:length(currDataRow)-1];
            testX=currTimebinsCalc;
            testY=currDataRow;
            
            p=polyfit(testY, testX,1);
            currDataSlopes(i)=p(1);
            currDataIntercepts(i)=p(2);
            
            %% Try mean final hour
            currDataAvgHour4(i)=nanmean(currDataRow(36:48));
            
            %%Original change calc(but re-done in sortUnitRowsByRateChange
            currDataAvgQuarters(i,:)=[nanmean(currDataRow((end-quartTimes):end)), nanmean(currDataRow(1:quartTimes))]; %fill the current row of Avg - with the mean(ignore NaN) of first
            currDataAvg_Change(i)=currDataAvgQuarters(i,1)-currDataAvgQuarters(i,2); % WAS:             %currDataAvgChange(i)=mean(currRow((end-quarters):end)) -
        end
        
        currDataClusterNums=[];
        
        
        %% Median split by slope - OLD WAY OF DOING SPLIT
        %     [med]=median(currDataSlopes,2,'omitnan');
        %     medSplit=struct();
        %     for s=1:2
        %     %get values and idx for split 1
        %         switch s
        %             case s==1
        %                splitIdx=find(currDataSlopes>=med);
        %             case s==2
        %                 splitIdx=find(currDataSlopes<med);
        %         end
        %           splitQu=currDataIdxQU([splitIdx],:);
        %
        %             preSortSplitSlopes=currDataSlopes(splitIdx);
        %
        %             [~, sortSplitIdx]=sort(preSortSplitSlopes);
        %
        %             sortSplitData=currData([sortSplitIdx],:);
        %             sortSplitQu=splitQu([sortSplitIdx],:);
        %
        %             medSplit(s).sortedSplitData=sortSplitData;
        %             medSplit(s).currDataSplitIdx=sortSplitIdx;
        %             medSplit(s).sortedSplitQu=sortSplitQu;
        %     end
        
        %% NEW WAY OF DOING UNIT SORTING USING + vs - FIRING RATE CHANGES HOUR 4- HOUR 1
        % Originally split data based on median, but now split data by
        % + OR -, so made median value = 0;
       
        med=0;
        medSplit=struct();
        currDataToSortBy=currDataAvg_Change;
 
        % Loop through each light-lick type twice for the decreasing and increasing units
        for s=1:2  %s=# of data splits for current type
            clearvars splitIdx splitQu preSortSplit*
            
            %%% Get the indices of split 1, decreasing rate, and split 2,
            % increasing rate
            if s==2
                splitIdx=find(currDataToSortBy>0);
                splitRateChangeDir='increase';
            elseif s==1
                splitIdx=find(currDataToSortBy<0);
                splitRateChangeDir='decrease';
            end
            
            % Save split data as new variables
            splitDataPreSort=currData([splitIdx],:);
            splitQuPreSort=currDataIdxQU([splitIdx],:);
            
            %% REARRANGE/SORT the units, and SAVE THEIR ORDER, based on the value of "splitRateChange" calcualted above.
            splitRateChange=currDataAvg_Change([splitIdx]);
            [res,idx]=sort(splitRateChange);
            
            splitDataSorted=splitDataPreSort([idx],:);
            splitQuSorted=splitQuPreSort([idx],:);
            splitRateChangeSorted=splitRateChange([idx]); %,:);
            
            %Save each split's for current data into medSplit
            medSplit(s).splitDataSorted=splitDataSorted;
            medSplit(s).splitQuSorted=splitQuSorted;
            medSplit(s).splitRateChangeSorted=splitRateChangeSorted;
            
            
            %%Apply sorting to the rows of % spikes in burst data
            sortCurrDataRowIdx=splitQuSorted;
            tempCurrPercBurstSplit=NaN(length(sortCurrDataRowIdx),48);
            
            %%% Loop through the sortCurrentDataRowIdx index and construct
            % matrix of group bursting data
            for l=1:size(sortCurrDataRowIdx,1)
                
                Q=sortCurrDataRowIdx(l,1);
                u=sortCurrDataRowIdx(l,2);
                
                addBursts=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.binnedMeans; % Clean;
                tempCurrPercBurstSplit(l,1:length(addBursts))= addBursts;
                
                %Document resulting unit data that does not have a full 48 time bins for DID session.
                if length(addBursts)<48
                    ERRshortPercBursts=[ERRshortPercBursts; Q, u];
                    fprintf('  [!] Unit DATA(%d).units(%d) had %d out of 48 bins.\n',Q,u,length(addBursts));
                end
                
            end
            
            
            %% Save resutls to dataSplit structure, which will become sub-field of SORTtracker
            dataSplit(s).clusterNum=s;
            dataSplit(s).rateChange=splitRateChangeDir;
            dataSplit(s).idxQU_Split= medSplit(s).splitQuSorted;
            dataSplit(s).changeInNormFiring=medSplit(s).splitRateChangeSorted';
            %     dataSplit(s).dataSplitMat=[medSplit(s).splitDataSorted];
            dataSplit(s).dataSplitSortedMat=medSplit(s).splitDataSorted;
            dataSplit(s).percSpikesInBursts=tempCurrPercBurstSplit;
            
        end
        % end
        
        concatData=vertcat(dataSplit.dataSplitSortedMat);
        concatIdx=vertcat(dataSplit.idxQU_Split);
        concatPercBursts=vertcat(dataSplit.percSpikesInBursts);
        
        SORTtracker.(currLightType).(currLickType).sortedData.sortedRateDataIdx=concatIdx;
        SORTtracker.(currLightType).(currLickType).sortedData.sortedRateDataToPlot=concatData;
        SORTtracker.(currLightType).(currLickType).sortedData.sortedPercBurstDataToPlot=concatPercBursts;
        SORTtracker.(currLightType).(currLickType).sortedData.dataSplit=dataSplit;
        
        
        clearvars dataSplit* temp* currDataSorted sortCurrDataRowIdx concatData sortedIdxQU_Split
    end
end
clearvars curr* idx* i ii j k list* num*

%% AT THE END, RETRIEVE FILE INFO TO GO WITH Q,U INDICES
lightTypeList=fieldnames(SORTtracker);

for r = 1:length(lightTypeList)
    currLightType=lightTypeList{r};
    
    lickTypeList=fieldnames(SORTtracker.(currLightType));
    
    for ii=1:length(lickTypeList)
        currLickType=lickTypeList{ii};
        
        fullFileUnitIndex={};
        currQ=[];
        currU=[];
        tempIdxQU=[];
        
        %     subfields=fieldnames(SORTtracker.(currLightType));
        
        
        %     if isfield(SORTtracker.(currLightType),'idxQU_sorted')
        for k=1:size(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit,2)
            tempIdxQU=SORTtracker.(currLightType).(currLickType).sortedData.dataSplit(k).idxQU_Split;
            
            tempBurstData=[];
            currSplitBurstData=[];
            
            for ii=1:size(tempIdxQU,1)%length(tempIdxQU)
                
                currQ=tempIdxQU(ii,1);
                currU=tempIdxQU(ii,2);
                fullFileUnitIndex{ii,1}=[currQ,currU];
                
                fullFileUnitIndex{ii,2}=DATA(currQ).fileinfo.filename;
                fullFileUnitIndex{ii,3}=DATA(currQ).units(currU).name;
                fullFileUnitIndex{ii,4}=DATA(currQ).units(currU).finalLightResponse;
                fullFileUnitIndex{ii,5}=DATA(currQ).units(currU).finalLickResponse;
                
            end
            
            if isfield(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit(k),'fullFileUnitIndex')==0
                continue
            elseif isempty(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit(k).fullFileUnitIndex)
                continue
            end
            
            SORTtracker.(currLightType).(currLickType).sortedData.dataSplit(k).fullFileUnitIndex=fullFileUnitIndex;
            
            clearvars fullFileUnitIndex percBurstdataToAddMaxNan percBurstdataSizeTest percBurstdataCellToAdd
            
        end
    end
    clearvars fullFileUnitIndex tempIdxQU currSplit* currQ currU
    
end
% clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* SPIKE* LICK* CORR*
% clearCRFdata;
% SORTtracker=orderfields(SORTtracker,{'excited','predictExcited','inhibited','NR'});
%     SORTtracker=orderfields(SORTtracker,{'NR','excited','predictExcited','inhibited'});
clearvars fullFileUnitIndex tempIdxQU currSplit* currQ currU

clearvars curr* idx* i ii j k list* num* l m r *Fields *fields temp*  quartTimes n b baseline* bin* bl* c percBurst* test* vars z
%% Combine all crf into one matrix and sort
lightTypes=fieldnames(SORTtracker);
SORTbyLight=struct();
SORTbyLight.lightType=[];
SORTbyLight.idx=[];
SORTbyLight.rateData=[];
SORTbyLight.percBurstData=[];

% ss=1;
for s=1:length(lightTypes)
    currLightType=lightTypes{s};
    
    lickFields=fieldnames(SORTtracker.(currLightType));
    combUnitIdx=[];
    combLightTypeRates=[];
    combLightTypePercBurst=[];
    
    for o=1:length(lickFields)
        currLickType=lickFields{o};
        
        dataIdxToAdd=[];
        dataIdxToAdd=SORTtracker.(currLightType).(currLickType).sortedData.sortedRateDataIdx  ;
        combUnitIdx=[combUnitIdx;dataIdxToAdd];
        
        rateDataToAdd=[];
        rateDataToAdd=SORTtracker.(currLightType).(currLickType).sortedData.sortedRateDataToPlot;%
        combLightTypeRates=[combLightTypeRates;rateDataToAdd];
        
        percBurstDataToAdd=[];
        percBurstDataToAdd=SORTtracker.(currLightType).(currLickType).sortedData.sortedPercBurstDataToPlot;
        percBurstDataToAdd(~any(~isnan(percBurstDataToAdd),2),:)=[];
        combLightTypePercBurst=[combLightTypePercBurst;percBurstDataToAdd];
    end
    %Now have currLightType matrix
    SORTbyLight(s).lightType=currLightType;
    SORTbyLight(s).idx=combUnitIdx;
    SORTbyLight(s).rateData=combLightTypeRates;
    SORTbyLight(s).percBurstData=combLightTypePercBurst;
    %       s=s+1
end

%% combine all nonCRF into one matrix and sort
%%Get the correct DIDSessionInts interval variable from DATA.fileinfo
searchFor='CRF';
currTestInt=cell2mat( arrayfun(@(x)  strcmp(x.lightType,searchFor), SORTbyLight,'UniformOutput',false));

sCRF=find(currTestInt);
sNonCRF=~(currTestInt);

currRateData=SORTbyLight(sCRF).rateData;
currBurstData=SORTbyLight(sCRF).percBurstData;
currUnitIdx=SORTbyLight(sCRF).idx;

currDataToSortBy=nanmean(currRateData(:,36:48),2);
[res, resIdx]=sort(currDataToSortBy);
sortedRateData=[currRateData([resIdx],:)];
sortedBurstData=[currBurstData([resIdx],:)];
sortedUnitsIdx=[currUnitIdx([resIdx],:)];
SORTbyLightOut(sCRF).dataType='CRF';
SORTbyLightOut(sCRF).sortedIdx=sortedUnitsIdx;
SORTbyLightOut(sCRF).sortedRateData=sortedRateData;
SORTbyLightOut(sCRF).sortedBurstData=sortedBurstData;
clearvars currRateData currBurstData currUnitIdx
%% Non-CRT now
currRateData=vertcat(SORTbyLight(sNonCRF==1).rateData);
currBurstData=vertcat(SORTbyLight(sNonCRF==1).percBurstData);
currUnitIdx=vertcat(SORTbyLight(sNonCRF==1).idx);

currDataToSortBy=nanmean(currRateData(:,36:48),2);
[res, resIdx]=sort(currDataToSortBy);
sortedRateData=[currRateData([resIdx],:)];
sortedBurstData=[currBurstData([resIdx],:)];
sortedUnitsIdx=[currUnitIdx([resIdx],:)];
SORTbyLightOut(2).dataType='NonCRF';
SORTbyLightOut(2).sortedIdx=sortedUnitsIdx;
SORTbyLightOut(2).sortedRateData=sortedRateData;
SORTbyLightOut(2).sortedBurstData=sortedBurstData;

% end
%% SORTbyLightOut, not create and graph PLOTdata
close all
PLOTdataNonCRF=struct();
spaceRow=NaN(1,size(SORTbyLightOut(1).sortedRateData,2));
rateData=[SORTbyLightOut(1).sortedRateData;spaceRow;SORTbyLightOut(2).sortedRateData];
PLOTdataNonCRF.rateData=rateData;

dataToPlot=PLOTdataNonCRF.rateData;
[nUnits, nBinsData]=size(dataToPlot);

hourSec=3600; %60 sec * 60 min
binsize=300;
nBins=4*hourSec/binsize;%?


tit='CRF vs Non-CRF Normalized Firing Rates';
hf=figure('name',tit);
hold on;

hp=pcolor(dataToPlot);
a=gca;
axis tight
view(2)
% set(hp,'EdgeColor','k','lineWidth',0.25)
set(hp,'EdgeColor','non','lineWidth',0.25)

title(tit)
ylabel('Unit#','fontSize',10,'fontWeight','bold');
xlabel('Time(min)','fontSize',10,'fontWeight','bold');



%%Set x-axis label based on binsize and showing hours
xlim([1 nBins])
xt=[1,linspace(hourSec/binsize,4*hourSec/binsize,4)];%+1;
set(gca,'XTick',xt)
% h=get(gca,'XTick');
xlabels=[0:hourSec:4*hourSec]/60;
set(gca,'XTickLabel',xlabels);


%%Set y-axis label so the label is mid-bin
%  set(gca,'YTick',(1:nUnits)+0.5,'ticklength',[0 0]);
% set(gca,'YTick',(1:nUnits),'ticklength',[0 0]);
% set(gca,'YTick',(1:nUnits)+0.5,'ticklength',[0 0]);


% a = get(gca,'YTickLabel');
% set(gca,'YTickLabel',[],'fontsize',8)
% set(gca,'YTickLabel',yTickNames,'fontsize',8)
% yt=get(gca,'YTick');
%

%Create and label colorbar
colormap('jet')
c=colorbar('colormap', jet);

hf=gcf;
ha=gca;
%Calcualte ideal colorbar axis
% cbarCenter=mean(nanmedian(dataToPlot,1));
%% Find the max min and std for determinin caxis
[nUnits, nBins]=size(dataToPlot);
minList=min(dataToPlot,[],2);
maxList=max(dataToPlot,[],2);
stdList=std(dataToPlot,[],2);

%%Calculate desired limits based on properties
cMeanLimLow=nanmean(minList)-(2*nanmean(stdList));
cMeanLimHi=nanmean(maxList)+(2*nanmean(stdList));
caxPlot=[cMeanLimLow, cMeanLimHi];
caxis(ha,caxPlot)
% caxis(hp,caxPlot)
%Create label for colorbar
ylabel(c,'Normalized Firing Rate Z','fontSize',10,'fontWeight','bold');




%% Add percSpikesInBurstsBinned to SORTtracker;
% listLightTypes=fieldnames(SORTtracker)
% for l=1:length(listLightTypes)
%     currLightType=listLightTypes{l};
%
%     listLickTypes=fieldnames(SORTtracker.(currLightType))
%     for k=1
%         currLickType=listLickTypes{k};
%
%         currIdxMat=SORTtracker.(currLightType).(currLickType).sortedData.sortedRateDataIdx;
%
%         for c=1:size(currIdxMat,1)
%
%             currQ=currIdxMat{c}(1);
%             currU=currIdxMat{c}(2);
%
%
%
%         end
%     end
% end
%     close all




% fprintf('Finished. Now running plotNormFiringFromSORTtracker_V2WIP.m \n \n');
% plotNormFiringFromSORTtracker_V3WIP
% lineList{1}={':k','-g',':k'};
% lineList{2}={':k','-r',':k'};
% sortFields=fieldnames(SORTtracker);
% for s=1:length(sortFields)
%
%     currLickType=sortFields{s};
%
%
%     figure('name',currLickType)
%     set(gcf,'units','normalized','pos',[0.25 0.25 0.5 0.25]);
%
%
%
%     %normalized firing
%     subplot(1,2,1);
%     hold on;
%     tit=sprintf('Normalized Firing Rate - %s',currLickType);
%     title(tit);
%     for d=1:length(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit)
%         [meanToPlot,posSEM,negSEM]=sem(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit(d).dataSplitSortedMat,1);
%         plot(posSEM,lineList{d}{1});
%         plot(meanToPlot,lineList{d}{2},'DisplayName','Average Data','lineWidth',2);
%         plot(negSEM,lineList{d}{3});
%         axis tight
%     end
%     set(gca,'ylim',[-5 10])
hold off
%
%     %pecent Spikes in bursts
%     subplot(1, 2, 2);
%     tit=sprintf('PercSpikesInBursts - %s',currLickType);
%     title(tit);
%     hold on
%     for d=1:length(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit)
%         [meanToPlot,posSEM,negSEM]=sem(SORTtracker.(currLightType).(currLickType).sortedData.dataSplit(d).percSpikesInBursts,1);
%         plot(posSEM,lineList{d}{1});
%         plot(meanToPlot,lineList{d}{2},'DisplayName','Average Data','lineWidth',2);
%         plot(negSEM,lineList{d}{3});
%         %     hold off
%         axis tight
%     end
%     set(gca,'ylim',[0 100])
%     hold off
%
%
% end
% % end
% % end



clearCRFdata


SORTtracker_SplitByRateChange=SORTtracker;
% clearvars h* curr* split* a c add* bin* c cax* cluster* cMean* comb* concat* dataSplit lick* light* maxlist slope searchFor sNonCRF rate* res* sorted* tit u Q *label* std* dataTo* intercept max* min* med* nBin* nUnit* p  s sCRF xt zScored* spaceRow *ToAdd o