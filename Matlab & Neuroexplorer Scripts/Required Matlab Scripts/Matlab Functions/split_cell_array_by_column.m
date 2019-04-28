function [cell_array_columns] = split_cell_array_by_column(cell_array)
% Takes a cell array (2,n) that has header cells in row 1 and data cells in
% row 2 and splits up columns into 1xn cell array of paired headers/data) 
%   Detailed explanation goes here
cell_array_columns={};
for i =1:length(cell_array)
    cell_header = cell_array{1,i};
    [unit_name, result_name] = split_unit_results_header(cell_header);
    cell_cols{1,1} = result_name;
    cell_cols{2,1}=unit_name;
    cell_cols{3,1} = cell_array{2,i};
    cell_array_columns{i}= cell_cols;
end

