%% Fields to Make Sure I Fill InWith This Script;
% BURSTunits(Q).units(u).avgBurstDuration;
% BURSTunits(Q).units(u).avgMeanFreqInBurst;
% BURSTunits(Q).units(u).avgMeanISIinBurst;
% BURSTunits(Q).units(u).avgPeakFreqInBurst;
% BURSTunits(Q).units(u).avgSpikesInBurst;
%
% BURSTunits(Q).units(u).burstingByHour.BurstDuration.(Hour1-Hour4);
% BURSTunits(Q).units(u).burstingByHour.burstsPerSecond.(Hour1-Hour4);
% BURSTunits(Q).units(u).burstingByHour.meanFreqInBurst.(Hour1-Hour4);
% BURSTunits(Q).units(u).burstingByHour.MeanISIinBurst.(Hour1-Hour4);
% BURSTunits(Q).units(u).burstingByHour.PeakFreqInBurst.(Hour1-Hour4);
% BURSTunits(Q).units(u).burstingByHour.percSpikesInHour.(Hour1-Hour4);
% BURSTunits(Q).units(u).burstingByHour.SpikesInBurst.(Hour1-Hour4);
%% Specify what fill methods you want to you use replaceBinnedOutliers:
% options are 0: for JUST removal; 'nearest': for nearest nonmissing data;
%'linear': linear interpolation; 'pchip': shape retaining cubewise...?


fillMethod1='0';
fillMethod2='0';
%
% fillMethod1='nearest';
% fillMethod2='nearest';

if exist('optionsOutliers','var')==0
    optionsOutliers=struct();
end
optionsOutliers.fillMethod1=sprintf(fillMethod1);
optionsOutliers.fillMethod2=sprintf(fillMethod2);
% fill1=num2str(fillMethod1)
fprintf('Non-spike data outliers will be replaced using 1) %s 2) %s.\n',fillMethod1,fillMethod2);

%% start with parts of calcPercBurstsByBins
varsAtStart=who;

binsize=300;
hourSec=3600;
hoursToAvg=4;

%constants from nexscript
timeBlockNames={'Hour1','Hour2','Hour3','Hour4'};
timeBlockBinsSec={[0 3600],[3600 7200],[7200 10800],[10800 14400]};

% percSpikesByHour=struct();
% percSpikesByHour.(timeBlockNames{h}).totalSpikesInHour=[];
% percSpikesByHour.(timeBlockNames{h}).percSpikesInHour=[];
ERRoutliersEmpty=[];
ERRoutliersMissing=[];
ERRmissPercBurst=[];

x=1; y=1;
%% Calculate and fill in spikes in bursts statistics
for Q=1:length(DATA)
    if DATA(Q).fileinfo.include==0
%         fprintf('Skipping 
        continue;
    end
    for u=1:length(DATA(Q).units)
        if DATA(Q).units(u).include==0
            fprintf('DATA(%d).units(%d).include==0',Q,u)
            continue
        end
        percSpikesInBurstByHour=struct();
        
        %Find and take DIDSessionInts
        currDIDSessInts = [];
        allfile_int=[];
        for j=1:length(DATA(Q).fileinfo.intervals)
            checkCurrInt=DATA(Q).fileinfo.intervals(j);
            if strcmpi(checkCurrInt.intName,'DIDSessionInts')>0
                currDIDSessInts=DATA(Q).fileinfo.intervals(j).intTimes;
            end
            if strcmpi(checkCurrInt.intName,'AllFile')>0
                allfile_int=DATA(Q).fileinfo.intervals(j).intTimes;
            end
        end
        if isempty(currDIDSessInts)==1 && isempty(allfile_int)==0
            currDIDSessInts =     allfile_int;
            fprintf('DIDSessionInts Not found in DATA(%d). Using AllFile interval instead.',Q)
        end
        
        %     end
        
        %Empty vars and get the timestamps and bursting intervals from DATA
        %and BURSTS
        currBurstInts=[];       currSpikesRaw=[];        currBurstInts=[];        allSpikes=[];        binCountsAll=[];
        
        %         if DATA(Q).fileinfo.include==0
        %             continue
        %         end
        %% Verify and retrieve outliers and burst timestamps
        if isfield(DATA(Q).units(u),'outliers')==0
            
            warning('DATA(%d).units(%d) is missing outliers field.\n',Q,u)
            ERRoutliersMissing=[ERRoutliersMissing; Q u];
            DATA(Q).units(u).include=0;
            fprintf('DATA(%d).units(%d).include==0',Q,u)
            continue;
            
        elseif isempty(DATA(Q).units(u).outliers)
            
            warning('DATA(%d).units(%d) has empty outliers.\n',Q,u)
            ERRoutliersEmpty=[ERRoutliersEmpty; Q u];
            DATA(Q).units(u).include=0;
            fprintf('DATA(%d).units(%d).include==0',Q,u)
            fprintf('think of an alternative way to deal with too NaN units who do not have outliers field!.\n')
            continue
            
        end
        
        currOutliers=DATA(Q).units(u).outliers;
        currSpikesRaw=DATA(Q).units(u).ts;
        
        
        % Spikes Previously Filtered (Nex?
        currBurstSpikes=BURSTunits(Q).units(u).BurstSpikes;
        currNonBurstSpikes=BURSTunits(Q).units(u).NonBurstSpikes;
        
        currBurstIntStart=BURSTunits(Q).units(u).BurstStart;
        currBurstIntEnd=BURSTunits(Q).units(u).BurstEnd;
        currBurstInts=horzcat(currBurstIntStart,currBurstIntEnd);
        
        
        %% Now Calculate Desired Data:
        %Calcualte bin counts for ALL good spikes
        if isempty(currBurstInts)
            continue
        end
        
        %% CALCULATE PERCENT SPIKES IN BURSTS
        % Use the bincounts from my own cutBinTimesGoodInts to calulate percent spikes in bursts using bincounts
        allSpikes=currSpikesRaw;
        [cutData, cutBins, binCountsAll, timebinsAll,binsCutIdxAll]= cutBinTimesGoodInts(allSpikes, binsize, currDIDSessInts);
        
        burstSpikes=currBurstSpikes;
        [cutBurstSpikes, cutBurstSpikesBins, binCountsBurstSpikes, timebinsburstSpikes,binsCutIdxBurstSpikes]= cutBinTimesGoodInts(burstSpikes, binsize, currDIDSessInts,timebinsAll); %added timebinsAll
        
        % nonBurstSpikes=currNonBurstSpikes;
        % [cutNonBurstSpikes, cutNonBurstSpikesBins, binCountsNonBurstSpikes, timebinsNonBurstSpikes,binsCutIdxNonBurstSpikes]= cutBinTimesGoodInts(nonBurstSpikes, binsize, currDIDSessInts,timebinsAll);%added timebinsAll
        
        %now use counts to calc percent spikes in bursts
        allPercSpikesInBursts=binCountsBurstSpikes./binCountsAll(1:length(binCountsBurstSpikes))*100;
        cutPercSpikesInBursts=cutBurstSpikes./cutData*100;
        
        %REPLACING Inf and NaN with 0
        allPercSpikesInBursts(isnan(allPercSpikesInBursts))=0;
        allPercSpikesInBursts(isinf(allPercSpikesInBursts))=0;
        cutPercSpikesInBursts(isnan(cutPercSpikesInBursts))=0;
        cutPercSpikesInBursts(isinf(cutPercSpikesInBursts))=0;
        
        
        %Cut out additional unwanted bins that have a starting time equal
        %to session length-binsize
        cutPercSpikesInBursts=cutPercSpikesInBursts(cutBins<14400);
        cutBins=cutBins(cutBins<14400);
        
        
        %Save percent spikes in bursts data, bins, and idx
        currUnitResults.percSpikesInBurstsFull=allPercSpikesInBursts;
        currUnitResults.percSpikesInBurstsBinEdges=timebinsAll(1:end-1);
        currUnitResults.percSpikesInBurstsBinIdx=binsCutIdxAll(1:end-1);
        
        currUnitResults.percSpikesInBurstsCut= cutPercSpikesInBursts;
        currUnitResults.percSpikesInBurstsCutBinEdges=cutBins;
        
        
        
        %% NOW REMOVE OUTLIER BINS AND REPLACE (MAYBE, 0,0=just remove)
        currDataToClean=cutPercSpikesInBursts;
        currOutliers=DATA(Q).units(u).outliers;
        
        try
            
            %             [cleanedCutData]=replaceBinnedOutliers(currDataToClean,currOutliers,'nearest','nearest');
            [cleanedCutData,include,outliersOut]=replaceBinnedOutliers(currDataToClean,currOutliers,fillMethod1,fillMethod2);
            if include==0
                DATA(Q).units(u).include=0;
                DATA(Q).units(u).outliers=outliersOut;
                DATA(Q).units(u).outliers.updated=1;
            end
        catch
            
            msg=sprintf('Error running replaceBinnedOutliers on DATA(%d).units(%d).\n',Q,u);
            warning(msg)
            
        end
        currUnitResults.percSpikesInBurstsCutClean=cleanedCutData;
        
        %% Fill in the fields of tempSpikesStruct that will be used in all subsequent burst calculations:
        tempSpikesStruct=struct();
        tempSpikesStruct.percSpikesInBursts.binnedMeans=currUnitResults.percSpikesInBurstsCut;
        tempSpikesStruct.percSpikesInBursts.binnedMeansClean= currUnitResults.percSpikesInBurstsCutClean;
        tempSpikesStruct.percSpikesInBursts.binnedMeansEdges= currUnitResults.percSpikesInBurstsCutBinEdges;%
        tempSpikesStruct.percSpikesInBursts.avg=nanmean(cleanedCutData);
        
        
        
        %% loop through hours to calculate hourly percent spikes in bursts
        burstingByHour=struct();
        
        for h=1:length(timeBlockBinsSec)
            
            intStart=timeBlockBinsSec{h}(1);
            intEnd=timeBlockBinsSec{h}(2);
            
            
            currBins=currUnitResults.percSpikesInBurstsCutBinEdges;
            currData=currUnitResults.percSpikesInBurstsCutClean;
            
            %Get index of cells that pass interval test
            indFiltBinsByHour=(currBins>=intStart).*(currBins<(intEnd));
            %             test(h).index=indFiltBinsByHour;
            filtCurrData=currData(indFiltBinsByHour==1);
            filtCurrBins=currBins(indFiltBinsByHour==1);
            
            burstingByHour.(timeBlockNames{h})=nanmean(filtCurrData);
            
        end
        
        tempSpikesStruct.percSpikesInBursts.burstingByHour=burstingByHour;
%         fprintf('BURSTunits(%d).units(%d).BURSTstats created.\n',Q,u)
        BURSTunits(Q).units(u).BURSTstats=tempSpikesStruct;
        BURSTunits(Q).units(u).outliers=currOutliers;
        
        clearvars temp*
        clearvars currUnitResults burstingByHour
        
    end %test
end %test
ERRmissPercBurst=[];



%% WANT TO HAVE THESE ALL BINNED AND CUT BY THE TIME GET TO HOURLY AVERAGES
statsToRun={'SpikesInBurst','MeanISIinBurst','PeakFreqInBurst','BurstDuration','meanFreqInBurst','BurstsPerSecond'};
% fprintf('Removed BurstsPerSecond from the script for now to produce excel faster.\n')

for Q=1:length(BURSTunits)
    if DATA(Q).fileinfo.include==0
        fprintf('Skipping DATA(%d) since include==0\n',Q)
        continue
    end
    %Find and take DIDSessionInts
    for j=1:length(DATA(Q).fileinfo.intervals)
        checkCurrInt=DATA(Q).fileinfo.intervals(j);
        if strcmp(checkCurrInt.intName,'DIDSessionInts')>0
            currDIDSessInts=DATA(Q).fileinfo.intervals(j).intTimes;
        end
    end
    
    
    for u=1:length(BURSTunits(Q).units)
        %                 filtSpikesBursts=spikesBursts(spikesBursts>intStart & spikesBursts<intEnd);
        
        % Extract the data to calculate binned averages from
        if DATA(Q).units(u).include==0
            fprintf('Skipping DATA(%d).units(%d), include==0.\n',Q,u)
            continue
        end
        
        
        tempBURSTbins=BURSTunits(Q).units(u).BURSTstats;

        if isfield(tempBURSTbins,'percSpikesInBursts')==0
            ERRmissPercBurst=[ERRmissPercBurst; Q u];
            fprintf('There was no percSpikesInBursts data for BURST(%d).units(%d),BURSTstats.\n',Q,u);
            DATA(Q).units(u).include=0;
            continue
        else
            tempBURSTbins.percSpikesInBursts=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts;
        end
        
        BurstDuration =BURSTunits(Q).units(u).BurstDuration;
        SpikesInBurst =BURSTunits(Q).units(u).SpikesInBurst;
        MeanISIinBurst =BURSTunits(Q).units(u).MeanISIinBurst;
        PeakFreqInBurst =BURSTunits(Q).units(u).PeakFreqInBurst;
        meanFreqInBurst = BURSTunits(Q).units(u).meanFreqInBurst;
        
        %% Use burstIntervals to get indices for binned data
        burstStartInts=BURSTunits(Q).units(u).BurstStart;
        %         if isempty(burstStartInts)
        %             continue;
        %         end
        
        %find which burst values belongs in which bin
        [cutData, cutBins, binCountsAll, timebinsAll,binsCutIdxAll,tsBinsIdx]= cutBinTimesGoodInts(burstStartInts, binsize, currDIDSessInts);
        
        
        %Do a loop for each bin's mean
        numBinsToLoop=unique(tsBinsIdx);
        %should maybe be numBinsToLoops=length(
        %         fprintf('Investigate hows tsBinsIdx is being used/looped versus numBinsToLoop to troubleshoot very long BurstDurations.\n\n')
        
        numBinsToLoop=numBinsToLoop(numBinsToLoop>0);
        
        %% Loop through stats to run for all other burst data binned averages
        for s=1:length(statsToRun)
            
            currStat=statsToRun{s};
            
            if strcmp(currStat,'BurstsPerSecond')>0
                %% Calculate Bursts per second from tsBinsIdx
                % currStat='BurstsPerSecond';
                burstRate=cutData./binsize;
                
                tempBURSTbins.(currStat).binnedMeans=burstRate;
                % tempBURSTbins.(currStat).binnedMeansEdges=cutBins;
                currDataToClean=burstRate;
            else
                
                
                currNexData=BURSTunits(Q).units(u).(currStat);
                %                 meanBinsData=[];
                
                %Generate the binned data equivalent of cutData
                %                 for n=1:length(numBinsToLoop)
                for n=1:length(timebinsAll)
                    %                     currBinIdxNum=numBinsToLoop(n);
                    currBinIdxNum=n;
                    meanBinsData(n)=nanmean(currNexData(tsBinsIdx==currBinIdxNum)); %essentially equivalent to binCountsAll
                end
                cutMeanBinsData=meanBinsData(binsCutIdxAll==1);
                
                %SAVE THE BINNED MEANS SO NEXT CALC HOURLY DATA
                tempBURSTbins.(currStat).binnedMeans=cutMeanBinsData;
                currDataToClean=cutMeanBinsData;
                
                
            end
            
            
            
            %%APPLY replaceBinnedOutliers to cutMeanBinsData, then calculate hour averages
            %currDataToClean is defined above
            currBins=cutBins;
            
            %             try
            currOutliers=DATA(Q).units(u).outliers;
            if currOutliers.isTooNaN==1
                DATA(Q).units(u).include=0;
                continue
            end
            %             catch
            %                 msg=warning('Missing DATA(%d).units(%d).outliers field.\n',Q,u);
            %             end
            
            
            %             try
            %             [cleanedCutData]=replaceBinnedOutliers(currDataToClean,currOutliers,'nearest','nearest');
            [cleanedCutData,include,outliersOut]=replaceBinnedOutliers(currDataToClean,currOutliers,fillMethod1,fillMethod2);
            if include==0
                DATA(Q).units(u).include=0;
                DATA(Q).units(u).outliers=outliersOut;
                DATA(Q).units(u).outliers.updated=1;
            end
            %             catch
            %
            %                 msg=sprintf('Error running replaceBinnedOutliers on DATA(%d).units(%d).\n',Q,u);
            %                 warning(msg)
            %
            %             end
            %             currUnitResults.percSpikesInBurstsCutClean=cleanedCutData;
            %             try
            %                 [cleanedCutData,include]=replaceBinnedOutliers(currDataToClean,currOutliers,fillMethod1,fillMethod2);
            %             catch
            %                 msg=sprintf('Error running replaceBinnedOutliers on DATA(%d).units(%d).\n',Q,u);
            %                 warning(msg)
            %             end
            
            
            
            tempBURSTbins.(currStat).binnedMeansClean=cleanedCutData;
            tempBURSTbins.(currStat).binnedMeansEdges=cutBins;
            tempBURSTbins.(currStat).avg=nanmean(cleanedCutData);
            
            %% now calculate hourly averages
            currData=cleanedCutData;
            tempBURSTbins.(currStat).burstingByHour=[];
            
            
            for h=1:length(timeBlockBinsSec)
                
                intStart=timeBlockBinsSec{h}(1);
                intEnd=timeBlockBinsSec{h}(2);
                
                
                %Get index of cells that pass interval test
                indFiltBinsByHour=(currBins>=intStart).*(currBins<(intEnd));
                %             test(h).index=indFiltBinsByHour;
                filtCurrData=currData(indFiltBinsByHour==1);
                filtCurrBins=currBins(indFiltBinsByHour==1);
                
                tempBURSTbins.(currStat).burstingByHour.(timeBlockNames{h})=nanmean(filtCurrData);
            end
            
        end
        
        % tempBURSTbins.percSpikesInBursts=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts;
        
        %Add burstsPerSecond? tempBURSTbins.
        
        BURSTunits(Q).units(u).BURSTstats=tempBURSTbins;
    end
end


varsAtEnd=[who];
varsNew=setdiff(varsAtEnd,varsAtStart);
clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* CORR* LICK* SPIKES
% 	clearvars(varsNew{:},'varsAtEnd','curr*','temp*','bin*','all*','cut*','time*','Q','u','x','y','clean*','-except','OUTLIERSfull','vars*','ERR*');