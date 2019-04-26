 function [zScoredData,blMeanForZ,blStdForZ]=calcOutlierZscores(unitsByTimeMat,graph,binsize,baselinePeriod)
%This function accepts a data matrix that is a time series of multiple
%units/trials, where rows = units/trials and columns=timepoints.
%% Steup
if nargin<4
baselinePeriod=1800;%will be divided by binsize
end
if nargin<3
binsize=300; %how many seconds does each cell represent
end
if nargin<2
    graph=0;
end

% currDataMatRaw=testData;
currDataMatRaw=unitsByTimeMat;
blEnd=baselinePeriod/binsize;

%% To use baseline mean and std to calculate Z-scores
% blMeanForZ=nanmean(currDataMatRaw(:,1:blEnd),2);
currData=currDataMatRaw(:,1:blEnd);
[blMeanForZ]=nanmean(currData,2);
[blStdForZ]=nanstd(currData,[],2);

currDataSubBl=(currDataMatRaw-blMeanForZ);
blCalcZscoreMat=currDataSubBl./blStdForZ;

% for z=1:size(currDataMatRaw,1)
%     currUnitRaw=[];
%     currUnitZscore=[];
%     currUnitRaw=currDataMatRaw(z,:);
% %     blMeanForZ=blMeanForZ(z);
% % blStdForZ= blStdForZ(z);
%     
%     if blStdForZ(z)==0
%         currUnitZscore=nanstd(currDataMatRaw(:,1:2*blEnd),0,2);
%     else
%         currUnitZscore=[(currUnitRaw-blMeanForZ(z))./blStdForZ(z)];
%     end
%     blCalcZscoreMat(z,1:length(currUnitZscore))=currUnitZscore;
% end

zScoredData=blCalcZscoreMat;
if graph==1
    plot(zScoredData')
end 