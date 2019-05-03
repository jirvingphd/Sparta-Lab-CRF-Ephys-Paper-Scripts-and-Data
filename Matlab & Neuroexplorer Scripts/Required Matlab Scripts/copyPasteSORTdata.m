% copy=cell{}

%% Make Normalized Firing Z-score Line Graphs
%% X= Time(min)0-235min
%%Y1:length(currLickType)


% SORTtracker_CRF.(currLickType).sortedData.

if exist('SORTtracker_CRF','var')==0
    SORTtracker_CRF=SORTtracker.CRF;
end
%% copy Full Norm FIring Data


copyNormFiringFull={};
    copyNormFiringFull{1,1}='Time (min)';
	timebins=[0:5:235];
	copyNormFiringFull(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
    j=2;

sortFields=fieldnames(SORTtracker_CRF);
    
for s = 1:length(sortFields)
    currLickType=sortFields{s};    

    % copy=SORTtracker_CRF.(curr.sortedData.sortedRateDataToPlot

    % 	copy=num2cell(T(:),2)
%     	currCopy = num2cell(currData,size(currData));

%%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
	j=j+1;
    
    currDataMat=SORTtracker_CRF.(currLickType).sortedData.sortedRateDataToPlot;
    c=1;
    while c<=size(currDataMat,1)
        
        currUnitData=currDataMat(c,:);
        copyNormFiringFull{1,j}=currLickType;
        copyNormFiringFull(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        j=j+1;
        c=c+1;
    end
end
    
    
    
    
%     copy{1,2:length}=currLickType;
%     copy(2:length(timebins)+1,j:size()=mat2cell(currData,ones(1,length(currData)),1) %make an array of ones equal to length of data to fill in 1 entry per line

    %%%


%% Calculate 60 min averages\
copyNormFiring60MinBins={};
timeBlockBins60Mins={[0 60],[60 120], [120 180],[180 240]};
%Create timebins column
timebins=[0:5:235];

    j=2;
temp=struct();
sortFields=fieldnames(SORTtracker_CRF);
for s = 1:length(sortFields)
    currLickType=sortFields{s};    
        j=j+1;

            currDataMat=SORTtracker_CRF.(currLickType).sortedData.sortedRateDataToPlot';
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
        
        temp.(currLickType).binnedResults=binnedResults;
        
end

%Fill in copy60MinBins
timebins=[1:4];
copyNormFiring60MinBins{1,1}='Time (Hours)';
copyNormFiring60MinBins(2:length(timebins)+1,1)=num2cell(timebins);


  tempfields=fieldnames(temp);
  j=2;
for t=1:length(tempfields)
    
        currLickType=tempfields{t}; 
       currData=temp.(currLickType).binnedResults;
    j=j+1;
        c=1;
        while c<=size(currData,2)
            currUnitData=currData(:,c);
            copyNormFiring60MinBins{1,j}=currLickType;
             copyNormFiring60MinBins(2:length(currUnitData)+1,j)=num2cell(currUnitData);
             c=c+1;
             j=j+1;
        end
end


clearvars timebins curr* cut*

%% Now calc 30 min bins
% 
% copyNormFiring30MinBins={};
% timeBlockBins30Mins={[0 30],[30 60],[60 90],[90 120],[120 150],[150 180],[180 210], [210 240]};
% %Create timebins column
% % timebins=[];
% timebins=[0:5:235];
% 
%     j=2;
% temp=struct();
% sortFields=fieldnames(SORTtracker_CRF);
% for s = 1:length(sortFields)
%     currLickType=sortFields{s};    
%         j=j+1;
% 
%             currDataMat=SORTtracker_CRF.(currLickType).sortedData.sortedRateDataToPlot';
%             binnedResults=[];
%             for h=1:length(timeBlockBins30Mins)
%                 includeCurrHour=[];
%                 avgRateCurrHour=[];
%                 %%%
%                 
%                 intStart=timeBlockBins30Mins{h}(1);
%                 intEnd=timeBlockBins30Mins{h}(2);
%         
%                  %Get index of cells that pass interval test
%                 indFiltBinsByBlocks=(timebins>=intStart).*(timebins<(intEnd));
%                 filtCurrData=currDataMat(indFiltBinsByBlocks==1,:);
%                 filtCurrBins=timebins(indFiltBinsByBlocks==1);   
%                 
%                 binnedResults(h,:)=nanmean(filtCurrData,1);
%             end
%         
%         temp.(currLickType).binnedResults=binnedResults;
%         
% end

% %Fill in copy30MinBins
% timebins=[0.5:0.5:4];
% % timeStrings=sprintf(timebins(1:end),)
% copyNormFiring30MinBins{1,1}='Time (Hours)';
% copyNormFiring30MinBins(2:length(timebins)+1,1)=num2cell(timebins);
% 
% 
%   tempfields=fieldnames(temp);
%   j=2;
% for t=1:length(tempfields)
%     
%         currLickType=tempfields{t}; 
%        currData=temp.(currLickType).binnedResults;
%     j=j+1;
%         c=1;
%         while c<=size(currData,2)
%             currUnitData=currData(:,c);
%             copyNormFiring30MinBins{1,j}=currLickType;
%              copyNormFiring30MinBins(2:length(currUnitData)+1,j)=num2cell(currUnitData);
%              c=c+1;
%              j=j+1;
%         end
% end
%   
        
        
        
%% Raw firing rates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
copyRawRatesFull={};

    copyRawRatesFull{1,1}='Time (min)';
    timebins=[0:5:235];
    copyRawRatesFull(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
    j=2;

sortFields=fieldnames(SORTtracker_CRF);
    
for s = 1:length(sortFields)
    currLickType=sortFields{s};    

    %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    
    currDataMat=SORTtracker_CRF.(currLickType).preSortData.rawRatesCleaned;
    j=j+1;
    c=1;

    while c<=size(currDataMat,1)
        
        currUnitData=currDataMat(c,:);
        copyRawRatesFull{1,j}=currLickType;
        copyRawRatesFull(2:length(currUnitData)+1,j)=num2cell(currUnitData);

        j=j+1;
        c=c+1;

    end
end
    
    
        
        
%% Calculate 60 min averages\
copy60MinRawRatesBins={};
timeBlockBins60Mins={[0 60],[60 120], [120 180],[180 240]};
%Create timebins column
timebins=[0:5:235];

    j=2;
temp=struct();
sortFields=fieldnames(SORTtracker_CRF);
for s = 1:length(sortFields)
    currLickType=sortFields{s};    
        j=j+1;

            currDataMat=SORTtracker_CRF.(currLickType).preSortData.rawRatesCleaned';
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
        
        temp.(currLickType).binnedResults=binnedResults;
        
end

%Fill in copy60MinRawRatesBins
timebins=[1:4];
copy60MinRawRatesBins{1,1}='Time (Hours)';
copy60MinRawRatesBins(2:length(timebins)+1,1)=num2cell(timebins);


  tempfields=fieldnames(temp);
  j=2;
for t=1:length(tempfields)
    
        currLickType=tempfields{t}; 
       currData=temp.(currLickType).binnedResults;
    j=j+1;
        c=1;
        while c<=size(currData,2)
            currUnitData=currData(:,c);
            copy60MinRawRatesBins{1,j}=currLickType;
             copy60MinRawRatesBins(2:length(currUnitData)+1,j)=num2cell(currUnitData);
             c=c+1;
             j=j+1;
        end
end


clearvars timebins curr* cut*



% %% Now calc 30 min bins
% 
% copy30MinRawRateBins={};
% timeBlockBins30Mins={[0 30],[30 60],[60 90],[90 120],[120 150],[150 180],[180 210], [210 240]};
% %Create timebins column
% % timebins=[];
% timebins=[0:5:235];
% 
%     j=2;
% temp=struct();
% sortFields=fieldnames(SORTtracker_CRF);
% for s = 1:length(sortFields)
%     currLickType=sortFields{s};    
%         j=j+1;
% 
%             currDataMat=SORTtracker_CRF.(currLickType).preSortData.rawRatesCleaned';
%             binnedResults=[];
%             for h=1:length(timeBlockBins30Mins)
%                 includeCurrHour=[];
%                 avgRateCurrHour=[];
%                 %%%
%                 
%                 intStart=timeBlockBins30Mins{h}(1);
%                 intEnd=timeBlockBins30Mins{h}(2);
%         
%                  %Get index of cells that pass interval test
%                 indFiltBinsByBlocks=(timebins>=intStart).*(timebins<(intEnd));
%                 filtCurrData=currDataMat(indFiltBinsByBlocks==1,:);
%                 filtCurrBins=timebins(indFiltBinsByBlocks==1);   
%                 
%                 binnedResults(h,:)=nanmean(filtCurrData,1);
%             end
%         
%         temp.(currLickType).binnedResults=binnedResults;
%         
% end
% % 
% %Fill in copy30MinRawRateBins
% timebins=[0.5:0.5:4];
% % timeStrings=sprintf(timebins(1:end),)
% copy30MinRawRateBins{1,1}='Time (Hours)';
% copy30MinRawRateBins(2:length(timebins)+1,1)=num2cell(timebins);
% 
% 
%   tempfields=fieldnames(temp);
%   j=2;
% for t=1:length(tempfields)
%     
%         currLickType=tempfields{t}; 
%        currData=temp.(currLickType).binnedResults;
%     j=j+1;
%         c=1;
%         while c<=size(currData,2)
%             currUnitData=currData(:,c);
%             copy30MinRawRateBins{1,j}=currLickType;
%              copy30MinRawRateBins(2:length(currUnitData)+1,j)=num2cell(currUnitData);
%              c=c+1;
%              j=j+1;
%         end
% end


%% ADDING OTHER FILES %%%%%%%%%% 
%% % OF SPIKES IN BURSTS - FULL
copyPercBurstFull={};
copyPercBurstFull{1,1}='Time (min)';
timebins=[0:5:235];
copyPercBurstFull(2:length(timebins)+1,1)=num2cell(timebins); %,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
j=2;

sortFields=fieldnames(SORTtracker_CRF);

for s = 1:length(sortFields)
    currLickType=sortFields{s};
    

    
    %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    j=j+1;
    currDataMat=SORTtracker_CRF.(currLickType).sortedData.sortedPercBurstDataToPlot;
%     currDataMat=SORTtracker_CRF.(currLickType).sortedData.sortedRateDataToPlot;
    c=1;
    while c<=size(currDataMat,1)
        
        currUnitData=currDataMat(c,:);
        copyPercBurstFull{1,j}=currLickType;
        copyPercBurstFull(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        j=j+1;
        c=c+1;
    end
end
%% Calculate 60 min averages % spikes in bursts\
copyPercBurst60MinBins={};
timeBlockBins60Mins={[0 60],[60 120], [120 180],[180 240]};
%Create timebins column
timebins=[0:5:235];

j=2;
temp=struct();
sortFields=fieldnames(SORTtracker_CRF);
for s = 1:length(sortFields)
    currLickType=sortFields{s};
    j=j+1;
 currDataMat=SORTtracker_CRF.(currLickType).sortedData.sortedPercBurstDataToPlot';
%     currDataMat=SORTtracker_CRF.(currLickType).sortedData.';
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
    
    temp.(currLickType).binnedResults=binnedResults;
    
end

%Fill in copy60MinBins
timebins=[1:4];
copyPercBurst60MinBins{1,1}='Time (Hours)';
copyPercBurst60MinBins(2:length(timebins)+1,1)=num2cell(timebins);


tempfields=fieldnames(temp);
j=2;
for t=1:length(tempfields)
    
    currLickType=tempfields{t};
    currData=temp.(currLickType).binnedResults;
    j=j+1;
    c=1;
    while c<=size(currData,2)
        currUnitData=currData(:,c);
        copyPercBurst60MinBins{1,j}=currLickType;
        copyPercBurst60MinBins(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        c=c+1;
        j=j+1;
    end
end


clearvars timebins curr* cut*




%% OPTIONAL: xlswrite

[date]=clock;
dateName=sprintf('%02d%02d%04d_%02dh%02dm',date(2),date(3),date(1),date(4),date(5));
xlsName=sprintf('copy CRF Data New Licks Prism_%s.xlsx',dateName);

excelOutList=who('copy*')
for e=1:length(excelOutList)
    currSheet=excelOutList{e};
    xlswrite(xlsName,eval(currSheet),currSheet);
end


