

function [cutTimestamps]=cutTimesGoodIntsFast(timestamps,goodInts)
%% [cutTimestamps]=cutTimesGoodIntsFast(timestamps,goodInts)
%This function cuts out any timestamps in the timestamps variable that do not fall
%within the the specified good intervals intervals.
%Input:
%timestamps: vector of timestamps that needs to be cleaned/cut
%goodInts: m x 2 matrix where each good interval is a row m with a
%beginning and ending timestamp


% %% Feed binnedData through goodInts, keeping only values that fall between Int(start , end;)
% numInts=size(goodInts,1);
% %Initialize a matrix of all zeroes that is timestamps rows by numInts cols.
% % currResult=zeros(length(timestamps),numInts);
% % if length(timestamps)
% includeTimesTracker=zeros(1,length(timestamps));
% timesCut=struct();
%
% j=1;
%
% while j<=numInts
%
%     for i=1:length(timestamps)
%
%         if timestamps(i) >= goodInts(j,1) && timestamps(i) <=goodInts(j,2)
%
%             includeTimesTracker(i)=1;
%
%             %add i?
%
%         else
%
%             includeTimesTracker(i)=0;
%
%         end
%     end
%     timesCut(j).filterRes=includeTimesTracker; %Multiplies rawBins timestamp by 1 if passed logic test or 0 if failed
%     j=j+1;
% end
% testBurstInts=vertcat(timesCut.filterRes);
% resBurstInts=any(testBurstInts,1);
% cutTimestamps=timestamps(resBurstInts==1);
%% Feed binnedData through goodInts, keeping only values that fall between Int(start , end;)
numInts=size(goodInts,1);
%Initialize a matrix of all zeroes that is timestamps rows by numInts cols.
% currResult=zeros(length(timestamps),numInts);
% if length(timestamps)
includeTimesTracker=zeros(1,length(timestamps));
timesCut=struct();

testRes=struct();

j=1;
resCheckCombine=timestamps>=goodInts(j,1) & timestamps<=goodInts(j,2);

% j=2;
for j=2:numInts
    
    %     resStart=timestamps>=goodInts(j,1);
    %     resEnd=timestamps<=goodInts(j,2);    
    %     resCheckPrevInt=resCheckCurrInt;  
    resCheckCurrInt=timestamps>=goodInts(j,1) & timestamps<=goodInts(j,2);
      resCheckCombine=resCheckCombine+resCheckCurrInt;
%             resCombined=[resCheckPrevInt;resCheckCurrInt];
%         resCompare=any(resCombined,1);
%     end
%     j=j+1;
end

cutTimestamps=timestamps(resCheckCombine==1);
% timesCut(j).resCheck=[resCheckCurrInt];

%     for i=1:length(timestamps)
%
%         if timestamps(i) >= goodInts(j,1) && timestamps(i) <=goodInts(j,2)
%
%             includeTimesTracker(i)=1;
%
%             %add i?
%
%         else
%
%             includeTimesTracker(i)=0;
%
%         end
%     end
% %     timesCut(j).filterRes=includeTimesTracker; %Multiplies rawBins timestamp by 1 if passed logic test or 0 if failed
%     j=j+1;
% end
% testBurstInts=vertcat(timesCut.resCheck);
% resBurstInts=any(testBurstInts,1);
% cutTimestamps=timestamps(resBurstInts==1);