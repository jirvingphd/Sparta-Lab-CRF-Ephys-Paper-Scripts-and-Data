function [cleanData,include,outliers]=replaceBinnedOutliers(binnedDataToClean, outliersStruct, fillMethod1, fillMethod2)
%replaceBinnedOutliers [cleanData]=replaceBinnedOutliers(binnedDataToClean, outliersStruct, fillMethod1, fillMethod2)
%currDataToClean= binnedDataToClean;%A vector of binned data the same length as the source of outliersStruct
% % DATA(currQ).units(currU).outliers as outliersStruct; must have subfields= .isTooNaN ; .TF1; .TF2
if nargin <4
    fillMethod2='linear';
end
if nargin <3
    fillMethod1='linear';
end
outliers=outliersStruct;

%         fillMethod@
%%INDIVIDUAL OUTLIER DATA FOR EACH UNIT ILL BE FORMATTED THIS WAY:
currDataToClean= binnedDataToClean;

currUnitOuts= outliersStruct;  % DATA(currQ).units(currU).outliers
isTooNaN=currUnitOuts.isTooNaN;
TF1=currUnitOuts.TF1;
TF2=currUnitOuts.TF2;


%1)REMOVE NaN rows
if isTooNaN==1
    msg=sprintf('Excluding unit DATA(%d).units(%d) as too NaN',outliers.verifyQuIdx(1),outliers.verifyQuIdx(1));
    warning(msg)
    cleanData=NaN(size(currDataToClean));
    include=0;
elseif isTooNaN==0
    
    
    %2) REMOVE TF1 FROM SESS WIDE FILLOUTLIERS
    TF1=currUnitOuts.TF1;
    currDataToClean(TF1==1)=NaN;
    
    
    
    fillMethod=fillMethod1; %formerly linear
    
    if fillMethod1=='0'
        currDataToClean_TF1nan=currDataToClean;
    else
        [currDataToClean_OutRem1]=fillmissing(currDataToClean,fillMethod,2);
    end
    %         %3) REMOVE NAN LINES USING IDX BEFORE COL FILLING
    %         data=currDataToClean_OutRem1;
    % %         dataIdx=OUTLIERSfull.(currLightType).(currLickType).preNanDataRows2QuIdx;
    %            dataIdx=[];
    % %         dataIdx=currDataIdxQU;
    % %         delData=OUTLIERSfull.(currLightType).(currLickType).nanDataRows2;
    %
    %         data(delData(:),:)=[];
    %         dataIdx(delData(:),:)=[];
    %
    %         currDataNanRem2=data;
    %         currIdxNanRem2=dataIdx;
    %
    %         tempCurrDataNanRem2=currDataNanRem2;
    %         currDataNanRem2(~any(~isnan(tempCurrDataNanRem2),2),:)=[];
    %         currIdxNanRem2(~any(~isnan(tempCurrDataNanRem2),2),:)=[];
    %         dataIdx=currIdxNanRem2;
    %
    
    %4) REMOVE TF2 FROM COL WISE ISOUTLIERS
    TF2=currUnitOuts.TF2;
    if fillMethod2=='0'
        currDataToClean_TF1nan(TF2==1)=NaN;
        currData_testNan=currDataToClean_TF1nan;
    else
        currDataToClean_OutRem1(TF2==1)=NaN;
        currData_testNan=currDataToClean_OutRem1;
    end

    fillMethod=fillMethod2; %formerly linear
    
    %% Check for too nan and set include=0 and isTooNaN=1;
    testData=currData_testNan;
    testNaN=find(isnan(currData_testNan));
    
    percNaN=length(testNaN)/length(testData);
    if percNaN >0.25
        include=0;
        currDataFilled_OutRem2=NaN(size(currDataToClean));
        outliers.isTooNaN=1;
    elseif fillMethod=='0'
        currDataFilled_OutRem2=currDataToClean_TF1nan;
        include=1;
    else
        [currDataFilled_OutRem2]=fillmissing(currDataToClean_OutRem1,fillMethod,2);
        include=1;
    end
    %SAVE OUTPUTS
    cleanData=currDataFilled_OutRem2;
end
% end

