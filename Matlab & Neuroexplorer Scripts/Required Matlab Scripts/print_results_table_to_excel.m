%printUnitNamesDetails_struct.m
%% Export RATEStables first
fprintf('Export rates tables using rates_tables_to_excel.m\n')
rates_table_to_excel
%% Export unit details 
P=struct();
row = 0;
for Q=1:length(DATA)
    for u=1:length(DATA(Q).units)
        row = row+1 ;
        P(1).file_name='File Name';
        file_name = DATA(Q).fileinfo.filename;
        P(row).file_name = file_name;

        P(1).Q='DATA(Q)';
        P(row).Q = Q;
        P(1).u='units(u)';
        P(row).u = u;

        P(1).unit_name ='Unit Name';
        unit_name = DATA(Q).units(u).name;
        P(row).unit_name = unit_name;
        
        P(1).include_file = 'Include File?';
        include_file = DATA(Q).fileinfo.include;
        P(row).include_file = include_file;

        P(1).include_unit = 'Include Unit?';
        include_unit = DATA(Q).units(u).include;
        P(row).include_unit = include_unit;
        if (include_unit == 0) || (include_file==0)
            continue
        end
        P(1).drink_type ='Drink Type';
        drink_type = DATA(Q).fileinfo.drinkType;
        P(row).drink_type = drink_type;

        P(1).ethanol_day ='Ethanol Day';
        ethanol_day = DATA(Q).fileinfo.drinkDay;
        P(row).ethanol_day = ethanol_day;

        
        P(1).light_response='Light Response';
        light_response = DATA(Q).units(u).finalLightResponse;
        P(row).light_response = light_response;

        P(1).lick_response='Lick Response';
        lick_response = DATA(Q).units(u).finalLickResponse;
        P(row).lick_response = lick_response;

        P(1).num_licks='#Licks';
        num_licks = length(DATA(Q).fileinfo.events.EventLick);
        P(row).num_licks = num_licks;

        P(1).spk_sec_full ='FullSess-Spk/sec';
        spk_sec_full =mean([DATA(Q).units(u).spikeRate.avgRateByHour(:).avgRate]);
        P(row).spk_sec_full = spk_sec_full;

        P(1).spk_sec_hr1 ='Hour1-Spk/sec';
        spk_sec_hr1 = DATA(Q).units(u).spikeRate.avgRateByHour(1).avgRate;
        P(row).spk_sec_hr1 = spk_sec_hr1;

        P(1).spk_sec_hr2 ='Hour2-Spk/sec';
        spk_sec_hr2 = DATA(Q).units(u).spikeRate.avgRateByHour(2).avgRate;
        P(row).spk_sec_hr2 = spk_sec_hr2;

        P(1).spk_sec_hr3 ='Hour3-Spk/sec';
        spk_sec_hr3 = DATA(Q).units(u).spikeRate.avgRateByHour(3).avgRate;
        P(row).spk_sec_hr3 = spk_sec_hr3;

        P(1).spk_sec_hr4 ='Hour4-Spk/sec';
        spk_sec_hr4 = DATA(Q).units(u).spikeRate.avgRateByHour(4).avgRate;
        P(row).spk_sec_hr4 = spk_sec_hr4;

        P(1).perc_in_bursts_full ='FullSess-%SpikesInBursts';
        perc_in_bursts_full = BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.avg;
        P(row).perc_in_bursts_full = perc_in_bursts_full;

        P(1).perc_in_bursts_hr1='Hour1-%SpikesInBursts';
        perc_in_bursts_hr1 = BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour1;
        P(row).perc_in_bursts_hr1 = perc_in_bursts_hr1;

        P(1).perc_in_bursts_hr2 ='Hour2-%SpikesInBursts';
        perc_in_bursts_hr2 = BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour2;
        P(row).perc_in_bursts_hr2 = perc_in_bursts_hr2;

        P(1).perc_in_bursts_hr3 ='Hour3-%SpikesInBursts';
        perc_in_bursts_hr3 = BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour3;
        P(row).perc_in_bursts_hr3 = perc_in_bursts_hr3;

        P(1).perc_in_bursts_hr4='Hour4-%SpikesInBursts';
        perc_in_bursts_hr4 = BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour4;
        P(row).perc_in_bursts_hr4 = perc_in_bursts_hr4;

        P(1).cv ='CV';
        cv = DATA(Q).units(u).spikeRate.CV;%'CV';
        P(row).cv = cv;

        P(1).avg_ISI ='avgISI';
        avgISI = DATA(Q).units(u).spikeRate.meanISI;
        P(row).avgISI = avgISI;

        P(1).hr1_spk_sec ='Hour1-Spk/sec';
        P(row).hr1_spk_sec = spk_sec_hr1;

        P(1).hr1_num_licks ='Hour1-NumLicks';
        hr1_num_licks =sum(LICKS(Q).cutLickCounts(1:12));
        P(row).hr1_num_licks = hr1_num_licks;

        P(1).hr2_spk_sec ='Hour2-Spk/sec';
        P(row).hr2_spk_sec = spk_sec_hr2;

        P(1).hr2_num_licks ='Hour2-NumLicks';
        hr2_num_licks = sum(LICKS(Q).cutLickCounts(13:24));
        P(row).hr2_num_licks = hr2_num_licks;

        P(1).hr3_spk_sec ='Hour3-Spk/sec';
        P(row).hr3_spk_sec = spk_sec_hr3;

        P(1).hr3_num_licks ='Hour3-NumLicks';
        hr3_num_licks=sum(LICKS(Q).cutLickCounts(25:36));
        P(row).hr3_num_licks = hr3_num_licks;

        P(1).hr4_spk_sec ='Hour4-Spk/sec';
        P(row).hr4_spk_sec = spk_sec_hr4;

        P(1).hr4_num_licks ='Hour4-NumLicks';
        hr4_num_licks=sum(LICKS(Q).cutLickCounts(37:48));
        P(row).hr4_num_licks = hr4_num_licks;
    end
end
% % P{1,10}='Spk/sec-Full4Hr';

RESULTS_TABLE = struct2table(P);
basename = 'Unit Results Summary Table';
excelfilename = strcat(basename,'.xlsx');
if isfile(excelfilename)
    [date]=clock;
    dateName=sprintf('%02d%02d%04d_%02dh%02dm',date(2),date(3),date(1),date(4),date(5));    
    excelfilename = strcat(basename,dateName,'.xlsx')
end
writetable(RESULTS_TABLE,excelfilename)

fprintf('If you have not run prep_data_for_norm_firing_fig.m, run now.\nElse, run plot_normalized_firing_CRF_by_lick_types.\n')
clearCRFdata
% ERRunitsOut=[];
% % j=2;
% for Q=1:length(DATA)
%     j=Q+1
%     if DATA(Q).fileinfo.include==0
%         fprintf('File DATA(%d)) was not included.\n',Q);
%         continue
%     end
    
    
%     for u=1:length(DATA(Q).units)
        
%         if DATA(Q).units(u).include==0
%             fprintf('Unit DATA(%d).units(%d) marked for exclusion.\n',Q,u);
%             ERRunitsOut=[ERRunitsOut; Q,u];
%             continue
%         end
        
        
%         %% Checking for manually added drink type and drink day info:
%         if isempty(DATA(Q).fileinfo.drinkType)% || isnan((DATA(Q).fileinfo.drinkType))
%             %             fprintf('DATA(Q).fileinfo.drinkType is empty. Assuming "ethanol",\n');
%             DATA(Q).fileinfo.drinkType='unknown';
%         end
%         if isnan(DATA(Q).fileinfo.drinkType)
%             DATA(Q).fileinfo.drinkType='unknown';
%         end
        
        
        
        
%         if isfield(DATA(Q).fileinfo, 'drinkDay')==0 %|| (any(isempty(DATA(Q).fileinfo.drinkDay)==1)
%             DATA(Q).fileinfo.drinkDay=NaN;
%         end
        
%         if isempty(DATA(Q).fileinfo.drinkDay)
%             DATA(Q).fileinfo.drinkDay=NaN;
            
%         end
        
       
        
%         if isfield(BURSTunits(Q).units(u).BURSTstats,'percSpikesInBursts')==0
%             P(j).perc_in_bursts_full='ERR';
%             P(j).perc_in_bursts_hr1='ERR';
%             P(j).perc_in_bursts_hr2='ERR';
%             P(j).perc_in_bursts_hr3='ERR';
%             P(j).perc_in_bursts_hr4='ERR';
%         else
%             P(j).perc_in_bursts_full=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.avg;%SpikesInBursts-Full4Hr';
%             P(j).perc_in_bursts_hr1=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour1; %'%SpikesInBursts-Hour1';
%             P(j).perc_in_bursts_hr2=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour2; %'%SpikesInBursts-Hour2';
%             P(j).perc_in_bursts_hr3=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour3; %'%SpikesInBursts-Hour3';
%             P(j).perc_in_bursts_hr4=BURSTunits(Q).units(u).BURSTstats.percSpikesInBursts.burstingByHour.Hour4; %'%SpikesInBursts-Hour4';
%         end
    
        
        
        
%     end
% end

