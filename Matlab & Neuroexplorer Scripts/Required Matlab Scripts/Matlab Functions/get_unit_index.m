function [output_index,split_unit_name,split_data_type] = get_unit_index(DATA,Q,unit_to_find)
%get_unit_index accepts the DATA structure and unit_name and finds the
%   accept unit_name, search through DATA(Q).units.name and return the u
%   value as output
% Extract the name of the units from the results columns
% [token_matches]= regexpi(unit_to_find,'(SPK\d\d[a-h])\s(\w*)','tokens'); %,'uni',false);
if contains(unit_to_find,'sig','IgnoreCase',true)
    regex = '(sig\d{2,3}[a-h])\s?(\w*)';
else
    regex = '(SPK\d\d[a-h])\s?(\w*)';
end
[token_matches]= regexpi(unit_to_find,regex,'tokens'); %,'uni',false);

token_matches = token_matches{:};

% Extract the unit name and then data-analysis-name into nexCols_unit_data
split_unit_name = token_matches{1}{1};
split_data_type = token_matches{1}{2};
%     next_Burst_data_units{n,3}=cell2mat(nex_Burst_results{n});
% end
output_index = [];
for u=1:length(DATA(Q).units)
    if contains(DATA(Q).units(u).name,split_unit_name,'IgnoreCase',true)
        output_index = [output_index;u];
    end
end
if isempty(output_index)
    warning('No corresponding unit found.')
end
% fprintf('Unit: %s',u)

