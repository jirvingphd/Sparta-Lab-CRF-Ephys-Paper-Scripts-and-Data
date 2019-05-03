%% This script will take the RATEScut strucutre and turn it into a table suitable for export to Excel 
RATEStrans = RATEScut';
cols_to_change = {'cutData','cutBins','timebins'};
for c =1:length(cols_to_change)
%     res2 = RATEStrans.(cols_to_change{1})
    col_cells = {RATEStrans(:).(cols_to_change{c})};
    longest_cell = max(cellfun('length',col_cells));

    % create empty nan row to fill in each row's data
    row_nan = nan(1,longest_cell);
    for r = 1:length(RATEStrans)
        filled_row = row_nan;
        currRow = RATEStrans(r).(cols_to_change{c});
        filled_row(1:length(currRow))=currRow;
        RATEStrans(r).(cols_to_change{c}) = filled_row;
    end
end

% now, convert cutBins to the headers for cutData 
RATEStable = struct2table(RATEStrans);
% keyboard


% Use splitvars to turn cutData into 48 columns, and use 'NewVariableNames'
% parameter to make te names be the cutBins


%% Split up index
RATEStable = splitvars(RATEStable,'index','NewVariableNames',{'DATA_file_num','unit_num'});
%% Determine bin names
bin_cells = {RATEStrans(:).timebins};
longest_cell = max(cellfun('length',bin_cells));
binNames = arrayfun(@(x) (num2str(x)),RATEStable.timebins(1,:),'UniformOutput',false);
prefix='bin_';
binNames = cellfun(@(x) [prefix,x],binNames,'UniformOutput',false);
RATEStable = removevars(RATEStable,{'cutBins','timebins'});

%% Split up into sheets for excel 
sheets = {'RawFiringRate','CleanedFiringRate','ZScoreRawRate','ZSoreCleanRate'};
sheet_vars = {'rawData','cutData','zScoreRawData','zScoreCutData'};
for s=1:length(sheets)
    sheetname=sheets{s};
    varname = sheet_vars{s};
    FiringRateType=cell(height(RATEStable),1);
    for f=1:numel(FiringRateType)
        FiringRateType{f}=varname;
    end
    tableOut = RATEStable(:,{'DATA_file_num','unit_num','lightType','lickType','goodInts',varname});
    tableOut.FiringRateType=FiringRateType;
    tableOut=movevars(tableOut,'FiringRateType','Before',varname);
    tableOut = splitvars(tableOut,varname,'NewVariableNames',binNames);
 
    writetable(tableOut,'firing_rate_tables.xlsx','Sheet',sheetname)
end


