if exist('SORTtrackerCRF','var')==0
    SORTtrackerCRF=SORTtracker_SplitByRateChange.CRF;
end
copyNormFIringFull_spl={};
copyNormFIringFull_spl{1,1}='Time (min)';
timebins=[0:5:235];
copyNormFIringFull_spl(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
j=2;

sortFields=fieldnames(SORTtrackerCRF);

for s = 1:length(sortFields)
    currLickType=sortFields{s};
    
    for d=1:2
        currSplit=sprintf('split%d',d);

        % copy=SORTtrackerCRF.(curr.sortedData.sortedRateDataToPlot

        % 	copy=num2cell(T(:),2)
        %     	currCopy = num2cell(currData,size(currData));

        %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
        j=j+1;
    %     currDataMat=SORTtrackerCRF.NR.sortedData.sortedPercBurstDataToPlot  

        currDataMat=SORTtrackerCRF.(currLickType).sortedData.dataSplit(d).dataSplitSortedMat;
        c=1;
        while c<=size(currDataMat,1)

            currUnitData=currDataMat(c,:);
            currColumnName=[currLickType,'-',currSplit];
            copyNormFIringFull_spl{1,j}=currColumnName;
            copyNormFIringFull_spl(2:length(currUnitData)+1,j)=num2cell(currUnitData);
            j=j+1;
            c=c+1;
        end
    end
end


%% Calculate 60 min averages - firing rate\
copyNormFiring60MinBins_spl={};
timeBlockBins60Mins={[0 60],[60 120], [120 180],[180 240]};
%Create timebins column
timebins=[0:5:235];

j=2;
temp=struct();
sortFields=fieldnames(SORTtrackerCRF);
for s = 1:length(sortFields)
    currLickType=sortFields{s};
    temp.(currLickType)=[];
    j=j+1;
    
    for d=1:2
        currSplit=sprintf('split%d',d);
    

        currDataMat=SORTtrackerCRF.(currLickType).sortedData.dataSplit(d).dataSplitSortedMat';
        binnedResults=[];
        for h=1:length(timeBlockBins60Mins)
            includeCurrHour=[];
            avgRateCurrHour=[];
            %%%

            intStart=timeBlockBins60Mins{h}(1);
            intEnd=timeBlockBins60Mins{h}(2);

            %Get index of cells that pass interval test
            indFiltBinsByBlocks=(timebins>=intStart).*(timebins<(intEnd));
            filtCurrData=currDataMat(indFiltBinsByBlocks==1,:);
            filtCurrBins=timebins(indFiltBinsByBlocks==1);

            binnedResults(h,:)=nanmean(filtCurrData,1);
        end

       temp.(currLickType).(currSplit)=binnedResults;
    end
end

%Fill in copy60MinBins
timebins=[1:4];
copyNormFiring60MinBins_spl{1,1}='Time (Hours)';
copyNormFiring60MinBins_spl(2:length(timebins)+1,1)=num2cell(timebins);


tempfields=fieldnames(temp);
j=2;
for t=1:length(tempfields)
    
    currLickType=tempfields{t};
    
    for d=1:2
    currSplit=sprintf('split%d',d);
    currData=temp.(currLickType).(currSplit);
    j=j+1;
    c=1;
    while c<=size(currData,2)
        currUnitData=currData(:,c);
        currLickSplitType=sprintf('%s_%s',currLickType,currSplit);
        
        copyNormFiring60MinBins_spl{1,j}=currLickSplitType;

        copyNormFiring60MinBins_spl(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        c=c+1;
        j=j+1;
    end
    end
end


clearvars timebins curr* cut*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% COPY PASTE FULL PERCENT OF SPIKES IN BURSTS
copyFullPercBurst_spl={};
copyFullPercBurst_spl{1,1}='Time (min)';
timebins=[0:5:235];
copyFullPercBurst_spl(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
j=2;

sortFields=fieldnames(SORTtrackerCRF);

for s = 1:length(sortFields)
    currLickType=sortFields{s};
    
    for d=1:2
        currSplit=sprintf('split%d',d);

        % copy=SORTtrackerCRF.(curr.sortedData.sortedRateDataToPlot

        % 	copy=num2cell(T(:),2)
        %     	currCopy = num2cell(currData,size(currData));

        %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
        j=j+1;
    %     currDataMat=SORTtrackerCRF.NR.sortedData.sortedPercBurstDataToPlot  

        currDataMat=SORTtrackerCRF.(currLickType).sortedData.dataSplit(d).percSpikesInBursts;
        c=1;
        while c<=size(currDataMat,1)

            currUnitData=currDataMat(c,:);
            currColumnName=[currLickType,'-',currSplit];
            copyFullPercBurst_spl{1,j}=currColumnName;
            copyFullPercBurst_spl(2:length(currUnitData)+1,j)=num2cell(currUnitData);
            j=j+1;
            c=c+1;
        end
    end
end


%% Calculate 60 min averages - PERC SPIKES BURSTS\
copy60MinBinsPercBurst_spl={};
copy60MinBinsPercBurst_spl={[0 60],[60 120], [120 180],[180 240]};
%Create timebins column
timebins=[0:5:235];

j=2;
temp=struct();
sortFields=fieldnames(SORTtrackerCRF);
for s = 1:length(sortFields)
    currLickType=sortFields{s};
    temp.(currLickType)=[];
    j=j+1;
    
    for d=1:2
        currSplit=sprintf('split%d',d);
    

        currDataMat=SORTtrackerCRF.(currLickType).sortedData.dataSplit(d).percSpikesInBursts';
        binnedResults=[];
        for h=1:length(copy60MinBinsPercBurst_spl)
            includeCurrHour=[];
            avgRateCurrHour=[];
            %%%

            intStart=copy60MinBinsPercBurst_spl{h}(1);
            intEnd=copy60MinBinsPercBurst_spl{h}(2);

            %Get index of cells that pass interval test
            indFiltBinsByBlocks=(timebins>=intStart).*(timebins<(intEnd));
            filtCurrData=currDataMat(indFiltBinsByBlocks==1,:);
            filtCurrBins=timebins(indFiltBinsByBlocks==1);

            binnedResults(h,:)=nanmean(filtCurrData,1);
        end

       temp.(currLickType).(currSplit)=binnedResults;
    end
end

%Fill in copy60MinBins
timebins=[1:4];
copy60MinBinsPercBurst_spl{1,1}='Time (Hours)';
copy60MinBinsPercBurst_spl(2:length(timebins)+1,1)=num2cell(timebins);


tempfields=fieldnames(temp);
j=2;
for t=1:length(tempfields)
    
    currLickType=tempfields{t};
    
    for d=1:2
    currSplit=sprintf('split%d',d);
    currData=temp.(currLickType).(currSplit);
    j=j+1;
    c=1;
    while c<=size(currData,2)
        currUnitData=currData(:,c);
        currLickSplitType=sprintf('%s_%s',currLickType,currSplit);
        
        copy60MinBinsPercBurst_spl{1,j}=currLickSplitType;

        copy60MinBinsPercBurst_spl(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        c=c+1;
        j=j+1;
    end
    end
end


clearvars timebins curr* cut*



%% OPTIONAL: xlswrite
 
[date]=clock;
dateName=sprintf('%02d%02d%04d_%02dh%02dm',date(2),date(3),date(1),date(4),date(5));
xlsName=sprintf('copy Split CRF Firing Data_%s.xlsx',dateName);
 
excelOutList=who('copy*');
for e=1:length(excelOutList)
    currSheet=excelOutList{e};
    xlswrite(xlsName,eval(currSheet),currSheet);
end
 
