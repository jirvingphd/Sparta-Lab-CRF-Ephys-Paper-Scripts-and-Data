%BURSTunits_Analysis.m
% James M Irving updated 10-03-18
% This script requires the FUnit results from burst analysis from Nex;
% Creates "BURSTunits" structure with same Q,u index as DATA
%
%% Index for filling separate subfields
% BURSTunits=struct();
BURSTunits=struct();
tokensNexCols={};
whoVarListNames={};
unitNames={};
%%%%%%%%%%%%%%%%%%%

%% Inserted from nexBurstsToStruct
% if exist('nexColumnNamesBursts','var')
%     nexColumnNames=nexColumnNamesBursts;
% end
% if exist('BURSTcells','var')==0
%
tic
BURSTcells=cell(2,length(nexColumnNames));
for i=1:length(nexColumnNames)
    BURSTcells{1,i}=nexColumnNames{i};
    BURSTcells{2,i}=num2cell(nexBursts(:,i));
end
toc


%% Capture tokens of nex results and sort into struct
%Get the names of units form the nexColumnNames to then eval and get the
%length of the variables for the units

% Process names from column titles and separate into pieces
[nexColNameUnits]=cellfun(@(x)regexpi(x,'(([FC])Unit\w*)\s','tokens'),nexColumnNames,'UniformOutput',false);
nexColNameUnits=[nexColNameUnits{:}]';
for t=1:length(nexColNameUnits)
    nexColNameUnits(t,1:size(nexColNameUnits{t,1},2))=[nexColNameUnits{t,1}];
end

% Process names from column titles and separate into pieces to find the
% correct type of data in each colum
[tokensNexCols]=cellfun(@(x)regexpi(x,'([FC])Unit+\_+(\w{1,2})\_+(\w{1,2})\_+(\w{1,2})\_+(\w{1,2})\W(\w*)','tokens'),nexColumnNames,'UniformOutput',false);
tokensNexCols=[tokensNexCols{:}]';

%%NEW ON 08/30: combines full unit name with tokens
for i=1:length(nexColNameUnits)
    nexColNameUnits_tokens(i,1)=nexColNameUnits(i);
    %nexColNameUnits_tokens(i,2)={tokensNexCols(i,:)};
    nexColNameUnits_tokens(i,2:size(tokensNexCols{t,1},2)+1)=[tokensNexCols{i,1}];
end

%NOW FILL IN BURST CELLS WITH RIGHT INFO
for i=1:length(nexColNameUnits_tokens)%for i=1:length(tokensNexCols)
    %     clearvars *Index
    currUnitName=nexColNameUnits_tokens{i,1};
    currUnitType=nexColNameUnits_tokens{i,2};
    
    Q=str2double(nexColNameUnits_tokens{i,3});
    u=str2double(nexColNameUnits_tokens{i,4});
    
    currLightType=nexColNameUnits_tokens{i,5};
    currLickType=nexColNameUnits_tokens{i,6};
    currResultsType=nexColNameUnits_tokens{i,7};
    
    %Delete NaN cells
    currData=cell2mat(BURSTcells{2,i});
    ind=find(isnan(currData));
    currData(ind)=[];
    
    %% New 10-03-18 - Replace shorter light and lick type names with NR,'excited, 'inhibited','predictive')
%     clearvars longType shortTypeToComp
    longType=[''];
    shortTypeToComp=[''];
    %%% Check LIGHT type name
    shortTypeToComp=currLightType;
    if length(shortTypeToComp)<3
        if strcmpi('I',shortTypeToComp)>0
            longType='inhibited';
        elseif strcmpi('P',shortTypeToComp)>0
            longType='predictive';
        elseif strcmpi('E',shortTypeToComp)>0
                longType='excited';
        elseif strcmpi('C',shortTypeToComp)
                longType='CRF';            
        elseif strcmpi('PE',shortTypeToComp)>0
            longType='predictiveExcited';
        elseif strcmpi('NR',shortTypeToComp)>0
            longType='NR';
        end
    end
    currLightType=longType;
    
    
    clearvars longType shortTypeToComp
    
    %%% Check LICK type name
    shortTypeToComp=currLickType;
    
    if length(shortTypeToComp)<3
        if strcmpi('I',shortTypeToComp)>0
            longType='inhibited';
        elseif strcmpi('P',shortTypeToComp)>0
            longType='predictive';
        elseif strcmpi('E',shortTypeToComp)>0
            longType='excited';
        elseif strcmpi('PE',shortTypeToComp)>0
            longType='predictiveExcited';
        elseif strcmpi('NR',shortTypeToComp)>0
            longType='NR';
        end
    end
    currLickType=longType;
    clearvars longType shortTypeToComp
    
    %% Fill in BURSTunits
    BURSTunits(Q).units(u).unitName=char(currUnitName);
    BURSTunits(Q).units(u).lightType=char(currLightType);
    BURSTunits(Q).units(u).lickType=char(currLickType);
    BURSTunits(Q).units(u).index=[Q,u];
    BURSTunits(Q).units(u).(currResultsType)=currData;
end
% clearvars tokens Q u dataType curr* tok* Q u curr* ind
% BURSTunits=sortBURSTunits;
clearvars Q u dataType curr* ind BURSTcells

%%Below was tested independently
% Original Script COntinues
%Below captures F/C TYPE/NUM TYPE/NUM TYPE/NUM BurstSpikes/NonBurstSpikes

%%GET TIMESTAMP VARIABLES
%Get List of timestamp containing variables to make cell matrix of variables selected and their contents
whoVarList=who;
%whoVarListNames=cellfun(@(x)regexp(x,'(FUnit|CUnit)\w*','match'),whoVarList,'UniformOutput',0);
whoVarListNames=cellfun(@(x)regexp(x,'(FUnit|CUnit)\w*Spikes','match'),whoVarList,'UniformOutput',0);
check=~cellfun(@(x)isempty(x),whoVarListNames);
whoVarListNames(check==0)=[];
whoVarListNames=[whoVarListNames{:}]';

whoVarListTokens=[cellfun(@(x)regexpi(x,'((FUnit\w*)(?=Non\w*|NonBurst\w*))','tokens'),whoVarListNames,'UniformOutput',0)]; %captures BurstSpikes and NonBurstSpikes too
%whoVarListTokens=[whoVarListTokens{:}]';
for t=1:length(whoVarListTokens)
    whoVarListTokens(t,1:size(whoVarListTokens{t,1},2))=[whoVarListTokens{t,1}];
end

%Use regexp to capture tokens of Unit names
tokensVarList={};
tokensVarList=[cellfun(@(x)regexpi(x,'([FC])Unit\_(\w{1,2})\_(\w{1,2})\_(\w{1,2})\_(\w{1,2}(?=Non\w*|Burst\w*))((Non)?BurstSpikes)?','tokens'),whoVarListNames,'UniformOutput',0)]; %captures BurstSpikes and NonBurstSpikes too
%Remove layers of cell arrays
tokensVarList=[tokensVarList{:}]';

%Take nested cell arrays and remove unnecessary top layer of cells{{}}
%     for t=1:length(tokensVarList)
%         tokensVarList(t,1:size(tokensVarList{t,1},2))=[tokensVarList{t,1}];
%     end

%Take the list of variables in whoListUnits and fill in data of other
%associated vars
unitVarsMasterList={};
for i=1:length(whoVarListNames)
    unitVarsMasterList(i,1)=whoVarListNames(i);
    unitVarsMasterList{i,2}=str2double(tokensVarList{i}(2:3));
    unitVarsMasterList{i,3}=tokensVarList{i}(6);
    unitVarsMasterList{i,4}=eval(char(whoVarListNames{i}));
    %         unitVarsMasterList{i,3}=eval(char(whoVarListNames{i}));
end
% Fill in BURSTunits with unitVarsMasterList
for i=1:length(unitVarsMasterList)
    
    Q=unitVarsMasterList{i,2}(1);
    u=unitVarsMasterList{i,2}(2);
    currDataType=char(unitVarsMasterList{i,3});
    currData=unitVarsMasterList{i,4};
    
    BURSTunits(Q).units(u).(currDataType)=currData;
    
end
%keyboard
clearvars FUnit* curr* who* num* total* Q u i tokens*

%% Calculate and fill in spikes in bursts statistics
for Q=1:length(BURSTunits)
    
    for u=1:length(BURSTunits(Q).units)
        if isfield(BURSTunits(Q).units(u),'BurstSpikes')
            numBurstSpikes=length(BURSTunits(Q).units(u).BurstSpikes);
        else
            numBurstSpikes=0;
        end
        if isfield(BURSTunits(Q).units(u),'NonBurstSpikes')
            numNonBurstSpikes=length(BURSTunits(Q).units(u).NonBurstSpikes);
        else
            numNonBurstSpikes=0;
        end
        %         numNonBurstSpikes=length(BURSTunits(Q).units(u).NonBurstSpikes);
        totalSpikes=numBurstSpikes+numNonBurstSpikes;
        currPercBurstSpike=numBurstSpikes/totalSpikes*100;
        BURSTunits(Q).units(u).totalSpikes=totalSpikes;
        BURSTunits(Q).units(u).percSpikesInBursts=currPercBurstSpike;
        
        
        %NEW AS OF 09112017
        if isempty(BURSTunits(Q).units(u).BurstDuration)
            continue
        else
            BURSTunits(Q).units(u).meanFreqInBurst = BURSTunits(Q).units(u).SpikesInBurst./BURSTunits(Q).units(u).BurstDuration;
            BURSTunits(Q).units(u).BurstsPerSecond = length(BURSTunits(Q).units(u).BurstStart) /(BURSTunits(Q).units(u).BurstStart(end)-BURSTunits(Q).units(u).BurstStart(1));
        end
    end
end

%% Run additional burst analysis
% fprintf('Now running nexBurstByHourUsingIntervals. . .\n')
% nexBurstByHourUsingIntervals


% clearvars FUnit* curr* who* num* total* Q u t check nex* unitNames StartStop
save('BURSTunits_DataStructure.mat','BURSTunits');
fprintf('Saved the BURSTunits data in new file: BURSTunits_DataStructure.mat\n')

clearCRFdata
fprintf('Burst analysis complete.\nNow load main DATA file and run: nexBurstByHourUsingCalcPercBursts\n')




% fprintf('Now running nexBurstByHourUsingCalcPercBursts. . .\n')
% nexBurstByHourUsingCalcPercBursts
