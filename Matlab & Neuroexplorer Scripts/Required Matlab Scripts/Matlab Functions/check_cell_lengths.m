function [value_counts] = check_cell_lengths(cells_to_check)
% Take a 1xn cell array and check the lengths of each element and returns the
% value counts for the unique lengths as a table.
%   Detailed explanation goes here

% check if cells are of equal length
length_matrix = cellfun(@(x) length(x), cells_to_check)
[c, ia, ic] = unique(length_matrix)
a_counts = accumarray(ic,1);
% value_counts = [c, a_counts']
value_counts=table(c',a_counts,'VariableNames',{'unique','counts'});
% unique(length_matrix,
end

