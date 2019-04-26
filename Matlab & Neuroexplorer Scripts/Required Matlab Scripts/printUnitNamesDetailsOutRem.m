% printUnitNamesDetails.m
%Updated 11/13/17 with CV and meanISI added to shortList
%REQUIRES: DATA, BURSTunits structures.
%This creates an excel spreadsheet that lists the specified characteristics of each unit

% j=2;
% for Q=1:length(DATA)
%     for u=1:length(DATA(Q).units)
%         j=j+1;
%     end
% end

% xlsName=['nex DATA Unit Details.xlsx'];
%Updating 02-25-18 to ensure the new outlier-removed percSpikesInBursts are
%used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% printUnitNamesDetails%%%%
shortList={};

shortList{1,1}='File Name';
shortList{1,2}='DATA(Q)';
shortList{1,3}='units(u)';
shortList{1,4}='Unit Name';
shortList{1,5}='Drink Type';
shortList{1,6}='Ethanol Day';
shortList{1,7}='Light Response';
shortList{1,8}='Lick Response';
shortList{1,9}='#Licks';


% % shortList{1,10}='Spk/sec-Full4Hr';
% % shortList{1,11}='%SpikesInBursts-Full4Hr';
% % shortList{1,12}='Spk/sec-Hour1';
% % shortList{1,13}='%SpikesInBursts-Hour1';
% % shortList{1,14}='Spk/sec-Hour2';
% % shortList{1,15}='%SpikesInBursts-Hour2';
% % shortList{1,16}='Spk/sec-Hour3';
% % shortList{1,17}='%SpikesInBursts-Hour3';
% % shortList{1,18}='Spk/sec-Hour4';
% % shortList{1,19}='%SpikesInBursts-Hour4';
% % shortList{1,20}='CV';
% % shortList{1,21}='avgISI';
shortList{1,10}='FullSess-Spk/sec';
shortList{1,11}='FullSess-%SpikesInBursts';
shortList{1,12}='Hour1-Spk/sec';
shortList{1,13}='Hour1-%SpikesInBursts';
shortList{1,14}='Hour2-Spk/sec';
shortList{1,15}='Hour2-%SpikesInBursts';
shortList{1,16}='Hour3-Spk/sec';
shortList{1,17}='Hour3-%SpikesInBursts';
shortList{1,18}='Hour4-Spk/sec';
shortList{1,19}='Hour4-%SpikesInBursts';
shortList{1,20}='CV';
shortList{1,21}='avgISI';


shortList{1,22}='Hour1-Spk/sec';
shortList{1,23}='Hour1-NumLicks';
shortList{1,24}='Hour2-Spk/sec';
shortList{1,25}='Hour2-NumLicks';
shortList{1,26}='Hour3-Spk/sec';
shortList{1,27}='Hour3-NumLicks';
shortList{1,28}='Hour4-Spk/sec';
shortList{1,29}='Hour4-NumLicks';

ERRunitsOut=[];

%%%%%%%%%%%%

j=2;
for Q=1:length(DATA)
    
    if DATA(Q).fileinfo.include==0
        fprintf('File DATA(%d)) was not included.\n',Q);
        continue
    end
    
    
    for u=1:length(DATA(Q).units)
        
        if DATA(Q).units(u).include==0
            fprintf('Unit DATA(%d).units(%d) marked for exclusion.\n',Q,u);
            ERRunitsOut=[ERRunitsOut; Q,u];
            continue
        end
        
        
        %% Checking for manually added drink type and drink day info:
        if isempty(DATA(Q).fileinfo.drinkType)% || isnan((DATA(Q).fileinfo.drinkType))
            %             fprintf('DATA(Q).fileinfo.drinkType is empty. Assuming "ethanol",\n');
            DATA(Q).fileinfo.drinkType='unknown';
        end
        if isnan(DATA(Q).fileinfo.drinkType)
            DATA(Q).fileinfo.drinkType='unknown';
        end
        
        
        
        
        if isfield(DATA(Q).fileinfo, 'drinkDay')==0 %|| (any(isempty(DATA(Q).fileinfo.drinkDay)==1)
            DATA(Q).fileinfo.drinkDay=NaN;
        end
        
        if isempty(DATA(Q).fileinfo.drinkDay)
            DATA(Q).fileinfo.drinkDay=NaN;
            
        end
        
        %% Populating the shortList cell array to be exported as an Excel file.
        shortList{j,1}=DATA(Q).fileinfo.filename;
        shortList{j,2}=Q;
        shortList{j,3}= u;
        shortList{j,4}= DATA(Q).units(u).name;
        
        shortList{j,5}=DATA(Q).fileinfo.drinkType;
        shortList{j,6}= DATA(Q).fileinfo.drinkDay;
        
        shortList{j,7}= DATA(Q).units(u).finalLightResponse;
        shortList{j,8}= DATA(Q).units(u).finalLickResponse;
        shortList{j,9}= length(DATA(Q).fileinfo.events.EventLick);
        
        %calc average
        TEMP=DATA(Q).units(u).spikeRate;
        tempData=[TEMP.avgRateByHour(:).avgRate];
        avgRateFull4hr=mean(tempData);
        clearvars TEMP tempData
        
        
        shortList{j,10}=avgRateFull4hr;
        
        if isfield(BURSTunits(Q).units(u).BURSTstats,'percSpikesInBursts')==0
            shortList{j,11}='ERR';
            shortList{j,13}='ERR';
            shortList{j,15}='ERR';
            shortList{j,17}='ERR';
            shortList{j,19}='ERR';
        else
            shortList{j,11}=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.avg;%SpikesInBursts-Full4Hr';
            shortList{j,13}=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour1; %'%SpikesInBursts-Hour1';
            shortList{j,15}=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour2; %'%SpikesInBursts-Hour2';
            shortList{j,17}=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour3; %'%SpikesInBursts-Hour3';
            shortList{j,19}=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour4; %'%SpikesInBursts-Hour4';
        end
        shortList{j,12}=DATA(Q).units(u).spikeRate.avgRateByHour(1).avgRate;%'Spk/sec-Hour1';
        shortList{j,14}=DATA(Q).units(u).spikeRate.avgRateByHour(2).avgRate;%'Spk/sec-Hour2';
        shortList{j,16}=DATA(Q).units(u).spikeRate.avgRateByHour(3).avgRate;%'Spk/sec-Hour3';
        shortList{j,18}=DATA(Q).units(u).spikeRate.avgRateByHour(4).avgRate;%'Spk/sec-Hour4';
        
        shortList{j,20}= DATA(Q).units(u).spikeRate.CV;%'CV';
        shortList{j,21}= DATA(Q).units(u).spikeRate.meanISI;%'avgISI';
        %     end
        
        %%CALC AVG FOR FULL SESSION
        TEMP=DATA(Q).units(u).spikeRate;
        tempData=[TEMP.avgRateByHour(:).avgRate];
        avgRateFull4hr=mean(tempData);
        
        
        
        TEMPlick=DATA(Q).units(u).lickRate;
        tempDataLick=[TEMPlick.avgRateByHour(:).avgRate];
        avgRateFull4hrLick=mean(tempDataLick);
        
        
        %%NEW LICKS
        %         shortList{j,22}=avgRateFull4hr;	%'FullSess-Spk/sec';
        %         shortList{j,23}=avgRateFull4hrLick;	%'FullSess-NumLicks';
        clearvars TEMP* tempData*
        
        % shortList{1,22}='Hour1-Spk/sec';
        % shortList{1,23}='Hour1-NumLicks';
        % shortList{1,25}='Hour2-Spk/sec';
        % shortList{1,26}='Hour2-NumLicks';
        % shortList{1,28}='Hour3-Spk/sec';
        % shortList{1,29}='Hour3-NumLicks';
        % shortList{1,31}='Hour4-Spk/sec';
        % shortList{1,32}='Hour4-NumLicks';
        
        shortList{j,22}=DATA(Q).units(u).spikeRate.avgRateByHour(1).avgRate;%'Spk/sec-Hour1';
        shortList{j,23}=DATA(Q).units(u).lickRate.licksByHour(1).lickCounts;
        
        shortList{j,24}=DATA(Q).units(u).spikeRate.avgRateByHour(2).avgRate;%'Spk/sec-Hour2';
        shortList{j,25}=DATA(Q).units(u).lickRate.licksByHour(2).lickCounts;
        
        shortList{j,26}=DATA(Q).units(u).spikeRate.avgRateByHour(3).avgRate;%'Spk/sec-Hour3';
        shortList{j,27}=DATA(Q).units(u).lickRate.licksByHour(3).lickCounts;
        
        shortList{j,28}=DATA(Q).units(u).spikeRate.avgRateByHour(4).avgRate;%'Spk/sec-Hour4';
        shortList{j,29}=DATA(Q).units(u).lickRate.licksByHour(4).lickCounts;
        
        
        
        
        k=30;
        %% Add lick correlations
        if exist('CORRlicks','var')
            nameFields=fieldnames(CORRlicks(Q).units);
            
            listOfStatNames=[cellfun(@(x)regexpi(x,'(\w*)_Sig\>','tokens'),nameFields,'UniformOutput',0)];
            listOfStatNames=[listOfStatNames{:}];
            listOfStatNames=[listOfStatNames{:}]';
            %             listOfStatNames={'rateVsLick_pVal','rateVsLick_pearsonR','percBurstVsLick_pVal','percBurstVsLick_pearsonR'};
            for s=1:length(listOfStatNames)
                currStat=listOfStatNames{s};
                shortList{1,k}=sprintf([currStat,'_pVal']);
                shortList{j,k}=CORRlicks(Q).units(u).(currStat).pVal;
                k=k+1;
                shortList{1,k}=sprintf([currStat,'_pearsonR']);
                shortList{j,k}=CORRlicks(Q).units(u).(currStat).pearsonR;
                k=k+1;
            end
        end
        
        
        %
        %% Add overall averages of other burst parameters normally included in unitList
        currStat='percSpikesInBursts';
        
        if isfield(BURSTunits(Q).units(u).BURSTstats,currStat)&& isfield(BURSTunits(Q).units(u).BURSTstats.(currStat),'avg')
            
            currStat='percSpikesInBursts';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg;
            k=k+1;
            
            currStat='SpikesInBurst';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg;
            k=k+1;
            
            currStat='MeanISIinBurst';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg;
            k=k+1;
            
            currStat='PeakFreqInBurst';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg ;
            k=k+1;
            
            currStat='BurstDuration';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg                      ;
            k=k+1;
            
            
            currStat='meanFreqInBurst';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg                              ;
            k=k+1;
            
            currStat='BurstsPerSecond';
            shortList{1,k}=sprintf('Avg %s',currStat);
            shortList{j,k}=BURSTunits(Q).units(u).BURSTstats.(currStat).avg;
            k=k+1;
            
            currStat='Include File?';
            shortList{1,k}=sprintf(currStat);
            shortList{j,k}=DATA(Q).fileinfo.include;
            
            k=k+1;
            currStat='Include Unit?';
            shortList{1,k}=sprintf(currStat);
            if DATA(Q).fileinfo.include==0
                shortList{j,k}=0;
            else
                currStat='Include File?';
                shortList{j,k}=DATA(Q).units(u).include;
            end
        end
        j=j+1;
    end
    
end

%% Add outlier details
k=k+2;
if exist('optionsOutliers','var')
    shortList{1,k}=sprintf('Fill Method 1:');
    shortList{2,k}=sprintf('%s',optionsOutliers.fillMethod1);
    k=k+1;
    shortList{1,k}=sprintf('Fill Method 2:');
    shortList{2,k}=sprintf('%s',optionsOutliers.fillMethod2);
    
end

%% Replace NaN with ERR so don't have to replace
%fprintf('Remember to replace blank cells with 0.\n\n');
for n=1:numel(shortList)
    if isnan(shortList{n})
        shortList{n}='ERR';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%A=shortList;
% A=shortList
% B=shortList;
% B(cellfun(@isnan,B,'UniformOutput',0))={0};
% replacedata(A,B(2:end,:));
% clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* shortList

%% Name and save Excel data file %%%%
[date]=clock;
%dateName=sprintf('%02d%02d%04d',date(2),date(3),date(1))
dateName=sprintf('%02d%02d%04d_%02dh%02dm',date(2),date(3),date(1),date(4),date(5));

xlsName=sprintf('DATA Unit Details By Hour_%s.xlsx',dateName);
xlswrite(xlsName,shortList,'ShortUnitDetails');

% clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* shortList* CORR* LICKS SPIKES
clearCRFdata