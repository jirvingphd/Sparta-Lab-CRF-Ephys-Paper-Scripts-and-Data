function [unit_light_stats,finalLightResponse] = classify_unit_light_type(unit_light_stats)
%Classify_unit_light_lick will use the stat results in the
%units.lightResponse structure to determine what light-response
%classification it belngs to. 

if unit_light_stats.tests.PrePost.p<=0.05
    % 1B) How did the unit's activity change with the light pulse? What was the sign (+/-) of the change pre vs post?
    switch sign(unit_light_stats.tests.PrePost.PrePostChange)
        case 1
            type='inc';
        case 0
            type= '0';
        case -1
            type='dec';
    end
    
    % If not...
    % Unit light response type = "NR"
elseif unit_light_stats.tests.PrePost.p>0.05
    type='NR';
end


%% 2) Was the cross correlation between light-evoked and non-evoked waveforms significant? (cross corr R value >0.9)
% First, make sure current unit has waveform data, if not
if isfield(unit_light_stats.tests,'waves')==0 || isempty(unit_light_stats.tests.waves)==1;
    unit_light_stats.tests.waves=[];
    CRF=false;
    
    % 3) Final result: Did the firing rate increase  pre vs post AND was the waveform  xcorr R value is >0.9??
elseif strcmp(type,'inc') && (unit_light_stats.tests.waves.xcorrR>0.9 )
    % if so, classify as CRF.
    CRF=true;
else
    % if not, classify as non-CRF
    CRF=false;
end


%% RENAME the lightTypes to match later script references.
switch type
    case 'inc'
        lightType='excited';
        
    case 'dec'
        lightType='inhibited';
        
    case 'NR'
        lightType='NR';
end

%% SAVE the light type results to unit_lightResponse: .type and .CRF
unit_light_stats.type     =   lightType;
unit_light_stats.CRF      =   CRF;
% FILL IN FINAL LICK RESPONSE CLASSIFICATION
if CRF==true
   finalLightResponse='CRF';
elseif CRF==false
    finalLightResponse=lightType;
end
