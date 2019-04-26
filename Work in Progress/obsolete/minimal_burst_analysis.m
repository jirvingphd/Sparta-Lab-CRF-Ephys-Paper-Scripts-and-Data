%minimal_burst_analysis


% Accept the nex_Burst_cols from get_data_from_nex_with_bursts
BURSTcells=cell(2,length(nex_Burst_cols));
for i=1:length(nex_Burst_cols)
    BURSTcells{1,i}=nex_Burst_cols{i};
    BURSTcells{2,i}=num2cell(nex_Burst_results(:,i));
end



%% Processing the nex results

% Extract the name of the units from the results columns
[nexColNameUnits]=cellfun(@(x)regexpi(x,'(SPK\d\d[a-h])\s(\w*)','tokens'),nex_Burst_cols,'UniformOutput',false);
nexCols_unit_data = {}
% Extract the unit name and then data-analysis-name into nexCols_unit_data
for n=1:length(nexColNameUnits)
    nexCols_unit_data{n,1}=nexColNameUnits{n}{1}{1}';
    nexCols_unit_data{n,2}=nexColNameUnits{n}{1}{2}';
end

%% Loop through list of nexCols_unit_data and fill in the proper information a units(u) structure
BURSTS=struct();
units=struct();
for n = 1:length(nexCols_unit_data)
    currUnit = nexCols_unit_data{1}
    currDataType=nexCols_unit_data{1}
%     currData=unitVarsMasterList{i,4};
    
    BURSTunits(Q).units(u).(currDataType)=currData;
    
    
% for t=1:length(nexColNameUnits)
%     nexColNameUnits(t,1:size(nexColNameUnits{t,1},2))=[nexColNameUnits{t,1}];
% end

% % Process names from column titles and separate into pieces to find the
% % correct type of data in each colum
% [tokensNexCols]=cellfun(@(x)regexpi(x,'([FC])Unit+\_+(\w{1,2})\_+(\w{1,2})\_+(\w{1,2})\_+(\w{1,2})\W(\w*)','tokens'),nex_Burst_cols,'UniformOutput',false);
% tokensNexCols=[tokensNexCols{:}]';
% 
% %%NEW ON 08/30: combines full unit name with tokens
% for i=1:length(nexColNameUnits)
%     nexColNameUnits_tokens(i,1)=nexColNameUnits(i);
%     %nexColNameUnits_tokens(i,2)={tokensNexCols(i,:)};
%     nexColNameUnits_tokens(i,2:size(tokensNexCols{t,1},2)+1)=[tokensNexCols{i,1}];
% end
