%% plotNormFiringFromSORTtracker_CRF.m
% THIS IS JUST THE PLOTTING PORTIONS OF rankOrderClusterPlotZmatFiring. It should be run after testClusterdata.m, which is run after rankOrderClusterPlotZmatFiring.
%It is currently meant to only be applied to one drink type's DATA file at
%a time. and then put together by user elsewhere
% fprintf('RATEScut has been filled with all CRF neuron data.');
% endScript=input('Exit script? \n Type Y to end, N to continue.\n','s');
if exist('PLOTdata','var')==0
    PLOTdata=struct();
end
binsize=300; %how many seconds does each cell represent
baselinePeriod=1800;%will be divided by binsize
blEnd=baselinePeriod/binsize;
if exist('SORTtracker_CRF','var')==0
    SORTtracker_CRF = SORTtracker.CRF;
end
%% Prepare dataSortedToPlot matrices and add to SORTtracker_CRF
responseFields=fieldnames(SORTtracker_CRF);
for r = 1:length(responseFields)
    clearvars dataSortedToPlot dataSplit* index* idxQU* idxQU_Split* sorted* curr* subfields dataConcatToPlot dataSortedToPlot blToSub idxQU_ConcatToPlot dataSplitSortedMat
    
    currResponse=responseFields{r};
    subfields=fieldnames(SORTtracker_CRF.(currResponse));
    
    %%%CREATE dataSortedToPlot VAR FOR PCOLOR
    
    %     dataConcatToPlot=vertcat(SORTtracker_CRF.(currResponse).sortedData.dataSplit.dataSplitSortedMat);
    %     dataConcatToPlotUnflipd=dataConcatToPlot;
    %     dataSortedToPlot=flipud(SORTtracker_CRF.(currResponse).sortedData.dataToPlot_blSubdSorted);
    %     idxQU_ConcatToPlot=vertcat(SORTtracker_CRF.(currResponse).sortedData.rdataSplit.idxQU_Split);
    
    
    %     SORTtracker_CRF.(responseFields{r}).sortedData.dataReadyToPlot=dataSortedToPlot;
    
    PLOTdata(r).responseType=responseFields{r};
    %     PLOTdata(r).dataToPlot=dataSortedToPlot;
    %     PLOTdata(r).indexQUplot=idxQU_ConcatToPlot;
    
    
    
    blSubDataToPlot=SORTtracker_CRF.(currResponse).sortedData.sortedRateDataToPlot;
    
    PLOTdata(r).blSubDataToPlot= blSubDataToPlot; %HERE IS BASELINE SUB OF 30MINS
    clearvars blDataToPlot blToSub
    
    % ADD THE PERC SPIKES HERE
    %     blPercToSub=nanmean(dataSortedToPlot(:,1:blEnd),2); %know that the first 5 5min bins should be average so (1:6)
    %     for b=1:size(dataSortedToPlot,1)
    %         blDataToPlot(b,:)=dataSortedToPlot(b,:)-blPercToSub(b);
    %     end
    %     SORTtracker_CRF.(responseFields{r}).sortedData.blSubdataReadyToPlot=blDataToPlot;
    
    
    
    clearvars dataSortedToPlot idx* index* dataSplit* sorted*
    fprintf('PLOTdata has been created and populated.\n');
end

%% Remove Outliers
% 
% for p=1:length(PLOTdata)
%     clearvars testDATA nonOutliers outliersRemoved
%     testData=PLOTdata(p).blSubDataToPlot;
%     PLOTdata(p).originalData=PLOTdata(p).blSubDataToPlot;
%     nonOutliers=~isoutlier(testData,1);
%     
%     cleanedData=testData.*nonOutliers;
%     [outRows, outCols] = find(nonOutliers==0);
%     outliersRemoved=testData.*~nonOutliers;
%     PLOTdata(p).cleaned=cleanedData;
%     PLOTdata(p).numOutliers=length(outRows);
%     PLOTdata(p).outliersRemoved=outliersRemoved;
%     PLOTdata(p).blSubDataToPlot=cleanedData;
%     fprintf('Cleaned data still has 0 in place of outliers. \n Revist and calculate columnwise means to fill.\n\n')
% end

%% NOW CONSTRUCT THE COMBINED FIGURE WITH SUB PANELS
fullFigData=PLOTdata(1).blSubDataToPlot;
for p=2:length(PLOTdata)
    
    dataToAdd=PLOTdata(p).blSubDataToPlot;
    fillDataToAdd=nan(size(dataToAdd,1),size(fullFigData,2));
    
    fillDataToAdd(:,1:size(dataToAdd,2))=dataToAdd;
%     emptyRow=nan(1,size(dataToAdd,2));
    emptyRow=nan(1,size(fullFigData,2));
%     fullFigData=vertcat(fullFigData,emptyRow,dataToAdd);
    fullFigData=vertcat(fullFigData,emptyRow,fillDataToAdd);
end
saveFullFigData=fullFigData;
% binsize=300;
% savefile=1;
fprintf('savefile has been set to 0.\n No figure will be saved...\n')
savefile=0;
figTitle='All CRF Units Combined';


% [figObj,plottedData]=pcolorSortedUnits(fullFigData,PLOTdata,binsize,savefile,figTitle);
[figObj]=pcolorSortedUnits_orig(fullFigData,PLOTdata,binsize,savefile,figTitle);

h=gcf;
a=gca;

[date]=clock;
dateName=sprintf('%02d%02d%04d',date(2),date(3),date(1));
savefigtitle=sprintf('Norm Firing Colorplot - %s',[figTitle dateName]);
if savefile==1
    figOut=gcf;
    print(figObj,'-dpng','-r300',savefigtitle);
    %     print(figObj,'-deps','-r300',savefigtitle);
    
    %     saveas(gcf,savefigtitle,'eps')%,'-r300');
    print(figObj,'-dpdf','-painters',savefigtitle)
    saveas(gcf,savefigtitle,'fig')
    saveas(gcf,savefigtitle,'epsc')
end
% clearvars dataToAdd bin* b conc* check* curr* data* date* full* p r res response* save* test* sub* vars fig* empty* bl* baseline*

% clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER*
clearCRFdata