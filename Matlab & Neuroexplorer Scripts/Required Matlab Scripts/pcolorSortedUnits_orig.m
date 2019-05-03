function [figObj,saveFullFigData]=pcolorSortedUnits(dataToPlot,PLOTdata,binsize,savefile,figTitle)



if nargin < 5
    figTitle='Default title';
end
if nargin<4
    savefile=0;
end
if nargin <3
    binsize=300;
end
    

hourSec=3600;

%%BELOW IS TAKEN FROM printDetails_rankOrderPlotZmatFull.m and plotMedSplitNormFiring.m

%% NOW CONSTRUCT THE COMBINED FIGURE WITH SUB PANELS
fullFigData=[];
% f=figure('Units','inches','PaperPositionMode','auto','Position',[1 1 6 8])
%                 j=1;
%                 for p=1:length(PLOTdata)
%                 %     fullFigData=PLOTdata(1).blSubDataToPlot;
%                     dataToAdd=PLOTdata(p).blSubDataToPlot;
%                     currResponse=PLOTdata(p).responseType;
% 
%                 %     yTickNames{p}.PLOTdata(p).responseType;
%                     for s=1:size(dataToAdd,1)
%                         yTickNames{j}=currResponse;
%                         j=j+1;
%                     end
%                     emptyRow=nan(1,size(dataToAdd,2));
%                     j=j+1;
%                     fullFigData=vertcat(fullFigData,emptyRow,dataToAdd);
%                 end
%                 saveFullFigData=fullFigData;

% fullFigData=PLOTdata(1).blSubDataToPlot;
% startResponse=PLOTdata(
j=1;
for p=1:length(PLOTdata)
    
    dataToAdd=PLOTdata(p).blSubDataToPlot;
    currResponse=PLOTdata(p).responseType;
        
    for s=1:size(dataToAdd,1)
        yTickNames{j}=currResponse;
        j=j+1;
    end
    %make placeholder nan matrix to match columns of fullFigData with as many
    %rows as data to add
    fillDataToAdd=nan(size(dataToAdd,1),size(fullFigData,2));
    fillDataToAdd(:,1:size(dataToAdd,2))=dataToAdd;
    emptyRow=nan(1,size(fullFigData,2));
    fullFigData=vertcat(fullFigData,emptyRow,fillDataToAdd);
end

%% CIRCUMVENS EVERYTHING ABOVE;
fullFigData=dataToPlot;
saveFullFigData=fullFigData;

% binsize=300;
savefile=0;
figTitle='All CRF Units Combined';
% dataToPlot=flipud(fullFigData);
% dataToPlot=fullFigData;
% dataToPlot=dataToPlots
% yTickNames=fliplr(yTickNames);
%  yTickNames=fliplr(yTickNames);


%% Plotting
tit='All CRF Together';
figObj=figure('name',tit,'Units','inches','PaperPositionMode','auto','Position',[1 1 6 8],'Resize','on')%,...
%         'Colormap',[0.208100006 0.166299999 0.529200017;0.178371429 0.142542854 0.596457183;0.148642868 0.118785717 0.66371429;0.118914291 0.095028572 0.730971456;0.089185715 0.071271427 0.798228562;0.059457146 0.047514286 0.865485728;0.029728573 0.023757143 0.932742834;0 0 1;0.011136363 0.011136363 0.988863647;0.022272727 0.022272727 0.977727294;0.033409089 0.033409089 0.966590881;0.044545453 0.044545453 0.955454528;0.055681814 0.055681814 0.944318175;0.066818178 0.066818178 0.933181822;0.077954538 0.077954538 0.922045469;0.089090906 0.089090906 0.910909057;0.100227267 0.100227267 0.899772704;0.111363627 0.111363627 0.888636351;0.122499995 0.122499995 0.877499998;0.133636355 0.133636355 0.866363645;0.144772723 0.144772723 0.855227232;0.155909076 0.155909076 0.844090879;0.167045444 0.167045444 0.832954526;0.201515138 0.201515138 0.798484802;0.235984832 0.235984832 0.764015138;0.270454526 0.270454526 0.729545414;0.30492422 0.30492422 0.69507575;0.339393944 0.339393944 0.660606027;0.373863637 0.373863637 0.626136363;0.408333331 0.408333331 0.591666639;0.442803025 0.442803025 0.557196975;0.477272719 0.477272719 0.522727251;0.488636374 0.488636374 0.511363626;0.5 0.5 0.5;0.527777791 0.527777791 0.472222209;0.555555582 0.555555582 0.444444448;0.619047642 0.619047642 0.380952388;0.682539701 0.682539701 0.317460328;0.746031761 0.746031761 0.253968269;0.809523821 0.809523821 0.190476194;0.873015881 0.873015881 0.126984134;0.93650794 0.93650794 0.063492067;1 1 0;1 0.993506491 0;1 0.987012982 0;1 0.980519474 0;1 0.974025965 0;1 0.967532456 0;1 0.961038947 0;1 0.954545438 0;1 0.886363626 0;1 0.818181813 0;1 0.75 0;1 0.681818187 0;1 0.613636374 0;1 0.545454562 0;1 0.477272719 0;1 0.409090906 0;1 0.340909094 0;1 0.272727281 0;1 0.204545453 0;1 0.13636364 0;1 0.06818182 0;1 0 0]);
axes1 = axes('Parent',figObj);%,...
%         'CLim',[-7 6]);
    
    
[nUnits, nBinsData]=size(dataToPlot);
nBins=4*hourSec/binsize;
if size(dataToPlot,1)<2
    error('There is only 1 unit to plot. Cannot use pcolor plotting method.\n')
end
hp=pcolor(dataToPlot); %changed from surf plot on 06/02/17
a=gca;
%hp=surf(dataToPlot)
axis tight
view(2);
set(hp,'EdgeColor','k','lineWidth',0.25)
% set(hp,'EdgeColor','k','lineWidth',[])
% shading(gca,'interp')

title(tit)
ylabel('Unit#','fontSize',10,'fontWeight','bold');
xlabel('Time(min)','fontSize',10,'fontWeight','bold');

% c=colorbar;
%REMINDER:
%binsize=300;
%plotTimeMax=10800;
%have nUnits nBins

%%Set x-axis label based on binsize and showing hours
xlim([1 nBins])
% set(gca,'XTick',[1:hourSec/binsize:nBins])
xt=[1,linspace(hourSec/binsize,4*hourSec/binsize,4)];%+1;
set(gca,'XTick',xt)
h=get(gca,'XTick');
xlabels=[0:hourSec:4*hourSec]/60;
% xlabels =num2str(h(:).*(binsize/60)-binsize/60); %weird line
% xlabels=num2str(h(:))
set(gca,'XTickLabel',xlabels);


%%Set y-axis label so the label is mid-bin
%  set(gca,'YTick',(1:nUnits)+0.5,'ticklength',[0 0]);
% set(gca,'YTick',(1:nUnits),'ticklength',[0 0]);
set(gca,'YTick',(1:nUnits)+0.5,'ticklength',[0 0]);


% a = get(gca,'YTickLabel');
% set(gca,'YTickLabel',[],'fontsize',8)
set(gca,'YTickLabel',yTickNames,'fontsize',8)
yt=get(gca,'YTick');
%



% spaces=find(cellfun(@isempty,plotZmatTracker));
hy=get(gca,'YTick');
% set(

%         ylabels=floor(hy(:)); 
%         for i=1:length(
%         ylabels=num2str(ylabels)
%         ylabels(spaces)='';
%         set(gca, 'YTickLabel',ylabels);
% set(gca,'YTickLabel',yLabels) %to name after cell type
%         set(gca,'YTickLabel',floor(yt));


%% CLORMAP SETTINGS
%Create and label colorbar
colormap('jet')
c=colorbar('colormap', jet);

%Calcualte ideal colorbar axis
% cbarCenter=mean(nanmedian(dataToPlot,1));

% cbarCenter=mean(nanmedian(dataToPlot,1));
cbarCenter=median(nanmedian(dataToPlot,1));
stdData=nanstd(dataToPlot,[],1);
cbarSpread=nanmean(stdData);
% caxis([min(dataToPlot(:)) max(dataToPlot(:))]); %,'CLim',[-6 7];) 

% caxis([(cbarCenter-3*cbarSpread) (cbarCenter+3*cbarSpread)]); %,'CLim',[-6 7]);
% caxis([min(min(dataToPlot)) max(max(dataToPlot))]);

%Create label for colorbar
ylabel(c,'Normalized Firing Rate Z','fontSize',10,'fontWeight','bold');


% cbarSpread=nanstd(dataToPlot);
% cmax=max(cbarSpread);
% colorRange=[cbarCenter-cmax, cbarCenter+cmax];
% colorRange=[cbarCenter-cmax, cbarCenter+cmax];
% colorbar('Limits',[floor(colorRange(1)) ceil(colorRange(2))]);
%  colorbar('Limits',[min(dataToPlot),max(dataToPlot)]);
% set(gca, 'CLim', [floor(colorRange(1)) ceil(colorRange(2))]);
% set(gca, 'Limits', [floor(colorRange(1)) ceil(colorRange(2))]);
% This version allowed greater range of hot coloars
% set(gca, 'CLim', [floor(colorRange(1)) ceil(colorRange(2))*2]);
[date]=clock;
dateName=sprintf('%02d%02d%04d',date(2),date(3),date(1));
savefigtitle=sprintf('Norm Firing Colorplot - %s',[figTitle dateName]);
if savefile==1
figObj=gcf;
print(figObj,'-dpng','-r300',savefigtitle);
print(figObj,'-dpdf','-painters')
savefile(figObj,savefigtitle);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%REMINDER:
%binsize=300;
%plotTimeMax=10800;
%have nUnits nBins

%%Set x-axis label based on binsize and showing hours

