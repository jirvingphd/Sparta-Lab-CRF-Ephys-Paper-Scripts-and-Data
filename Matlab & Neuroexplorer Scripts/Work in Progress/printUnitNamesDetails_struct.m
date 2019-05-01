%printUnitNamesDetails_struct.m

printList=struct();

printList(1).file_name='File Name';
printList(1).Q='DATA(Q)';
printList(1).u='units(u)';
printList(1).unit_name ='Unit Name';
printList(1).drink_type ='Drink Type';
printList(1).ethanol_day ='Ethanol Day';
printList(1).light_response='Light Response';
printList(1).lick_response='Lick Response';
printList(1).num_licks='#Licks';

printList(1).spk_sec_full ='FullSess-Spk/sec';
printList(1).perc_in_bursts_full ='FullSess-%SpikesInBursts';
printList(1).spk_sec_hr1 ='Hour1-Spk/sec';
printList(1).perc_in_bursts_hr1='Hour1-%SpikesInBursts';
printList(1).spk_sec_hr2 ='Hour2-Spk/sec';
printList(1).perc_in_bursts_hr2 ='Hour2-%SpikesInBursts';
printList(1).spk_sec_hr3 ='Hour3-Spk/sec';
printList(1).perc_in_bursts_hr3 ='Hour3-%SpikesInBursts';
printList(1).spk_sec_hr4 ='Hour4-Spk/sec';
printList(1).perc_in_bursts_hr4='Hour4-%SpikesInBursts';
printList(1).cv ='CV';
printList(1).avg_ISI ='avgISI';


printList(1).hr1_spk_sec ='Hour1-Spk/sec';
printList(1).hr1_num_licks ='Hour1-NumLicks';
printList(1).hr2_spk_sec ='Hour2-Spk/sec';
printList(1).hr2_num_licks ='Hour2-NumLicks';
printList(1).hr3_spk_sec ='Hour3-Spk/sec';
printList(1).hr3_num_licks ='Hour3-NumLicks';
printList(1).hr4_spk_sec ='Hour4-Spk/sec';
printList(1).hr4_num_licks ='Hour4-NumLicks';
% % printList{1,10}='Spk/sec-Full4Hr';

ERRunitsOut=[];
% j=2;
for Q=1:length(DATA)
    j=Q+1
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
        
        %% Populating the printList cell array to be exported as an Excel file.
        printList(j).file_name=DATA(Q).fileinfo.filename;
        printList(j).Q=Q;
        printList(j).u= u;
        printList(j).unit_name= DATA(Q).units(u).name;
        
        printList(j).drink_type=DATA(Q).fileinfo.drinkType;
        printList(j).ethanol_day= DATA(Q).fileinfo.drinkDay;
        
        printList(j).light_response= DATA(Q).units(u).finalLightResponse;
        printList(j).lick_response= DATA(Q).units(u).finalLickResponse;
        printList(j).num_licks= length(DATA(Q).fileinfo.events.EventLick);
        
        %calc average
        TEMP=DATA(Q).units(u).spikeRate;
        tempData=[TEMP.avgRateByHour(:).avgRate];
        avgRateFull4hr=mean(tempData);
        clearvars TEMP tempData
        
        
        printList(j).spk_sec_full=avgRateFull4hr;
        
        if isfield(BURSTunits(Q).units(u).BURSTstats,'percSpikesInBursts')==0
            printList(j).perc_in_bursts_full='ERR';
            printList(j).perc_in_bursts_hr1='ERR';
            printList(j).perc_in_bursts_hr2='ERR';
            printList(j).perc_in_bursts_hr3='ERR';
            printList(j).perc_in_bursts_hr4='ERR';
        else
            printList(j).perc_in_bursts_full=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.avg;%SpikesInBursts-Full4Hr';
            printList(j).perc_in_bursts_hr1=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour1; %'%SpikesInBursts-Hour1';
            printList(j).perc_in_bursts_hr2=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour2; %'%SpikesInBursts-Hour2';
            printList(j).perc_in_bursts_hr3=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour3; %'%SpikesInBursts-Hour3';
            printList(j).perc_in_bursts_hr4=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour4; %'%SpikesInBursts-Hour4';
        end
        printList(j).spk_sec_hr1=DATA(Q).units(u).spikeRate.avgRateByHour(1).avgRate;%'Spk/sec-Hour1';
        printList(j).spk_sec_hr2=DATA(Q).units(u).spikeRate.avgRateByHour(2).avgRate;%'Spk/sec-Hour2';
        printList(j).spk_sec_hr3=DATA(Q).units(u).spikeRate.avgRateByHour(3).avgRate;%'Spk/sec-Hour3';
        printList(j).spk_sec_hr4=DATA(Q).units(u).spikeRate.avgRateByHour(4).avgRate;%'Spk/sec-Hour4';
        
        printList(j).cv= DATA(Q).units(u).spikeRate.CV;%'CV';
        printList(j).avg_ISI= DATA(Q).units(u).spikeRate.meanISI;%'avgISI';
        %     end
        
        %%CALC AVG FOR FULL SESSION
        TEMP=DATA(Q).units(u).spikeRate;
        tempData=[TEMP.avgRateByHour(:).avgRate];
        avgRateFull4hr=mean(tempData);
        
        
        
%         TEMPlick=LICKS(Q).cutLickRate;
                
        
        %%NEW LICKS
        %         printList(j).=avgRateFull4hr;	%'FullSess-Spk/sec';
        %         printList(j).=avgRateFull4hrLick;	%'FullSess-NumLicks';
        clearvars TEMP* tempData*
        
        % printList{1,22}='Hour1-Spk/sec';
        % printList{1,23}='Hour1-NumLicks';
        % printList{1,25}='Hour2-Spk/sec';
        % printList{1,26}='Hour2-NumLicks';
        % printList{1,28}='Hour3-Spk/sec';
        % printList{1,29}='Hour3-NumLicks';
        % printList{1,31}='Hour4-Spk/sec';
        % printList{1,32}='Hour4-NumLicks';
        
        printList(j).hr1_spk_sec=DATA(Q).units(u).spikeRate.avgRateByHour(1).avgRate;%'Spk/sec-Hour1';
        printList(j).hr1_num_licks=sum(LICKS(Q).cutLickCounts(1:12));
        
        printList(j).hr2_spk_sec=DATA(Q).units(u).spikeRate.avgRateByHour(2).avgRate;%'Spk/sec-Hour2';
        printList(j).hr2_num_licks=sum(LICKS(Q).cutLickCounts(13:24));
        
        printList(j).hr3_spk_sec=DATA(Q).units(u).spikeRate.avgRateByHour(3).avgRate;%'Spk/sec-Hour3';
        printList(j).hr3_num_licks=sum(LICKS(Q).cutLickCounts(25:36));
        
        printList(j).hr4_spk_sec=DATA(Q).units(u).spikeRate.avgRateByHour(4).avgRate;%'Spk/sec-Hour4';
        printList(j).hr4_num_licks=sum(LICKS(Q).cutLickCounts(37:48));
        
        
        
        
    end
end

T = struct2table(printList)