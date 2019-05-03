report={};
report{1,1} = 'Q_u';
report{1,2} = 'light_type';
report{1,3}='spike_p_val';
report{1,4}='spike_p_sig';

report{1,5}='spikes_rate_change';
report{1,6} = 'wave_p_val';
report{1,7} = 'wave_p_sig';
report{1,8} = 'waves_pearson_R';
row = 2;
for Q=1:length(DATA)
    for u=1:length(DATA(Q).units)
        
        report{row,1} = [Q,u];
        report{row,2} = DATA(Q).units(u).finalLightResponse;%'light_type';
        % spikes
        spike_p = DATA(Q).units(u).lightResponse.tests.PrePost.p;%'PreVsPost_pulse_spikes_p_val';
        report{row,3}=spike_p;%'PreVsPost_pulse_spikes_p_val';
        report{row,4}= spike_p<.05;
        report{row,5}=DATA(Q).units(u).lightResponse.tests.PrePost.PrePostChange;%'PreVsPost_pulse_spikes_rate_change';
        
        % waves
        if any(isempty(DATA(Q).units(u).lightResponse.tests.waves))
            report{row,6} = NaN;
            report{row,7} = false;
            report{row,8} = NaN;
        else
            
            wave_p = DATA(Q).units(u).lightResponse.tests.waves.corrcoefPval;%'waves:p_val';
            report{row,6} = wave_p;%'waves:p_val';
            report{row,7} = wave_p<.05;
            report{row,8} =  DATA(Q).units(u).lightResponse.tests.waves.xcorrR;%'waves:pearson_R';
       
        end
%         report{row,1} = [Q,u];
%         report(row,2:width(light_type_response.spike_tests) = struct2table(light_type_response.spike_tests,'AsArray',true);
%         report{row,3} = struct2table(light_type_response.wave_tests,'AsArray',true);
        row=row+1;
    end
end

REPORT_light_classification= cell2table(report(2:end,:),'VariableNames',report(1,:))
%         lick_type = DATA(Q).units(u).finalLickResponse;
        