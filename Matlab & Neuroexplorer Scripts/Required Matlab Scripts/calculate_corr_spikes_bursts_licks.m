% corrSPIKESandLICKS.m meant to be run after
% findDATAoutliersFromSpikes_cutLicksSameBins
%%NOTE: MUST CHECK LICKS.cutLickRate for NaN values, and only compare
%%against same bins for SPIEKS.untis.RatesClean
%% New code for cutLicksToCorrBurstsAndRates
%% SHOULD ADD OTHER CORRELATIONS
% dbstop if error
ERRlickLength=[];
CORRlicks=struct();
% for d=1:length(dataTypeNames)
% currDataType= dataTypeNames{d};
% lightTypes=fieldnames(COUNTS.(currDataType));

% r=1;

%% SPIKES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fprintf('currLickData will be reused multiple times as...\n')
% listLickDataToRun={'cutLickRate','cutLickCounts','cumSumLicks'};
listLickDataToRun={'cutLickRate','cumSumLicks'}; %Removed cutLickCounts becuase results are the same as rate

%% ANALYZE FIRING RATES VS LICK DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for currQ=1:length(SPIKES)
    for currU=1:length(SPIKES(currQ).units)
        
        currLightType=SPIKES(currQ).units(currU).lightType;
        currLickType=SPIKES(currQ).units(currU).lickType;
        
        %         if isfield(DATA(currQ).units(currU).spikeRate,'ratesClean')==0
        if isempty(SPIKES(currQ).units(currU).ratesClean)
            CORRlicks(currQ).units(currU).include=0;
            continue;
            %         else
        end
        CORRlicks(currQ).units(currU).include=1;
        
        %%Loop through each entry of Lick Data to Run
        for ii=1:length(listLickDataToRun)
            
            %define currLickData=LICKS(Q).(currentStat)
            msg=sprintf('currLickData=LICKS(%d).%s;',currQ,listLickDataToRun{ii});
            eval(msg);
            currRateData=SPIKES(currQ).units(currU).ratesClean;
            
            %%RUN and save the correlation results
            r=[];  p=[]; sig=[];
            
            %Select data to correlate
            currSpikeDataToCorr=currRateData;
            currLickDataToCorr=currLickData;
            
            %%%  ACTUAL CORRELATION CALCULATION
            [r, p]=corrcoef(currLickDataToCorr',currSpikeDataToCorr','rows','pairwise');
            currP=p(2,1); currR=r(2,1);
            
            %Summarize p value with text variable (sig)
            if currP> 0.10
                sig='No';
            elseif currP <=0.05
                sig='Yes';
            elseif currP <=0.10
                sig='Trend';
            end
            
            %%%FILL IN OUTPUT
            nameOfCurrentData=sprintf('ratesVs%s',listLickDataToRun{ii});
            CORRlicks(currQ).units(currU).lightType=currLightType;
            CORRlicks(currQ).units(currU).lickType=currLickType;
            CORRlicks(currQ).units(currU).(nameOfCurrentData).pVal=currP;
            CORRlicks(currQ).units(currU).(nameOfCurrentData).pearsonR=currR;
            CORRlicks(currQ).units(currU).([nameOfCurrentData,'_Sig'])=sig;
            
            
            %%  ADDING NORMALIZED FIRING RATES @NOW
            r=[]; p=[]; sig=[]; currRateData=[]; currSpikeDataToCorr=[];
            
            msg=sprintf('currLickData=LICKS(%d).%s;',currQ,listLickDataToRun{ii});
            eval(msg);
            
            currRateData=SPIKES(currQ).units(currU).ratesClean;
            [zScoredCleanData]=calcOutlierZscoresV2(currRateData);
            
            currSpikeDataToCorr=zScoredCleanData;
            currLickDataToCorr=currLickData;
            
            [r, p]=corrcoef(currLickDataToCorr',currSpikeDataToCorr','rows','pairwise');
            currP=p(2,1); currR=r(2,1);
%             saveCurrSpikeDataNorm=currSpikeDataToCorr;
%             saveCurr_pr_norm=[p(2,1), r(2,1)];

            if currP> 0.10
                sig='No';
            elseif currP <=0.05
                sig='Yes';
            elseif currP <=0.10
                sig='Trend';
            end
            
            nameOfCurrentData=sprintf('normRatesVs%s',listLickDataToRun{ii});
            CORRlicks(currQ).units(currU).(nameOfCurrentData).pVal=currP;
            CORRlicks(currQ).units(currU).(nameOfCurrentData).pearsonR=currR;
            CORRlicks(currQ).units(currU).([nameOfCurrentData,'_Sig'])=sig;
            
            
        end
    end
end


%% ANALYZE BURST VS LICK DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% listLickDataToRun={'cutLickRate','cumSumLicks'}; %Already defined

% if exist('BURSTunits','var')==0
%     fprintf('BURSTunits structure does not exist. Skipping burst correlations.\n')
%     return
% end
if isfield(BURSTunits(1).units(1),'file_num')
    if isfield(BURSTunits(1).units(1),'lightType')==0
        for B=1:length(BURSTunits)
            for u=1:length(BURSTunits(B).units)
                iQ = BURSTunits(B).units(u).file_num;
                iU = BURSTunits(B).units(u).unit_num;
                burst_name = BURSTunits(B).units(u).name;
                
                if burst_name ==DATA(iQ).units(iU).name
                    BURSTunits(B).units(u).lightType=DATA(iQ).units(iU).finalLightResponse;
                    BURSTunits(B).units(u).lickType = DATA(iQ).units(iU).finalLickResponse;
                end
            end
        end
    end
end

                
                
%%Loop through BURSTunits(Q)
for currQ=1:length(BURSTunits)
    
    %Skip empty units
    if isempty(CORRlicks(currQ).units)
        continue;
    end
    
    %%Loop through BURSTunits(Q).units(u)
    for currU=1:length(BURSTunits(currQ).units)
        
        currLightType=[]; currLickType=[];
        
        %Select current units light-lick type
        currLightType=BURSTunits(currQ).units(currU).lightType;
        currLickType=BURSTunits(currQ).units(currU).lickType;
        
        %Verify unit is included in dataset
        if DATA(currQ).units(currU).include==0
            continue;
        end
        
        %Verify CORRlicks and BURST data match
        if strcmp(CORRlicks(currQ).units(currU).lightType,currLightType)==0 ||strcmp(CORRlicks(currQ).units(currU).lickType,currLickType)==0
            fprintf('[!] The light/lick fields of BURSTunits vs CORRlicks(%d).units(%d)do not match.\n',currQ,currU)
            fprintf('     LIGHT:   BURSTunits(%d).units(%d): %s vs CORRlicks(%d).units(%d): %s.\n',currQ,currU,currLightType,currQ,currU,CORRlicks(currQ).units(currU).lightType);
            fprintf('     LICKS:   BURSTunits(%d).units(%d): %s vs CORRlicks(%d).units(%d): %s.\n\n',currQ,currU,currLickType,currQ,currU,CORRlicks(currQ).units(currU).lickType);
            continue;
        end
        
        %Verify if need these checks still after adding some to beginning
        if isfield(SPIKES(currQ).units(currU),'ratesClean')==0
            continue;
        elseif isempty(BURSTunits(currQ).units(currU).BURSTstats.percSpikesInBursts.binnedMeansClean)
            %             CORRlicks(currQ).units(currU).includeBursts=0;
            continue;
        else
            %             CORRlicks(currQ).units(currU).includeBursts=1;
            
            currBurstData=BURSTunits(currQ).units(currU).BURSTstats.percSpikesInBursts.binnedMeansClean;
            currLickData=LICKS(currQ).cutLickRate;
            
            %             %%ADD IN nan check for currLickData and only take non-Nan idx
            %             %%from both currLickData and currBurstData
            %             indNotNan=find(isnan(currLickData)==0);
            %             currLickDataToCorr=currLickData(indNotNan);
            %             currBurstDataToCorr=currBurstData(indNotNan);
            %
            %             %%MOVE LENGTH CHECK TO AFTER USING NAN
            %             if length(currBurstDataToCorr)~=length(currLickDataToCorr)
            %                 fprintf('Rate Data and Lick Data for DATA(%d).units(%d) are different sizes.\n',currQ,currU);
            %                 fprintf('Rate Data: %d. Lick Data: %d.\n',length(currBurstData),length(currLickData));
            %                 ERRlickLength=[ERRlickLength;currQ,currU];
            %                 %continue?
            %             end
            %             %
            %
            
            for ii=1:length(listLickDataToRun)
                
                %define currLickData=LICKS(Q).(currentStat)
                msg=sprintf('currLickData=LICKS(%d).%s;',currQ,listLickDataToRun{ii});
                eval(msg);
                currRateData=SPIKES(currQ).units(currU).ratesClean;
                
                %% RUN and save the correlation results
                r=[];  p=[]; sig=[];
                currUnitDataToCorr=NaN(1,48);
                currUnitDataToCorr(1:length(currBurstData))=currBurstData;
                currLickDataToCorr=currLickData;
                
                [r, p]=corrcoef(currLickDataToCorr,currUnitDataToCorr,'rows','pairwise');
                currP=p(2,1); currR=r(2,1);
                if currP> 0.10
                    sig='No';
                elseif currP <=0.05
                    %                 sig=num2str(currP);
                    sig='Yes';
                elseif currP <=0.10
                    sig='Trend';
                end
                
                %%%FILL IN OUTPUT
                nameOfCurrentData=sprintf('percBurstVs%s',listLickDataToRun{ii});
                CORRlicks(currQ).units(currU).lightType=currLightType;
                CORRlicks(currQ).units(currU).lickType=currLickType;
                CORRlicks(currQ).units(currU).(nameOfCurrentData).pVal=currP;
                CORRlicks(currQ).units(currU).(nameOfCurrentData).pearsonR=currR;
                CORRlicks(currQ).units(currU).([nameOfCurrentData,'_Sig'])=sig;
                
                
            end
            
            %%%FILL IN OUTPUT
            nameOfCurrentData=sprintf('percBurstVs%s',listLickDataToRun{ii});
            CORRlicks(currQ).units(currU).lightType=currLightType;
            CORRlicks(currQ).units(currU).lickType=currLickType;
            CORRlicks(currQ).units(currU).(nameOfCurrentData).pVal=currP;
            CORRlicks(currQ).units(currU).(nameOfCurrentData).pearsonR=currR;
            CORRlicks(currQ).units(currU).([nameOfCurrentData,'_Sig'])=sig;
            
            
        end
    end
end
% end
fprintf('You may now run print_results_table_to_excel.m\n')
fprintf('To continue plotting run prep_data_for_norm_firing_fig.\n')
% clearvars -except DATA* BURST* COUNTS* CRF* options* PLOT* RATES* SORT* ERR* OUTLIER* CORR* LICK* SPIKES
clearCRFdata