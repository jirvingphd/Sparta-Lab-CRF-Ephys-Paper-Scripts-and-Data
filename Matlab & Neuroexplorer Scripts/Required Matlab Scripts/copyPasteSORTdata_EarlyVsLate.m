
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LICKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Raw firing rates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyRawRatesFull={};

% copyRawRatesFull{1,1}='Time (min)';
% timebins=[0:5:235];
% copyRawRatesFull(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
% j=2;

% sortFields=fieldnames(SORTtracker);

% for s = 1:length(sortFields)
%     currLickType=sortFields{s};
    
%     %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    
%     currDataMat=SORTtracker.(currLickType).preSortData.rawRatesCleaned;
%     j=j+1;
%     c=1;
    
%     while c<=size(currDataMat,1)
        
%         currUnitData=currDataMat(c,:);
%         copyRawRatesFull{1,j}=currLickType;
%         copyRawRatesFull(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        
%         j=j+1;
%         c=c+1;
        
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PERC BURSTS:  Adding PercSpikesInBurst: early vs late  05/11/18 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
copyPercBurstFull_EvL={};
copyPercBurstFull_EvL{1,1}='Time (min)';
timebins=[0:5:235];
copyPercBurstFull_EvL(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line

e=1;
l=1;

sortFields=fieldnames(SORTtracker);
tempData=struct();

for s = 1:length(sortFields)
    
    currLickType=sortFields{s};
    %     tempData.(currLickType)
    tempData.(currLickType).early=[];
    tempData.(currLickType).late=[];
    %     e=e+1;
    % c=1;
    
%     currIdx =   SORTtracker.(currLickType).preSortData.idxQUPreSort;
%     currDataMat=SORTtracker.(currLickType).preSortData.dataPreSortCalcByBl';
currDataToComb1=SORTtracker.(currLickType).sortedData.dataSplit(1).percSpikesInBursts;  
currDataToComb2=SORTtracker.(currLickType).sortedData.dataSplit(2).percSpikesInBursts;
currIdxToComb1=SORTtracker.(currLickType).sortedData.dataSplit(1).idxQU_Split;
currIdxToComb2=SORTtracker.(currLickType).sortedData.dataSplit(2).idxQU_Split;


currDataMat=vertcat(currDataToComb1,currDataToComb2)';
currIdx =vertcat(currIdxToComb1,currIdxToComb2);
    %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    
    c=1;
    while c<=size(currDataMat,2)
        
        
        currUnitData=currDataMat(c,:);
        
        currQ=currIdx(c,1);
        currU=currIdx(c,2);
        

        currDrinkDay=DATA(currQ).fileinfo.drinkDay;
        if ischar(currDrinkDay)
            currDrinkDay=str2num(currDrinkDay);
        end
        
        if currDrinkDay<=9
            currSessionTime='early';
        elseif currDrinkDay>16
            currSessionTime='late';
        else
            c=c+1;
            continue
        end
        
        currUnitData=currDataMat(:,c);
        combData=tempData.(currLickType).(currSessionTime);
        tempData.(currLickType).(currSessionTime)=[combData, currUnitData];
        c=c+1;
        
    end
    
    
end

%%Fill in copyPasteFull_EvL

lickTypeList=fieldnames(tempData);
j=2;

for l=1:length(lickTypeList)
    
    currLickType=lickTypeList{l};
    
    sessFields=fieldnames(tempData.(currLickType));
    j=j+1;
    
    for s=1:length(sessFields)
        
        currSessType=sessFields{s};
        
        currData=tempData.(currLickType).(currSessType);
        j=j+1;
        c=1;
        
        while c<=size(currData,2)
                    currDataName=[currLickType,'-',currSessType];

            currUnitData=currData(:,c);
            copyPercBurstFull_EvL{1,j}=currDataName;
            copyPercBurstFull_EvL(2:length(currUnitData)+1,j)=num2cell(currUnitData);
            c=c+1;
            j=j+1;
            
        end
        
    end
end

%% ADDING BAR FOR PERCBUSRT
% Fill in copyPasteFullRaw_EvLBar
copyPercBurstFull_EvLBar={};
copyPercBurstFull_EvLBar{1,1}='Time (min)';
copyPercBurstFull_EvLBar{2,1}='Early';
copyPercBurstFull_EvLBar{3,1}='Late';
% timebins=[0:5:235];
% copyPasteFullRaw_EvLBar(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line

lickTypeList=fieldnames(tempData);
% j=2;
k=2; %col index
for l=1:length(lickTypeList)
    
    currLickType=lickTypeList{l};
    
    sessFields=fieldnames(tempData.(currLickType));
    %     j=j+1;
    j=2; %row index
    k=k+1;
    for s=1:length(sessFields)
        
        currSessType=sessFields{s};
        
        
        %         j=j+1;
        %         c=1;
        
        %         while c<=size(currData,2)
        currDataName=[currLickType]; %,'-',currSessType];
        currData=tempData.(currLickType).(currSessType);
        
        currUnitData=nanmean(currData,1);
        copyPercBurstFull_EvLBar{1,k}=currDataName;
        c=length(currUnitData);
        copyPercBurstFull_EvLBar(j,k:k+c-1)=num2cell(currUnitData);
        %             copyPasteFullRaw_EvLBar(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        k=k+c+1;
        j=j+1;
        
    end
    
end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adding early vs late %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
copyRawRates_EvL={};
copyPercBurstFull_EvL{1,1}='Time (min)';
timebins=[0:5:235];
copyRawRates_EvL(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line

e=1;
l=1;

sortFields=fieldnames(SORTtracker);
tempData=struct();

for s = 1:length(sortFields)
    
    currLickType=sortFields{s};
    %     tempData.(currLickType)
    tempData.(currLickType).early=[];
    tempData.(currLickType).late=[];
    %     e=e+1;
    % c=1;
    
    currIdx =   SORTtracker.(currLickType).preSortData.idxQUPreSort;
    currDataMat=SORTtracker.(currLickType).preSortData.rawRatesCleaned';
    
    
    %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    
    c=1;
    while c<=size(currDataMat,2)
        
        
        currUnitData=currDataMat(c,:);
        
        currQ=currIdx(c,1);
        currU=currIdx(c,2);
        

        currDrinkDay=DATA(currQ).fileinfo.drinkDay;
        if ischar(currDrinkDay)
            currDrinkDay=str2num(currDrinkDay);
        end
        
        if currDrinkDay<= 9
            currSessionTime='early';
        elseif currDrinkDay>16
            currSessionTime='late';
        else
            c=c+1;
            continue
        end
        
        currUnitData=currDataMat(:,c);
        combData=tempData.(currLickType).(currSessionTime);
        tempData.(currLickType).(currSessionTime)=[combData, currUnitData];
        c=c+1;
        
    end
    
    
end

%% Fill in copyPasteFull_EvL

lickTypeList=fieldnames(tempData);
j=2;

for l=1:length(lickTypeList)
    
    currLickType=lickTypeList{l};
    
    sessFields=fieldnames(tempData.(currLickType));
    j=j+1;
    
    for s=1:length(sessFields)
        
        currSessType=sessFields{s};
        
        currData=tempData.(currLickType).(currSessType);
        j=j+1;
        c=1;
        
        while c<=size(currData,2)
                    currDataName=[currLickType,'-',currSessType];

            currUnitData=currData(:,c);
            copyRawRates_EvL{1,j}=currDataName;
            copyRawRates_EvL(2:length(currUnitData)+1,j)=num2cell(currUnitData);
            c=c+1;
            j=j+1;
            
        end
        
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adding early vs late %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
copyNormRates_EvL={};
copyPercBurstFull_EvL{1,1}='Time (min)';
timebins=[0:5:235];
copyNormRates_EvL(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line

e=1;
l=1;

sortFields=fieldnames(SORTtracker);
tempData=struct();

for s = 1:length(sortFields)
    
    currLickType=sortFields{s};
    %     tempData.(currLickType)
    tempData.(currLickType).early=[];
    tempData.(currLickType).late=[];
    %     e=e+1;
    % c=1;
    
    currIdx =   SORTtracker.(currLickType).preSortData.idxQUPreSort;
    currDataMat=SORTtracker.(currLickType).preSortData.dataPreSortCalcByBl';
    
    
    %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    
    c=1;
    while c<=size(currDataMat,2)
        
        
        currUnitData=currDataMat(c,:);
        
        currQ=currIdx(c,1);
        currU=currIdx(c,2);
        

        currDrinkDay=DATA(currQ).fileinfo.drinkDay;
        if ischar(currDrinkDay)
            currDrinkDay=str2num(currDrinkDay);
        end
        
        if currDrinkDay<= 9
            currSessionTime='early';
        elseif currDrinkDay>16
            currSessionTime='late';
        else
            c=c+1;
            continue
        end
        
        currUnitData=currDataMat(:,c);
        combData=tempData.(currLickType).(currSessionTime);
        tempData.(currLickType).(currSessionTime)=[combData, currUnitData];
        c=c+1;
        
    end
    
    
end

%% Fill in copyPasteFull_EvL

lickTypeList=fieldnames(tempData);
j=2;

for l=1:length(lickTypeList)
    
    currLickType=lickTypeList{l};
    
    sessFields=fieldnames(tempData.(currLickType));
    j=j+1;
    
    for s=1:length(sessFields)
        
        currSessType=sessFields{s};
        
        currData=tempData.(currLickType).(currSessType);
        j=j+1;
        c=1;
        
        while c<=size(currData,2)
                    currDataName=[currLickType,'-',currSessType];

            currUnitData=currData(:,c);
            copyNormRates_EvL{1,j}=currDataName;
            copyNormRates_EvL(2:length(currUnitData)+1,j)=num2cell(currUnitData);
            c=c+1;
            j=j+1;
            
        end
        
    end
end
    
%% Fill in copyPasteFullRaw_EvLBar
copyPasteFullRaw_EvLBar={};
copyPasteFullRaw_EvLBar{1,1}='Time (min)';
copyPasteFullRaw_EvLBar{2,1}='Early';
copyPasteFullRaw_EvLBar{3,1}='Late';
% timebins=[0:5:235];
% copyPasteFullRaw_EvLBar(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line

lickTypeList=fieldnames(tempData);
% j=2;
k=2; %col index
for l=1:length(lickTypeList)
    
    currLickType=lickTypeList{l};
    
    sessFields=fieldnames(tempData.(currLickType));
    %     j=j+1;
    j=2; %row index
    k=k+1;
    for s=1:length(sessFields)
        
        currSessType=sessFields{s};
        
        
        %         j=j+1;
        %         c=1;
        
        %         while c<=size(currData,2)
        currDataName=[currLickType]; %,'-',currSessType];
        currData=tempData.(currLickType).(currSessType);
        
        currUnitData=nanmean(currData,1);
        copyPasteFullRaw_EvLBar{1,k}=currDataName;
        c=length(currUnitData);
        copyPasteFullRaw_EvLBar(j,k:k+c-1)=num2cell(currUnitData);
        %             copyPasteFullRaw_EvLBar(2:length(currUnitData)+1,j)=num2cell(currUnitData);
        k=k+c+1;
        j=j+1;
        
    end
    
end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adding early vs late Hour 1 vs Hour 4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e=1;
l=1;

sortFields=fieldnames(SORTtracker);
tempData=struct();

for s = 1:length(sortFields)
    
    currLickType=sortFields{s};
    %     tempData.(currLickType)
    tempData.(currLickType).early.Hour1=[];
    tempData.(currLickType).early.Hour4=[];
    tempData.(currLickType).late.Hour1=[];
    tempData.(currLickType).late.Hour4=[];
    %     e=e+1;
    % c=1;
    
    currIdx =   SORTtracker.(currLickType).preSortData.idxQUPreSort;
    % currDataMat=SORTtracker.(currLickType).preSortData.dataPreSortCalcByBl';
    
    
    %%% To fill in a column of a cell array with values from a matrix (making paste-able cell array for prism/excel)
    
    c=1;
    while c<=size(currIdx,1)
        
        
        % currUnitData=currDataMat(c,:);
        
        currQ=currIdx(c,1);
        currU=currIdx(c,2);
        

        currDrinkDay=DATA(currQ).fileinfo.drinkDay;
        if ischar(currDrinkDay)
            currDrinkDay=str2num(currDrinkDay);
        end
        
        if currDrinkDay<= 9
            currSessionTime='early';
        elseif currDrinkDay>16
            currSessionTime='late';
        else
            c=c+1;
            continue
        end
        
        currUnitHr1=DATA(currQ).units(currU).spikeRate.avgRateByHour(1).avgRate;
        currUnitHr4=DATA(currQ).units(currU).spikeRate.avgRateByHour(4).avgRate;

        % currUnitData=currDataMat(:,c);
        combData1=tempData.(currLickType).(currSessionTime).Hour1;
        combData4=tempData.(currLickType).(currSessionTime).Hour4;

        tempData.(currLickType).(currSessionTime).Hour1=[combData1, currUnitHr1];
        tempData.(currLickType).(currSessionTime).Hour4=[combData4, currUnitHr4];
        c=c+1;
        
    end
    
    
end

%% Fill in copyPasteFull_EvL
% This output needs a different format than the previous for each type of
% CRF lickType;
% outputCells{1,1}='Hour'
% outputCells{1,j)=currLickType-sessType %i.e inhibited-early
% outputCells{2,1)=Hour1
% outputCells{3,1}=Hour4
% j=2;
% outputCells{2,j}=[DATA(Q).units(u).spikeRate.avgRateByHour(1).avgRate];
% outputCells{3,j}=[DATA(Q).units(u).spikeRate.avgRateByHour(4).avgRate];


copy_RawRatesEvsL_Hr1v4={};
copy_RawRatesEvsL_Hr1v4{1,1}='Hour';
% timebins=[0:5:235];
% copy_RawRatesEvsL_Hr1v4(2:length(timebins)+1,1)=num2cell(timebins);%,size(timebins)); %make an array of ones equal to length of data to fill in 1 entry per line
copy_RawRatesEvsL_Hr1v4{2,1}=1;
copy_RawRatesEvsL_Hr1v4{3,1}=4;


lickTypeList=fieldnames(tempData);
j=2;

for l=1:length(lickTypeList)
    
    currLickType=lickTypeList{l};
    
    sessFields=fieldnames(tempData.(currLickType));
    j=j+1;
    
    for s=1:length(sessFields)
        
        currSessType=sessFields{s};
        
        currDataHr1=tempData.(currLickType).(currSessionTime).Hour1;
        currDataHr4=tempData.(currLickType).(currSessionTime).Hour4;
        j=j+1;
        c=1;
        
        while c<=size(currDataHr1,2)

            currDataName=[currLickType,'-',currSessType];

            % currUnitData=currData(:,c);
            copy_RawRatesEvsL_Hr1v4{1,j}=currDataName;
            % copy_RawRatesEvsL_Hr1v4(2:length(currUnitData)+1,j)=num2cell(currUnitData);
            copy_RawRatesEvsL_Hr1v4{2,j}=currDataHr1(c);
            copy_RawRatesEvsL_Hr1v4{3,j}=currDataHr4(c);

            c=c+1;
            j=j+1;
            
        end
        
    end
end


%% OPTIONAL: xlswrite
 
[date]=clock;
dateName=sprintf('%02d%02d%04d_%02dh%02dm',date(2),date(3),date(1),date(4),date(5));
xlsName=sprintf('copy EarlyLate Data for Prism_%s.xlsx',dateName);
 
excelOutList=who('copy*');
for e=1:length(excelOutList)
    currSheet=excelOutList{e};
    xlswrite(xlsName,eval(currSheet),currSheet);
end
%  
