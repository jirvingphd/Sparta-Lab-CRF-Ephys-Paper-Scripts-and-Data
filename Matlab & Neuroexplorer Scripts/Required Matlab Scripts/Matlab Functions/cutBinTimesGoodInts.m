

function [dataCountsCut,  dataBinEdgesCut, dataCountsFull,  dataBinEdgesFull,  binsToKeep,  tsBinsIdx]=cutBinTimesGoodInts(timestamps,binsize,goodInts,timebins)
%% [dataCountsCut,dataBinEdgesCut, dataCountsFull,dataBinEdgesFull,cutEdgesIdx,tsBinsIdx]=cutBinTimesGoodInts(timestamps,binsize,goodInts)
%This function cuts out any timestamps in the timebins variable that fall within the the specified cut intervals, +/- the window size
%This ensures that PES will not contain any sections without data.
%Input:
%timestamps: vector of timestamps that needs to be cleaned/cut
%binsize: how large bins should be for binning data with histc
%	Each Row is 2 elements, [start of interval to remove, end of of interval to remove]
%	can manually create this easily by typing cut=[start1 end1; start2 end2; start3 end3] where start and end are times in same units as timebins timestamps
%	winmaxmin: same as chronux; Two element array with time before and time after event to be used in PES
%i.e. [5 5] for removing 5 seconds before and 5 seconds after


%% Figure out how many left-sided bins are needed and make timebins
% % lastBin=floor(timestamps(end)/binsize);
% if timestamps(end)<14400
%     lastBin=14400/binsize;
% else
% end
if nargin<4
    lastBin=floor(timestamps(end)/binsize);
    timebins=[0:binsize:binsize*lastBin];
end

%% Get binned data from histc 
% countBinnedData=histc(timestamps,timebins); %Histc is no longer recommended, and i should make this match... calcPercSpikesInBursts?
% [dataCountsFull, dataBinEdgesFull ,~]=histcounts(timestamps,'binWidth',binsize);
[dataCountsFull, dataBinEdgesFull, tsBinsIdx]=histcounts(timestamps,timebins);

% dataBinEdgesFull=dataBinEdgesFull(1:length(dataCountsFull)); %Uncomment
% if only want left edges of bins

% Divide by binsize to make firing rates
% binnedData=countBinnedData./binsize;
%% Feed binnedData through goodInts, keeping only values that fall between Int(start , end;)
numInts=size(goodInts,1);
%Initialize a matrix of all zeroes that is timebins rows by numInts cols. 
currResult=zeros(length(dataCountsFull),numInts);

for j = 1:numInts
    
    for i=1:length(dataCountsFull)

        if dataBinEdgesFull(i) >= goodInts(j,1) && (dataBinEdgesFull(i)+binsize)<=goodInts(j,2)
        
            currResult(i,j)=1;
            
        else
            
            currResult(i,j)=0;
            
        end
      
    end

end

%%Compress currResult so that it becomes 1 vector timebins-long with 0 or 1
includeRows=max(currResult,[],2);
%cutBins=timebins(includeRows==1);
% dataCountsCut=binnedData(includeRows==1);
dataCountsCut=dataCountsFull(includeRows==1);
dataBinEdgesCut=[0:binsize:(length(dataCountsCut)-1)*binsize];
binsToKeep=includeRows;


% countsData=dataCountsFull(includeRows==1);
% cutEdgesIdx=countsDataEdges(includeRows==0);
% dataBinEdgesCut








