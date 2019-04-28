function [unit_lick_stats,finalLickResponse] = classify_unit_lick_type(unit_lick_stats)
%Classify unit lick responses using the stats in unit_lick_stats
%% %   Comparison 1: PRE V POST LICK RESPONSE
% Q1.A) Does the unit's spike activity change pre vs post lick? (p<=.05)
if unit_lick_stats.tests.PrePost.p<=0.05
    
    % If so...
    % Q1.B) How did the unit's activity change with the lick? What was the sign (+/-) of the change?
    switch sign(unit_lick_stats.tests.PrePost.PrePostChange)
        case 1
            type='inc';
        case 0
            type='0';
        case -1
            type='dec';
    end
    
    %If not...
    %Unit PrePost response type = "NR"
elseif unit_lick_stats.tests.PrePost.p>0.05
    type='NR';
end

% Save the Pre Vs Post type result.
unit_lick_stats.tests.PrePostType=type;
typePrePost=type;
type=[''];

% END (Pre vs Post)

%% Comparison 2: BL V PRE LICK RESPONSIVE
% Q2.A) Does the unit's spike activity change BL vs PRE lick? (p<=.05)
if unit_lick_stats.tests.BLPre.p<=0.05
    % If so...
    % Q2.B) How did the unit's activity change from BL to PRE? What was the sign (+/-) of the change?
    switch sign(unit_lick_stats.tests.BLPre.BLPreChange)
        case 1
            type='inc';
        case 0
            type='0';
        case -1
            type='dec';
    end
    %If not...
    %Unit BL vs PRE response type = "NR"
elseif unit_lick_stats.tests.BLPre.p>0.05
    type='NR';
end

% Save the Pre Vs Post type result.
unit_lick_stats.tests.BLPreType=type;
typeBLPre=type;
type=[''];
% END (BL vs PRE)

%% %% FINAL LICK CLASSIFICATION
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
finalLickResponse=lickTypeComb;
unit_lick_stats.type = finalLickResponse;
% DATA(Q).units(u).finalLickResponse = lickTypeComb;
