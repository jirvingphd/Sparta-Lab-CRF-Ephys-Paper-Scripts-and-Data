
function [WilcStats, optionsStats, options]=unit_responses_stat_tests(currSpikes,currEvent,optionsStats,options)
%% This function accepts a vector of spiketimes, eventtimes, options structure for JMI_spikeMatFun, and optionsStats structure for Wilcoxon intervals. 
%Requires  function JMI_spkMatFun
%%Inputs:
%	currSpikes	= vector of spike timestamps (in seconds)
%	currEvent	= vector of event timestamps (in seconds)
%	options structure for JMI_spikeMatFun
%		options.pre=100; 
%		options.post=100;
%		options.fr    = 1;
%		options.tb    = 1;
%		options.binsize = 5;
%		options.chart = 2;
%	optionsStats (values in ms)
%		optionsStats.intervals.statBL=[-100 -50]; %%Baseline period for Wilcoxon test
%		optionsStats.intervals.statPRE=[-50 0]; %%Pre-Event period for Wilcoxon test
%		optionsStats.intervals.statPOST=[0 50]; %%Post-Event period for Wilcoxon test
%%Outputs:
%	WilcStats structure
%		WilcStats.BaselinePre.p=p;
%		WilcStats.BaselinePre.h=h;
%		WilcStats.BaselinePre.stats=stats;
%		WilcStats.BaselinePost.p=p;
%		WilcStats.BaselinePost.h=h;
%		WilcStats.BaselinePost.stats=stats;

%%%Change the interval fields below for time (in ms) that should be analyzed for each Wilcoxon test
% if nargin < 4
% 	options=struct();
% 	options.pre=100;
% 	options.post=100;
% 	options.fr    = 1;
% 	options.tb    = 1;
% 	options.binsize = 5;
% 	options.chart = 2;
	
% end

%%Fill in options structure if it doesn't exist
if nargin < 3
	%optionsStats (values in ms)
%     sprintf('No optionsStats structure provided. Using default values:')
    % nexOptionsCriteria
	% 		optionsStats.intervals.statBL=[-100 -50]; %%Baseline period for Wilcoxon test
	% 		optionsStats.intervals.statPRE=[-50 0]; %%Pre-Event period for Wilcoxon test
	% 		optionsStats.intervals.statPOST=[0 50];

end

if nargin < 2
	error('Missing input currSpikes or currEvent vector')
end

WilcStats=struct();

%%	Fill in values from options structure
% pre     =  options.pre;
% post    =  options.post;
% fr      =  options.fr;
% tb      =  options.tb;
% binsize =  options.binsize;
% chart   =  options.chart;

%%%Create Wilcoxon intervals with timeBins to determine indices for selecting data to compare
% WilcBLint	= optionsStats.intervals.intBL_ms;
% WilcPreInt	= optionsStats.intervals.intPre_ms;
% WilcPostInt	= optionsStats.intervals.intPost_ms;
% timeBins=[-pre:binsize:post-binsize];
%%	Fill in values from code below:

pre     =  100;%start of timeinterval(pre-event), left-inclusive
post    =  100;%end of timeinterval(post-event), right-exlcuded(post-binsize)
binsize = 5;
timeBins=[-pre:binsize:post-binsize];

fr      =  1; % firing rate. if 1 then stats are divided by time to get rates
tb      =  1;
chart   =  2;

% Time Periods for Wilcoxon Signed Rank Test
WilcBLint	= [-100, -50];
WilcPreInt	= [-50, 0];
WilcPostInt	= [0, 50];

%%Create spkMat - Matrix of PEH counts by trial 
% [spkMat options] = JMI_spkMatFun(currSpikes,currEvent,options);
[spkMat ~] = JMI_spkMatFun(currSpikes,currEvent);%,options);


%%FIND THE INDICES TO USE FOR PULLING OUT RIGHT ARRAYS TO RUN WILCOXON SIGNTEST ON;
%BASELINE

	if (abs(WilcBLint(2)-WilcBLint(1)))==binsize
	    ind_WilcBase(1:2)=find(timeBins==WilcBLint(1));
	else    
	ind_WilcBase(:,1)=find(timeBins==WilcBLint(1));
	ind_WilcBase(:,2)=find(timeBins==WilcBLint(2));
	end

	spkMatWilcBL=spkMat(:,ind_WilcBase(1):ind_WilcBase(2));
	intLengthBL=(WilcBLint(2)-WilcBLint(1));

%PRE-EVENT    
	if abs(WilcPreInt(2)-WilcPreInt(1))==binsize
	    ind_WilcPre(1:2)=find(timeBins==WilcPreInt(1));
	else   
	    ind_WilcPre(:,1)=find(timeBins==WilcPreInt(1));
	    ind_WilcPre(:,2)=find(timeBins==WilcPreInt(2));
	end
	spkMatWilcPre=spkMat(:,ind_WilcPre(1):ind_WilcPre(2));
	intLengthPre=(WilcPreInt(2)-WilcPreInt(1));

%POST-EVENT
	if (abs(WilcPostInt(2)-WilcPostInt(1)))==binsize
	    ind_WilcPost(1:2)=find(timeBins==WilcPostlineInt(1));
	else   
	    ind_WilcPost(:,1)=find(timeBins==WilcPostInt(1));
	    ind_WilcPost(:,2)=find(timeBins==WilcPostInt(2));
	end
	spkMatWilcPost=spkMat(:,ind_WilcPost(1):ind_WilcPost(2));
	intLengthPost=(WilcPostInt(2)-WilcPostInt(1));



%%%Run the Wilcoxon ranked sign tests 
%%Normalize counts per bin by firing rate / sec
if fr==1
	statMatBL=sum(spkMatWilcBL,2)./(intLengthBL);
	statMatPre=sum(spkMatWilcPre,2)./(intLengthPre);
	statMatPost=sum(spkMatWilcPost,2)./(intLengthPost);
else 
	statMatBL 	= sum(spkMatWilcBL,2);
	statMatPre 	= sum(spkMatWilcPre,2);
	statMatPost 	= sum(spkMatWilcPost,2);
end

[p, h, stats]=signrank(statMatBL,statMatPre); % meaning statMatBL-statMatPre has a median different from zero 
% WilcStats.BLPre.BLPreChange=sum(statMatBL)-sum(statMatPre); %%BACKWARD?!
WilcStats.BLPre.BLPreChange=sum(statMatPre)-sum(statMatBL); 
WilcStats.BLPre.p=p;
WilcStats.BLPre.h=h;
WilcStats.BLPre.stats=stats;

[p, h, stats]=signrank(statMatBL,statMatPost);
% WilcStats.BLPost.BLPostChange=sum(statMatBL)-sum(statMatPost);%%%BACKWARD?!
WilcStats.BLPost.BLPostChange=sum(statMatPost)-sum(statMatBL);
WilcStats.BLPost.p=p;
WilcStats.BLPost.h=h;
WilcStats.BLPost.stats=stats;

[p, h, stats]=signrank(statMatPre,statMatPost);
% WilcStats.PrePost.PrePostChange=sum(statMatPost)-sum(statMatPre);%%BACKWARD?!
WilcStats.PrePost.PrePostChange=sum(statMatPost)-sum(statMatPre);
WilcStats.PrePost.p=p;
WilcStats.PrePost.h=h;
WilcStats.PrePost.stats=stats;