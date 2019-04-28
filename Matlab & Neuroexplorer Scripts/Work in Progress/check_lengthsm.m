% check if cells are of equal length
length_matrix = cellfun(@(x) length(x), cell_extract);
[c, ia, ic] = unique(length_matrix);
a_counts = accumarray(ic,1);
% value_counts = [c, a_counts']
value_counts=table(c',a_counts,'VariableNames',{'unique','counts'});
% unique(length_matrix,
