%% This script will take the RATEScut strucutre and turn it into a table suitable for export to Excel 
RATEStrans = RATEScut';
cols_to_change = {'cutData','cutBins','timebins','rawData','timebins','zScoreCutData','zScoreRawData'};
longest_cell=[];
full_timebins = [0:300:14400];
for c=1:length(cols_to_change)
    col_cells = {RATEStrans(:).(cols_to_change{c})};
    longest_cell(c) = max(cellfun('length',col_cells));
end
longest_data = max(longest_cell);
%    keyboard 
for c =1:length(cols_to_change)
% %     res2 = RATEStrans.(cols_to_change{1})
%     col_cells = {RATEStrans(:).(cols_to_change{c})};
%     longest_cell = max(cellfun('length',col_cells));

    % create empty nan row to fill in each row's data
    row_nan = nan(1,longest_data);
    for r = 1:length(RATEStrans)
        filled_row = row_nan;
        currRow = RATEStrans(r).(cols_to_change{c});
        filled_row(1:length(currRow))=currRow;
        RATEStrans(r).(cols_to_change{c}) = filled_row;
    end
end

% now, convert cutBins to the headers for cutData 
RATEStable = struct2table(RATEStrans);
% RATEStable = removevars(RATEStable,'goodInts')
% keyboard


% Use splitvars to turn cutData into 48 columns, and use 'NewVariableNames'
% parameter to make te names be the cutBins


%% Split up index
RATEStable = splitvars(RATEStable,'index','NewVariableNames',{'DATA_file_num','unit_num'});
%% Determine bin names

bin_cells = {RATEStrans(:).cutBins};
longest_cell = max(cellfun('length',bin_cells));

full_timebins = [0:300:14400];
full_timebins(1:longest_cell);
% full_timebins(0:49)

binNames = arrayfun(@(x) (num2str(x)),full_timebins,'UniformOutput',false);
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
    tableOut = RATEStable(:,{'DATA_file_num','unit_num','lightType','lickType',varname});
    tableOut.FiringRateType=FiringRateType;
    tableOut=movevars(tableOut,'FiringRateType','Before',varname);
    tableOut = splitvars(tableOut,varname,'NewVariableNames',binNames);
 
    writetable(tableOut,'firing_rate_tables.xlsx','Sheet',sheetname)
end


