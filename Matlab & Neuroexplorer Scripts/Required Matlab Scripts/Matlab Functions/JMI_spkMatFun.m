%JMI_spkMatFun.m
function [spkMat options] = JMI_spkMatFun(currSpikes,currEvent,options)
%%Produced a trial by trial perievent histogram to be used for Wilcoxon signed rank test
% Inputs: 

spxtimes  = 1000*currSpikes;
eventTimes = 1000*currEvent;

%%Default values (times are in seconds) or user-specified varargin
if nargin < 3
  options=struct();
  options.pre=100;
  options.post=100;
  options.fr    = 1;
  options.tb    = 1;
  options.binsize = 5; 
  options.chart = 2;
  else if nargin < 2
    error('Missing currEvent vector or currSpikes vector');
  end;
end;
%spkTotal=[];
spkMat=[];		 %complete matrix of bin counts per trial-output as spkHistTrials


pre     =  options.pre;
post    =  options.post;
fr      =  options.fr;
tb      =  options.tb;
binsize =  options.binsize;
chart   =  options.chart;

timeBins=[-pre:binsize:post-binsize]; %Post-binsize? 

% options.timeTickLabels=timeBins;
% options.
% psth=zeros(numel(timeBins)-1,2);%Create the psth matrix,pre-filled with zeros and the first column equal to left edge of bins
% psth(:,1)=timeBins(1:numel(timeBins)-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%from calcWFcorrelationNexTrigd
tsToTest=spxtimes;
%events={'EventPulse'};
%for t=1:length(events) %events?
% currIntName=intList{t};
% int=eval(currIntName);
resMatsize=[-pre:binsize:post-binsize];
%idxResMat=[]

    
%%%For each peri-event interval, check all spiketimes against the interval
spkMat=zeros(length(eventTimes),length(timeBins));
spkMat(:)=NaN;

for i=1:length(eventTimes)
  %define the interval based on ith event and pre/post
  currIntToTest=[eventTimes(i)-pre, eventTimes(i)+post];

  [ind_foundTS] = find(tsToTest >= currIntToTest(1) & tsToTest < currIntToTest(2));%Index of passing timestamps
 
  resFoundSpikeTimes=tsToTest(ind_foundTS)';
  spkMat(i,:)=histc(resFoundSpikeTimes,[currIntToTest(1):binsize:currIntToTest(2)-binsize]);

end
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% %% pre-allocate for speed
% if binsize>1
%   psth = zeros(ceil(pre/binsize+post/binsize),2);         % one extra chan for timebase
%   psth (:,1) = (-1*pre:binsize:post-1);           % time base
% elseif binsize==1
%   % in this case, pre+post+1 bins are generate (ranging from pre:1:post)
%   psth = zeros(pre+post+1,2);
%   psth (:,1) = (-1*pre:1:post);       % time base
% end
% %% construct psth & trialspx
% trialspx = cell(numel(eventTimes),1);
% for i = 1:numel(eventTimes)
%   clear spikes
%   spikes = spxtimes - eventTimes(i);                           % all spikes relative to current trigtime
%   trialspx{i} = round(spikes(spikes>=-pre & spikes<=post));   % spikes close to current trigtime
%   if binsize==1 % just to make sure...
%     psth(trialspx{i}+pre+1,2) = psth(trialspx{i}+pre+1,2)+1;    % markers just add up
%     % previous line works fine as long as not more than one spike occurs in the same ms bin
%     % in the same trial - else it's omitted
%   elseif binsize>1
%     try
%       for j = 1:numel(trialspx{i})
%         psth(floor(trialspx{i}(j)/binsize+pre/binsize+1),2) = psth(floor(trialspx{i}(j)/binsize+pre/binsize+1),2)+1;
%       end
%     end
%   end
% end
% %% normalize to firing rate if desired
% if fr==1
%   psth (:,2) = (1/binsize)*1000*psth(:,2)/numel(eventTimes);
% end
% %% remove time base
% if tb==0
%   psth(:,1) = [];
% end






















% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%% mraster.m 

% %% preallocate
% rastmat = zeros(numel(trialspx),pre+1+post);
% timevec = -pre:1:post;  
% %% generate raster
% for i = 1:numel(trialspx)
%   rastmat(i,trialspx{i}+pre+1) = 1;
% end
% %% plot raster
% if chart==1
%   figure('name','peri-stimulus time histogram','units','normalized','position',[0.3 0.4 0.4 0.2])
%   for i = 1:numel(trialspx)
%     % plot rastmat(i,rastmat(i,:)~=0) rather than rastmat(i,:) so that zero entries are not plotted, too
%     plot(timevec(rastmat(i,:)~=0),rastmat(i,rastmat(i,:)~=0)*i,'k.','MarkerSize',4),hold on
%   end
%   axis([-pre+10 post+10 0.5 numel(trialspx)+0.5])
%   xlabel('time (ms)'),ylabel('trials')
% end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%