%%% nexDATAclassificationFixWIP2.m
% JMI 10/01/18

%% This script will loop through all files and units in DATA structure and use event times and spike times
% to perform Wilcoxon signrank tests (in a sub-function) on time periods "pre, post, BL"(defined in the "criteria" structure below)
% MUST FIRST run NexCombinedDATAstruct.m and extract DATA structure from Nex Files.

% Required input:
%   DATA structure created by NexCombinedDATAstruct.m
%   NOTE: The waveform cross correlation statistics were previously calculated and just used again for classification here.

% Requires sub-functions:
%   -nexTestUnitResponsesFixWIP_FinFixWIP
%   -JMI_spkMatFun

% Output:
%   Updated DATA structure with new fields populated:
%    -DATA(Q).units(u).lightResponse.type;
%    -DATA(Q).units(u).lightResponse.CRF;




%%OPTIONS STRUCTURE FOR JMI_spkMatFun
if isstruct('options')==0
    options=struct();
    options.pre=100;
    options.post=100;
    options.fr    = 1;
    options.tb    = 1;
    options.binsize = 5;
    options.chart = 2;
end

%%CRITERIA FOR JUDGING LIGHT RESPONSE
if isstruct('criteria')==0
    criteria=struct();
    criteria.light.intBL_ms=[-20 10];
    criteria.light.intPre_ms=[-5 0];
    criteria.light.intPost_ms=[0 10];
    
    %%CRITERIA FOR JUDGING LICK RESPONSE
    criteria.lick.intBL_ms=[-100 -50];
    criteria.lick.intPre_ms=[-50 0];
    criteria.lick.intPost_ms=[0 50];
end





%% START LOOPING THROUGHT EVERy DATA FILE
for Q = 1:length(DATA)
    
    % Take the current EventPulse and EventLick for current DATA file.
    currEventPulse      =   DATA(Q).fileinfo.events.EventPulse;
    currEventLick       =   DATA(Q).fileinfo.events.EventLick;
    
    % Skip DATA(Q) files that have less than 20 licks.
    if length(currEventLick)<20
        msg=sprintf('currEventLick<20 for DATA(%d). Skipping.\n',Q);
        warning(msg)
        continue
    end
    
    
    %% CALCULATE WILCOXON SIGN RANK TEST FOR LIGHT AND LICK RESPONSES FOR EACH UNIT(u)
    for u=1:length(DATA(Q).units)
        
        
        %Select current spike timestamps, skip unit if there are no spikes.
        currSpikes=DATA(Q).units(u).ts;
        if isempty(currSpikes)
            msg=sprintf('DATA(%d).units(%d) has 0 spikes. Skipping.\n',Q,u);
            warning(msg);
            continue
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% LIGHT RESPONSE CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%
        optionsStats.intervals  =   criteria.light;
        
        % Send the event times, spike times, and options structures to custom function: nexTestUnitResponsesFixWIP_FinFixWIP
        %will construct perievent raster/histograms then calculate signrank results for the Pre Post and BL periods defined in options
        [WilcStatsLight optionsStatsPulse options]   =   nexTestUnitResponsesFixWIP_Fin(currSpikes,currEventPulse,optionsStats,options);
        
        
        % Extract and save the Waveform analysis results calculated in NexCombineDATAstruct
        if isfield(DATA(Q).units(u).lightResponse.tests,'waves')
            
            WilcStatsLight.waves=DATA(Q).units(u).lightResponse.tests.waves;
            
        else %Can't rememmber the exact error that would occurr that made me add the section below to address missing waves data
            
            DATA(Q).units(u).lightResponse.tests.waves.xcorrR=0;
            DATA(Q).units(u).lightResponse.CRF=false;
            
        end
        
        %Save the data to DATA.units.lightResponse
        DATA(Q).units(u).lightResponse.tests    =   WilcStatsLight;
        clearvars WilcStatsLight
        
        
        
        %% LOGIC TESTS FOR LIGHT CLASSIFICATION "TYPE"
        
        % 1A) Does the unit's spike activity change pre vs post laser pulse? (p<=.05)
        if DATA(Q).units(u).lightResponse.tests.PrePost.p<=0.05
            
            % If so...
            % 1B) How did the unit's activity change with the light pulse? What was the sign (+/-) of the change pre vs post?
            switch sign(DATA(Q).units(u).lightResponse.tests.PrePost.PrePostChange)
                case 1
                    type='inc';
                case 0
                    type= '0';
                case -1
                    type='dec';
            end
            
            % If not...
            % Unit light response type = "NR"
        elseif DATA(Q).units(u).lightResponse.tests.PrePost.p>0.05
            type='NR';
        end
        
        
        % 2) Was the cross correlation between light-evoked and non-evoked waveforms significant? (cross corr R value >0.9)
        % First, make sure current unit has waveform data, if not
        if isfield(DATA(Q).units(u).lightResponse.tests,'waves')==0 || isempty(DATA(Q).units(u).lightResponse.tests.waves)==1;
            DATA(Q).units(u).lightResponse.tests.waves=[];
            CRF=false;
            
            % 3) Final result: Did the firing rate increase  pre vs post AND was the waveform  xcorr R value is >0.9??
        elseif strcmp(type,'inc') && (DATA(Q).units(u).lightResponse.tests.waves.xcorrR>0.9 )
            % if so, classify as CRF.
            CRF=true;
        else
            % if not, classify as non-CRF
            CRF=false;
        end
        
        
        % RENAME the lightTypes to match later script references.
        switch type
            case 'inc'
                lightType='excited';
                
            case 'dec'
                lightType='inhibited';
                
            case 'NR'
                lightType='NR';
        end
        
        % SAVE the light type results to DATA(Q).units(u).lightResponse: .type and .CRF
        DATA(Q).units(u).lightResponse.type     =   lightType;
        DATA(Q).units(u).lightResponse.CRF      =   CRF;
        
        %%% FILL IN FINAL LICK RESPONSE CLASSIFICATION
        DATA(Q).units(u).finalLightResponse=[''];
        if CRF==true
            DATA(Q).units(u).finalLightResponse='CRF';
        elseif CRF==false
            DATA(Q).units(u).finalLightResponse=lightType;
            lightType=[]; type=[];    CRF=[];
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% LICK RESPONSE CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%
        optionsStats.intervals=criteria.lick;
        
        % Send the event times, spike times, and options structures to custom function: nexTestUnitResponsesFixWIP_FinFixWIP
        % will construct perievent raster/histograms then calculate signrank results for the Pre Post and BL periods defined in options
        [WilcStatsLick optionsStatsLick options]=nexTestUnitResponsesFixWIP_Fin(currSpikes,currEventLick,optionsStats,options);
        
        DATA(Q).units(u).lickResponse.tests=WilcStatsLick;
        clearvars WilcStatsLick
        
        
        %% LOGIC TESTS FOR LICK CLASSIFICATION "TYPE"
        
        %%%   Comparison 1: PRE V POST LICK RESPONSE
        
        % Q1.A) Does the unit's spike activity change pre vs post lick? (p<=.05)
        if DATA(Q).units(u).lickResponse.tests.PrePost.p<=0.05
            
            % If so...
            % Q1.B) How did the unit's activity change with the lick? What was the sign (+/-) of the change?
            switch sign(DATA(Q).units(u).lickResponse.tests.PrePost.PrePostChange)
                case 1
                    type='inc';
                case 0
                    type='0';
                case -1
                    type='dec';
            end
            
            %If not...
            %Unit PrePost response type = "NR"
        elseif DATA(Q).units(u).lickResponse.tests.PrePost.p>0.05
            type='NR';
        end
        
        % Save the Pre Vs Post type result.
        DATA(Q).units(u).lickResponse.tests.PrePostType=type;
        typePrePost=type;
        type=[''];
        
        %END (Pre vs Post)
        
        
        %%%   Comparison 2: BL V PRE LICK RESPONSIVE
        
        % Q2.A) Does the unit's spike activity change BL vs PRE lick? (p<=.05)
        if DATA(Q).units(u).lickResponse.tests.BLPre.p<=0.05
            
            % If so...
            % Q2.B) How did the unit's activity change from BL to PRE? What was the sign (+/-) of the change?
            switch sign(DATA(Q).units(u).lickResponse.tests.BLPre.BLPreChange)
                case 1
                    type='inc';
                case 0
                    type='0';
                case -1
                    type='dec';
            end
            
            %If not...
            %Unit BL vs PRE response type = "NR"
        elseif DATA(Q).units(u).lickResponse.tests.BLPre.p>0.05
            type='NR';
        end
        
        % Save the Pre Vs Post type result.
        DATA(Q).units(u).lickResponse.tests.BLPreType=type;
        typeBLPre=type;
        type=[''];
        %%
        
        %END (BL vs PRE)
        
        
        
        %%%% FINAL LICK CLASSIFICATION
        
        % Q3) Use lick comparison types from comparison 1 and 2 to determine final classification.
        
        % For units that increased rate BL to Pre...
        if strcmp(typeBLPre,'inc')
            
            % What was their Pre Post change type?
            switch typePrePost
                
                case 'inc'
                    lickTypeComb='predictiveExcited';
                case 'dec'
                    lickTypeComb='predictive';
                case '0'
                    lickTypeComb='NaN';
                    fprintf('lickTypeComb=NaN!\n')
                case 'NR'
                    lickTypeComb='predictive';
                    
            end
            
            % For units that did NOT increase rate BL to Pre...
        else
            
            % What was their Pre Post change type?
            switch typePrePost
                
                case 'dec'
                    lickTypeComb='inhibited';
                case 'inc'
                    lickTypeComb='excited';
                case 'NR'
                    lickTypeComb='NR';
                case '0'
                    lickTypeComb='NR';
                    fprintf('licktTypeComb, case 0=NR.\n')
                    
            end
        end
        
        % Save the final lick type combined classification
        DATA(Q).units(u).lickResponse.type=lickTypeComb;
        DATA(Q).units(u).finalLickResponse=lickTypeComb;
        clearvars type* lickTypeComb CRF
    end
end
% end
% clearvars -except DATA STATS options* optionsStats criteria RESULTS ERR* BURST*
clearCRFdata

fprintf('Main script finished, running: renameDATAfileinfoDrinkTypeDay to ensure naming conventions consistent in DATA.fileinfo\n')
renameDATAfileinfoDrinkTypeDay

run_fill_drink_day = input('Enter drink type information?(y/n):\n','s')
if strcmpi(run_fill_drink_day,'y')
    fprintf('Ok. Running nexDATA_fillDrinkDay...\n');
    nexDATA_fillDrinkDay
end

fprintf('FINISHED.\nFor full workflow, run calc_spike_binned_data_remove_outliers.m\n');
fprintf('OR if only want counts of unit responses: count_unit_responses.m \n');
