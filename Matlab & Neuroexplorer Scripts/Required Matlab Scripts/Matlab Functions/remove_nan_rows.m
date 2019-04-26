function [cleaned_cell_array] = remove_nan_rows(cell_array)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
cleaned_cell_array = {};
for i =1:size(cell_array,2)
%     cellfun(cell_array(
    test_cell=cell_array{i};
    nanidx= isnan(test_cell);
    test_cell(nanidx)=[];
    cleaned_cell_array{i}=test_cell;
end
cleaned_cell_array = cleaned_cell_array;


