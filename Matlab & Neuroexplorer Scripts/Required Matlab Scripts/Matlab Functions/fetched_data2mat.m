function [data_cells, index_mat] = fetched_data2mat(retreived_data_cells)
%Takes output of fetch_unit_type_data and creates a matrix of the data
%cells and a list of indices
%   Detailed explanation goes here
data_cells = retreived_data_cells;
output_mat = [];
output_cells = {};


for c = 1:length(data_cells)
    
    extract_cell = data_cells{c};
    fun = @(x) x(3);
    extractCellData = cell2mat(extract_cell(3));
    output_cells=horzcat(output_cells,extractCellData);
end
data_cells = output_cells;
% outputArg2 = inputArg2;
end

