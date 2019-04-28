function [edited_cell_strings_out] = space_to_underscore(cell_strings)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
edited_cell_strings={};
for i =1:length(cell_strings)
    edited_cell_strings{i} = regexprep(cell_strings{i},'\s','_');
end
edited_cell_strings_out = edited_cell_strings;
