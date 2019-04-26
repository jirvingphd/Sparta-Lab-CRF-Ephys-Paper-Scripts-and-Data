function [SPK, nexDATA, msg]=nexCutRateHistoNexTrigdFUN(nexRates,nexColumnNames)
%%Updated/fin on 02/18/17
%Actually triggered by matlab script NexCombinedDATAstruct [03/18/17]
% TESTING TAKING A nexWIP- FIRING RATE OUTPUT WITH ZEROS AND REMOVING INTERVAL
%%WITH 0. Input is "nexRates" m x n matrix, where m=number of time bins and n=number of units - 1.
%The first column is left end of time bin
%%%OUTPUT IS SPK structure with fields rateRaw, ratePerc, binsRaw, binPerc, and empty field isCRF
%%rateRaw is matrix with variable num rows depending on the data removed (binsRaw corresponding axis)
%%ratePerc uses continuous interp with interpft to make the rate matrix 100 rows (% time of session)

%% Read in data
% template in nexWIP is set to output nexRates as Matlab matrix.
% if exist('nexRates','var')==0;
%     nexRates=nex;
% end
nexWIP=nexRates;
nexJustRates=nexRates(:,2:end);
[row col]=size(nexJustRates);


%%Make a new folder for resulting data.
% dname=pwd;
% newFolder=mkdir(pwd,'Firing Rates');
% cd('Firing Rates');

%
%% FIND ROWS OF THE MATRIX IN WHICH EVERY COLUMNS (UNIT) HAS A VALUE OF ZERO)
dataOut=[];
SPK=[];
zeroRows=any(max(nexJustRates,[],2),2);
%zeroRows=any(max(nexRates,[],2),2);

for z=1:length(zeroRows)
    if zeroRows(z)==1
        dataOut=[dataOut; nexWIP(z,:)];
    end
end
nexCut=dataOut;
clearvars dataOut

%% FILL IN OUTPUT "nexDATA"
for c=1:(size(nexColumnNames,2))%-1 %-1)
    nexDATA{1,c}= nexColumnNames{c};
    nexDATA{2,c}= num2cell(nexCut(:,c));
    %interp firing rates to 100 time bines (100% of session)
    nexDATA{3,c}=num2cell(interpft(nexCut(:,c),100));
end
%disp('Check that nexDATA first column is not filled with a unit')
binSize=nexWIP(2,1)-nexWIP(1,1);
r2=size(nexCut,1);
timeAxis=[0:binSize:binSize*(r2-1)]';

nexDATA{3,1}=num2cell(timeAxis);
%%TO RETRIEVE DATA LATER:
%spk1=
%ts1=cell2mat(nexDATA{2,1})


%%SAVE WF NAMES, WAVEFORMS, AND TIMESTAMPS TO WFs STRUCTURE
SPK=struct();
for j=1:length(nexDATA(1,:))-1
    SPK(j).name=nexDATA{1,j+1};
    SPK(j).rateRaw=cell2mat(nexDATA{2,j+1});
    SPK(j).ratePerc=cell2mat(nexDATA{3,j+1});
    % %%USE INTERP TO CHANGE THE NUMBER OF TIME BINS TO 100 BINS (Perc)
    % currRate=cell2mat(nexDATA{2,j+1});
    % 	SPK(j).rateRaw=currRate;
    % 	SPK(j).ratePerc=interpft(currRate,100)
    % 	currRate=[];
    
    SPK(j).binsRaw=cell2mat(nexDATA{3,1});
    SPK(j).binsPerc=linspace(0,max(cell2mat(nexDATA{3,1}))); % fills in values of 0 to max of timebins with 100 entries
    %SPK(j).isCRF=[];
end


%clearvars newFolder dataOut zeroRows r c nexJustRates binSize nexCut nexWIP r2 z timeAxis j binSize %nexRates

%save('nexRateHistoDATA.mat','SPK','nexDATA');
%disp('nexDATA & SPK structure are complete and saved as nexRateHistoDATA.mat')
disp('nexCutRateHistoNexTrigd complete.')
%msg='It ran.';

