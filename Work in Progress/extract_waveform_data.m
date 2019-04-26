%extract_waveform_data.m
WAVES = struct();
disp('This code was added to check_excluded_units.m')
%% START LOOPING THROUGHT EVERy DATA FILE
for Q = 1:length(DATA)
    WAVES(Q).fileinfo=DATA(Q).fileinfo;
    
    %% CALCULATE WILCOXON SIGN RANK TEST FOR LIGHT AND LICK RESPONSES FOR EACH UNIT(u)
    for u=1:length(DATA(Q).units)
        WAVES(Q).units(u).idx=[Q,u];
        if isfield(DATA(Q).units,'lightResponse')
            
            WAVES(Q).units(u).finalLightResponse = DATA(Q).units(u).finalLightResponse;
            WAVES(Q).units(u).finalLickResponse = DATA(Q).units(u).finalLickResponse;
            WAVES(Q).units(u).include = DATA(Q).units(u).include;
            
            WAVES(Q).units(u).filteredWaves = DATA(Q).units(u).filteredWaves;
            WAVES(Q).units(u).lightResponse = DATA(Q).units(u).lightResponse;

        end
    end
end

