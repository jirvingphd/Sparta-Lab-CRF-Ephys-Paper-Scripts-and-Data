function [unit_name,result_name] = split_unit_results_header(unit_header,expr_unit_names)
% Accepts a string of "SPK##/Sig### ResultName" and returns the unit name and REsultName separated. 
%   Detailed explanation goes here

if nargin <2
    if ischar(unit_header)
        unit_header = convertCharsToStrings(unit_header);
    end
    if contains(unit_header,'sig','IgnoreCase',true)
        expr_unit_names = '(sig\d{2,3}[a-h])\s?(\w*)';
    else
        expr_unit_names = '(SPK\d\d[a-h])\s?(\w*)';
    end
end


[token_matches]= regexpi(unit_header,expr_unit_names,'tokens'); %,'uni',false);
token_matches = token_matches{:};

% Extract the unit name and then data-analysis-name into nexCols_unit_data
unit_name = token_matches{1};
result_name = token_matches{2};
end

