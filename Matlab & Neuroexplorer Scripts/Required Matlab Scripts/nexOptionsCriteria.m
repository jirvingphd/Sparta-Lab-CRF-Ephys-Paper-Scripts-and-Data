%nexOptionsCriteria.m
%%script meant to load all of the criteria and options structures needed to work with phototagging suite
%     options=struct();
%     options.pre=100;
%     options.post=100;
%     options.fr    = 1;
%     options.tb    = 1;
%     options.binsize = 5;
%     options.chart = 2;
% end
% 
%%CRITERIA FOR JUDGING LIGHT RESPONSE
% criteria=struct();
% criteria.light.intBL_ms=[-20 10];
% criteria.light.intPre_ms=[-5 0];
% criteria.light.intPost_ms=[0 10];
% 
% %%CRITERIA FOR JUDGING LICK RESPONSE
% criteria.lick.intBL_ms=[-100 -50];
% criteria.lick.intPre_ms=[-50 0];
% criteria.lick.intPost_ms=[0 50];
% end%03/20/17

%%OPTIONS STRUCTURE FOR JMI_spkMatFun
options=struct();
options.pre=100;
options.post=100;
options.fr    = 1; %if fr=1, PEH will udivide counts by binsize 
options.tb    = 1;
options.binsize = 5; %was 10
options.chart = 2;

%% Wilcoxon Test Parameters
optionsStats=struct(); %(values in ms)
optionsStats.intervals.statBL=[-100 -50]; %%Baseline period for Wilcoxon test
optionsStats.intervals.statPRE=[-50 0]; %%Pre-Event period for Wilcoxon test
optionsStats.intervals.statPOST=[0 50];

%% Light Response Criteria
criteria=struct();
criteria.light.intBL_ms=[-10 0]; %was -20 at some point
criteria.light.intPre_ms=[-5 0];
criteria.light.intPost_ms=[0 10];

%% Lick Repsonse Criteria
criteria.lick.intBL_ms=[-100 -50];
criteria.lick.intPre_ms=[-50 0];
criteria.lick.intPost_ms=[0 50];