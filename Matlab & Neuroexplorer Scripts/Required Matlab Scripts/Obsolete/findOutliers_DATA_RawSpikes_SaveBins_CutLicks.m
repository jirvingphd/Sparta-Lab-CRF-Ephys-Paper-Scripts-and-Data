%findDATAoutliersFromSpikes.m

% OUTLIERSfull=struct();
varsAtStart=[who];

fprintf('Running nexDATAcountUnitsFinal.\n');
nexDATAcountUnitsFinal
%% Now use COUNTS to process data
OUTLIERSfull=struct();
SPIKES=struct();
LICKS=struct();
% CORR=struct();

dataTypeNames={'lightLick'}; %only runs on the light - lick categories since will be removing OUTLIERSfull of same type
d=1;
% for d=1:length(dataTypeNames)
currDataType= dataTypeNames{d};
lightTypes=fieldnames(COUNTS.(currDataType));

for l=1:length(lightTypes)
    currLightType=lightTypes{l};
    
    lickTypes=fieldnames(COUNTS.(currDataType).(lightTypes{l}));
    
    for k=1:length(lickTypes)
        currLickType=lickTypes{k};
        
        %             currIdxMat=COUNTS.(currDataType).(lightTypes{l}).(lickTypes{k}).index;
        %             currNumUnits=COUNTS.(currDataType).(lightTypes{l}).(lickTypes{k}).count;
        
        currIdxMat=COUNTS.(currDataType).(currLightType).(currLickType).index;
        currNumUnits=COUNTS.(currDataType).(currLightType).(currLickType).count;
        
        combinedDataMat=NaN(currNumUnits,48); %was 50
        %             combinedDataMat=[];
        
        r=1;
        currDataQUmat=[];
        
        for c=1:length(currIdxMat)
            
            currQ=currIdxMat{c}(1);
            currU=currIdxMat{c}(2);
            currDataQUmat(c,:)=[currQ, currU];
            currDataToAdd=NaN(1,48);
            %% Realized I need to run the binned data/interval removal scripts from nexPrep_forNormFiringFigs
            
            
            %%GET DIDSessionInts in DATA.fileinfo
            goodInts=[];
            for j=1:length(DATA(currQ).fileinfo.intervals)
                checkCurrInt=DATA(currQ).fileinfo.intervals(j);
                if strcmp(checkCurrInt.intName,'DIDSessionInts')>0
                    goodInts=DATA(currQ).fileinfo.intervals(j).intTimes;
                end
            end
            if isempty(goodInts)
                error(sprintf('Could not find DIDSessionInts at Q=%d u=%d',Q,u))
            end
            %
            
            %%Get cutData from my cutBinTimesGoodInts using units original timestamps.
            binsize=300;
            timestamps=DATA(currQ).units(currU).ts;
            cutData=[]; currDataToAdd=[];
            
            %Send in current cells ts, the binsize in seconds, and the intervals to
            %             [cutData,  cutBins, binnedData,  spikeTimebins,  tsBinsToKeep,  tsBinsIdx]=cutBinTimesGoodInts(timestamps,binsize,goodInts);%,spikeTimebins)
            [cutDataCounts,  cutBins, binnedData,  spikeTimebins,  tsBinsToKeep,  tsBinsIdx]=cutBinTimesGoodInts(timestamps,binsize,goodInts);%,spikeTimebins)
            
            % Add new unit's cut spike data combinedDataMat (for finding OUTLIERSfull)
            
            currDataToAdd=NaN(1,48);
            cutData=cutDataCounts./binsize;
            currDataToAdd(1:length(cutData))=cutData; %add to combinedDataMat AND SPIKES...cutSpikeRate
            
            %THIS IS WHERE LICK TYPE DATA MATRIX IS COMPLETE
            combinedDataMat(c,1:48)=currDataToAdd(1:48);%THIS LINE MUST BE DIFFERENT TO SAVE RAW
            combinedDataMatRawSAVE=combinedDataMat;
            
            OUTLIERSfull.(currLightType).(currLickType).rawData= combinedDataMatRawSAVE;
            OUTLIERSfull.(currLightType).(currLickType).binsRaw= cutBins;
            
            
            
            %SAVE TO SPIKES structure to compare to LICKS
            SPIKES(currQ).units(currU).spikeTimes=[]; %timestamps;
            SPIKES(currQ).units(currU).cutSpikeRate=currDataToAdd;
            SPIKES(currQ).units(currU).cutSpikeCounts=cutDataCounts;
            SPIKES(currQ).units(currU).cutBinEdges=cutBins;
            SPIKES(currQ).units(currU).uncutSpikes=binnedData;
            SPIKES(currQ).units(currU).uncutBinEdges=spikeTimebins;
            SPIKES(currQ).units(currU).binsToKeep=tsBinsToKeep;
            SPIKES(currQ).units(currU).tsBinsIdx=tsBinsIdx;
            SPIKES(currQ).units(currU).goodDIDints=goodInts;
            SPIKES(currQ).units(currU).lightType=currLightType;
            SPIKES(currQ).units(currU).lickType=currLickType;
            %                 currDataQUmat(c,:)=[currQ, currU];
            
            %% ADDING IN LICKS TO USE TIMEBINS FROM SPIKES (uncutBinEdges)
            lickTimes= DATA(currQ).fileinfo.events.EventLick;
            
            cutLicks=[]; currLickDataToAdd=[]; cutLickRate=[];
            
            %Send in current cells ts, the binsize in seconds, and the intervals to
            [cutLicks, cutLickBins, binnedLickData, lickTimebins, binsToKeep,tsLickBinsIdx]= cutBinTimesGoodInts(lickTimes, binsize, goodInts,spikeTimebins); %%IMPORTANT TO FEED IN TIMEBINS FROM SPIKES
            
            % Add new unit's cut lick COUNTS data to a 48bin NaN vector
            cutLickDataToAdd=NaN(1,48);
            cutLickDataToAdd(1:length(cutLicks))=cutLicks;
            % Add new unit's cut lick RATE data to a 48bin NaN vector
            cutLickRateDataToAdd=NaN(1,48); %             cutLickRate=cutLicks./binsize;
            cutLickRateDataToAdd(1:length(cutLicks))= cutLicks./binsize;
            
            cutLickDataToAdd=cutLickDataToAdd(1:48);
            cumSumLicks=cumsum(cutLickDataToAdd,'omitnan');
            
            LICKS(currQ).lickTimes=lickTimes;
            LICKS(currQ).cutLickCounts=cutLickDataToAdd(1:48);
            LICKS(currQ).cutLickRate=cutLickRateDataToAdd(1:48); % changed to now always be 46 long
            
            LICKS(currQ).cumSumLicks=cumSumLicks;
            %             fprintf('maybe run cumsum on *DataToAdd\n')
            
            LICKS(currQ).cutBinEdges=cutLickBins;
            LICKS(currQ).uncutLicks=binnedLickData;
            LICKS(currQ).uncutBinEdges=lickTimebins;
            LICKS(currQ).binsToKeep=binsToKeep;
            
            LICKS(currQ).tsBinsIdx=tsLickBinsIdx;
            LICKS(currQ).goodDIDints=goodInts;
            
        end
        
        
        %% Now outlier renoval as in nexPrep_makeSORTclustersv3_remOutsPt1%%%%%%%%%%%%%%%%%%%%%%%
        
        %%25%+NaN REMOVAL
        %First,verify that each row of data is no more than 25% NaN
        %             data=NaN(size(currDataQUmat,1), 48);
        data =combinedDataMat;
        dataIdx = currDataQUmat;
        
        if size(data,1)~=size(dataIdx)
            error('The index for the current data does not have the same number of units as the data matrix.')
        end
        
        delData=[]; testData=[];
        for d=1:size(data,1)-1
            
            testNaN=[]; tooNan=[]; percNaN=[];
            testNaN=isnan(data(d,:));
            tooNan=find(testNaN);
            
            percNaN=length(tooNan)/length(testNaN);
            if percNaN >0.25
                %         data(d,:)=[];
                delData=[delData, d];
            end
        end
        
        %%SAVE TOO-NAN IDX
        OUTLIERSfull.(currLightType).(currLickType).originalQuIdx=currDataQUmat;
        OUTLIERSfull.(currLightType).(currLickType).nanDataRows=delData;
        
        %%REMOVE NAN LINES USING IDX
        data(delData(:),:)=[];
        dataIdx(delData(:),:)=[];
        combinedDataMat(~any(~isnan(data),2),:)=[];%removes any lines filled with NaN
        
        
        OUTLIERSfull.(currLightType).(currLickType).postNanQuIdx=dataIdx;
        if isempty(data)
            %             fprintf('There was no combined Data for %s , %s.\n',currLightType,currLickType)
            continue
        end
        %%%SAVE OUTPUT
        testData= data;
        testDataIdx=dataIdx;
        
        %% OUTLIER REMOVAL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clearvars TF* T1 T2 cleaned I J loc cleaned* comb*
        
        %%%OUTLIER FIND & FILL 1 (within rows)
        [cleanedData1, TF1, lower1, upper1,center1]=filloutliers(testData(:,1:48),'linear','movmedian',6,2); %48 bc 48 =4 hours
        OUTLIERSfull.(currLightType).(currLickType).remSessOutTF1=TF1;
        T1=find(TF1);
        fprintf('# outlier timebins: light-%s, lick-%s: \n   Pass 1:  %d\n',currLightType,currLickType,length(T1));
        
        %%%OUTLIER FIND 2 (column wise (by time bins))
        [TF2]=isoutlier(cleanedData1,'mean'); %operates on each column separately
        T2=find(TF2);
        fprintf('   Pass 2: %d \n\n\n',length(T2));
        
        %save the location of the OUTLIERSfull in subscripts
        [I, J]=find(TF2>=1);
        [loc(:,1),loc(:,2)]=find(TF2>0);
        
        OUTLIERSfull.(currLightType).(currLickType).remTimebinOutsTF2=TF2;
        
        outlierRows=[];
        outlierRows=unique(I); %find all rows that contain OUTLIERSfull
        
        cleanedData1_OUTLIERSfullNaN=[];
        cleanedData1_OUTLIERSfullNaN=cleanedData1;
        cleanedData1_OUTLIERSfullNaN(TF2==1)=NaN; %This is where entire CRF.inhibited. #3 is problem and becomes NaN
        
        
        %%Insert NaN removal again
        delData=[]; testData=[];
        data=cleanedData1_OUTLIERSfullNaN;
        for d=1:size(data,1)-1
            
            testNaN=[]; tooNan=[]; percNaN=[];
            testNaN=isnan(data(d,:));
            tooNan=find(testNaN);
            
            percNaN=length(tooNan)/length(testNaN);
            if percNaN >0.25
                %         data(d,:)=[];
                delData=[delData, d];
            end
        end
        
        %%SAVE TOO-NAN IDX
        OUTLIERSfull.(currLightType).(currLickType).preNanDataRows2QuIdx=dataIdx;
        OUTLIERSfull.(currLightType).(currLickType).nanDataRows2=delData;
        
        %%REMOVE NAN LINES USING IDX
        data(delData(:),:)=[];
        dataIdx(delData(:),:)=[];
        %         tempCombData
        combinedDataMat=data;
        %         nanFinalIdx=dataIdx;
        combinedDataMat(~any(~isnan(data),2),:)=[];%removes any lines filled with NaN
        dataIdx(~any(~isnan(data),2),:)=[];%removes any lines filled with NaN
        
        %%% OUTLIER REPLACEMENT 2 (across row OUTLIERSfull, filled via row)
        currData=combinedDataMat;
        [currDataFilled]=fillmissing(currData,'linear',2);
        
        %%SAVE OUTLIERS DATA 
%[i]     %NOTE: The data filled in here will be used for all subsequent  analysis. 
         %to change data used for normalized firing and prism, change what is filled in OUTLIERSfull...cleanedData
        OUTLIERSfull.(currLightType).(currLickType).cleanedData= currDataFilled; 
        OUTLIERSfull.(currLightType).(currLickType).cleanedDataIdx= dataIdx;
        
    end
end
clearvars curr* temp* data*


%% Distribute back to new DATA.units.outliers
lightTypes=fieldnames(OUTLIERSfull);

for l=1:length(lightTypes)
    currLightType=lightTypes{l};
    
    lickTypes=fieldnames(OUTLIERSfull.(currLightType));
    
    for k=1:length(lickTypes)
        currLickType=lickTypes{k};
        
        
        clearvars TF* nanData* startFullIdx goodDataIdx prepNanQuIdx
        
        if isempty(OUTLIERSfull.(currLightType).(currLickType).originalQuIdx)
            continue
        end
        
        startFullIdx=OUTLIERSfull.(currLightType).(currLickType).originalQuIdx;
        nanDataRows1=OUTLIERSfull.(currLightType).(currLickType).nanDataRows;
        %         goodDataIdx=OUTLIERSfull.(currLightType).(currLickType).postNanQuIdx;
        
        TF1=OUTLIERSfull.(currLightType).(currLickType).remSessOutTF1;
        TF2=OUTLIERSfull.(currLightType).(currLickType).remTimebinOutsTF2;
        preNan2QuIdx=OUTLIERSfull.(currLightType).(currLickType).preNanDataRows2QuIdx;
        nanDataRows2=OUTLIERSfull.(currLightType).(currLickType).nanDataRows2;
        
        goodDataIdx=OUTLIERSfull.(currLightType).(currLickType).cleanedDataIdx;
        spikeRatesCleanMat=OUTLIERSfull.(currLightType).(currLickType).cleanedData;
        spikeRatesUncleanMat=OUTLIERSfull.(currLightType).(currLickType).rawData;
        %%%%
        
        %% Find missing units that were removed and make sure give them outliers field
        badUnitsToFill=[];
        badUnitsToFill=setdiff(startFullIdx,goodDataIdx,'rows');
        for b=1:size(badUnitsToFill,1)
            currQ=badUnitsToFill(b,1);
            currU=badUnitsToFill(b,2);
            currUnitOuts.isTooNaN=1;
            currUnitOuts.TF1=[];
            currUnitOuts.TF2=[];
            %             currUnitOuts.TF1=ones(1,size(TF1,2)); %fill all 1's
            %             currUnitOuts.TF2=ones(1,size(TF2,2));
            currUnitOuts.verifyLight=currLightType;
            currUnitOuts.verifyLick=currLickType;
            currUnitOuts.verifyQuIdx=[currQ,currU];
            DATA(currQ).units(currU).include=0;
            DATA(currQ).units(currU).outliers=currUnitOuts;
        end
        %                 indexToLoop=startFullIdx;
        
        %% LOOP THROUGH ALL ROWS OF EACH TYPE AND DISTRIBUTE DATA TO Q U
        c=1;
        indexToLoop=goodDataIdx;
        while c<=size(indexToLoop,1)
            
            currUnitOuts=struct();
            
            currQ=indexToLoop(c,1);
            currU=indexToLoop(c,2);
            
                %%% THIS PHASE OF PROCESSING WAS REMOVED PER
                %               REQUEST OF DENNIS AND SONIA? or just not needed.  (pretty sure)
                %             %Check if currUnit is included in nanDataRows1
                %             if isempty(nanDataRows1)==0 || isempty(nanDataRows2)==0
                %                 badUnitNan1=[];
                %                 badUnitNan2=[];
                %
                %                 if isempty(nanDataRows1)==0
                %                     for ii=1:length(nanDataRows1)
                %
                %                         [badUnitNan1]=startFullIdx(nanDataRows1(ii),:);
                %
                %                         if badUnitNan1(1)==currQ && badUnitNan1(2)==currU
                %                             currUnitOuts.isTooNaN=1;
                %                             currUnitOuts.TF1=[];
                %                             currUnitOuts.TF2=[];
                %                             currUnitOuts.verifyLight=currLightType;
                %                             currUnitOuts.verifyLick=currLickType;
                %                             currUnitOuts.verifyQuIdx=[currQ,currU];
                %                             DATA(currQ).units(currU).include=0;
                %
                %                             DATA(currQ).units(currU).outliers=currUnitOuts;
                %                             c=c+1;
                %                             break;
                %                         end
                %
                %                     end
                %                 end
                %
                %                 jj=1;
                %                 %Check if currUniti
                %                 if isempty(nanDataRows2)==0
                %                     badUnitNan2=[];
                %                     for jj=1:length(nanDataRows2)
                %                         [badUnitNan2]=preNan2QuIdx(nanDataRows2(jj),:);
                %                         if badUnitNan2(1)==currQ && badUnitNan2(2)==currU
                %                             currUnitOuts.isTooNaN=1;
                %                             currUnitOuts.TF1=[];
                %                             currUnitOuts.TF2=[];
                %
                %                             currUnitOuts.verifyLight=currLightType;
                %                             currUnitOuts.verifyLick=currLickType;
                %                             currUnitOuts.verifyQuIdx=[currQ,currU];
                %                             DATA(currQ).units(currU).outliers=currUnitOuts;
                %                             c=c+1;
                %                             %                             break;
                %                             break;
                %                         end
                %                     end
                %                 end
                %             end
                %         end
            
            currUnitOuts.isTooNaN=0; %Bad units were already filled in previously above with isTooNaN=1 
            currUnitOuts.TF1=TF1(c,:);
            currUnitOuts.TF2=TF2(c,:);
            currUnitOuts.verifyLight=currLightType;
            currUnitOuts.verifyLick=currLickType;
            currUnitOuts.verifyQuIdx=[currQ,currU];
            
            %%%SAVE THE RESULTS TO CURRENT UNIT IN DATA
            DATA(currQ).units(currU).outliers=currUnitOuts;
            
            %% FILLS IN DATA(Q).units(u).spikeRate with outlier-removed data from structure: "newSpikeRateDATA"
            % FILLS IN CLEANED VERSION OF SPIKE RATES (newSpikeRateDATA.ratesClean) CALCULATED AT START OF SCRIPT AND CV
            DATA(currQ).units(currU).spikeRate=[];
            newSpikeRateDATA=struct();
            newSpikeRateDATA.name=[];
            newSpikeRateDATA.ratesRaw=[];
            newSpikeRateDATA.binsRaw=[];
            newSpikeRateDATA.ratesClean=[]; %NEW
            newSpikeRateDATA.CV=[];
            newSpikeRateDATA.meanISI=[];
            newSpikeRateDATA.avgRateFullSession=[];
            newSpikeRateDATA.avgRateByHour=[];
            
%[i]        % Take group matrices of spikeRates to separate by unit
            spikeRatesCleanMat=OUTLIERSfull.(currLightType).(currLickType).cleanedData;
            spikeRatesUncleanMat=OUTLIERSfull.(currLightType).(currLickType).rawData;
            spikeRatesCutBins=OUTLIERSfull.(currLightType).(currLickType).binsRaw;
            
            %Separate unit's row of data
            newSpikeRateDATA.ratesClean      =    spikeRatesCleanMat(c,:);
            newSpikeRateDATA.ratesRaw       =     spikeRatesUncleanMat(c,:);
            newSpikeRateDATA.binsRaw        =     spikeRatesCutBins;
            
            % Adding in saving to SPIKES for corrSPIKESandLICKS
            SPIKES(currQ).units(currU).ratesClean=spikeRatesCleanMat(c,:);
            SPIKES(currQ).units(currU).ratesRaw=spikeRatesUncleanMat(c,:);
            SPIKES(currQ).units(currU).binsRaw=spikeRatesCutBins;
            
            
%[i]        % Exclude units that do not have data for at least 75% of timebins 
            if (length(spikeRatesCutBins)/length(spikeRatesUncleanMat(c,:)))<0.75
                DATA(currQ).units(currU).include=0;
            end
            

            %% CV CALCULATION
            
            %get timestamps
            currTimes=DATA(currQ).units(currU).ts;
            
            % Get DIDSessionInts
            searchFor='DIDSessionInts';
            currTestInt=cell2mat( arrayfun(@(x)  strcmp(x.intName,searchFor), DATA(currQ).fileinfo.intervals,'UniformOutput',false));
            currGoodInt=DATA(currQ).fileinfo.intervals(currTestInt==1).intTimes;
            
            % Filter out non DIDSession spikes 
            currGoodSpikes=cutTimesGoodIntsFast(currTimes,currGoodInt);
            
            %Calculate average ISIs
            currISImat=[];
            for i=2:length(currGoodSpikes)
                currISImat(i)=currGoodSpikes(i)-currGoodSpikes(i-1);
            end
            currMeanISI=nanmean(currISImat);
            
            %Calculate CV
            currCV=std(currISImat)/currMeanISI;
            
            %Fill in results
            newSpikeRateDATA.meanISI=currMeanISI;
            newSpikeRateDATA.CV=currCV;
            
            %% Calc avgRateFullSession and avgRateByHour
            hourlyAvgRates=struct();
            hourSec=3600;
            hoursToAvg=4;
            timeBlockNames={'Hour1','Hour2','Hour3','Hour4'};
            timeBlockBinsSec={[0 3600],[3600 7200],[7200 10800],[10800 14400]};
            
            currBins=spikeRatesCutBins;
            currData=spikeRatesCleanMat(c,:);
            newSpikeRateDATA.avgRateFullSession=nanmean(currData);
            
            for h=1:hoursToAvg
                includeCurrHour=[];
                avgRateCurrHour=[];
                
                %Get starting and ending time of current hour(h)
                intStart=timeBlockBinsSec{h}(1);
                intEnd=timeBlockBinsSec{h}(2);
                
                
                %Get index of cells that pass interval test and filter
                %their data into new matrix
                indFiltBinsByHour=(currBins>=intStart).*(currBins<(intEnd));
                filtCurrData=currData(indFiltBinsByHour==1);
                filtCurrBins=currBins(indFiltBinsByHour==1);
                
                % Save hourly averages in structure
                hourlyAvgRates(h).hourNum=h;
                hourlyAvgRates(h).avgRate=nanmean(filtCurrData);
                
            end
            
            %Fill in avgRateByHour sub-structure in newSpikeRateDATA
            newSpikeRateDATA.avgRateByHour=hourlyAvgRates;
            
            %Fill in current units data alone into DATA(Q).units(u)
            DATA(currQ).units(currU).spikeRate=newSpikeRateDATA;
            
            % Increment c to select the next unit's data in matrix.
            c=c+1;
        end
    end
    
    
    
end
clearCRFdata

save_data = input('Initial phase of spike analysis complete...\nSave data file now?(y/n):\n','s');
if strcmpi(save_data,'y')
    savefilename = 'DATA-OutliersRemoved_NoBURSTS.mat';
    save(savefilename, '-v7.3')
    fprintf('Data was saved as:\n %s',savefilename)
% else
%     fprintf('Data was not saved to .mat file. \n Please consider saving data now.')
end

% fprintf('Initial phase of spike analysis complete.\n Next phase is Burst Analysis with NeuroExplorer.\n Run makeUnitTimestampVarsForAll.m\n')
% clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* SPIKE* CORR* LICKS* corr* SPIKES
clearCRFdata
fprintf('\nNext analysis phase is Burst Analysis with NeuroExplorer.\n Run makeUnitTimestampVarsForAll.m\n')

