function [retreived_data_cells] = fetch_unit_type_data(DATA_structure, light_type,lick_type,data_fields)

%UNTITLED5 Retreives the specified data field for the specified light_type
%and lick_type.
%   User must specifiy fields of target data using a cell array of strings.
%   1 cell for each field

if nargin <4
    data_fields={"spikeRate","ratesClean"};
end
if nargin < 3
    lick_type = "all"
end
if nargin <2
    light_type="all"
end
DATA = DATA_structure;
retreived_data = {};
user_light_type=light_type;

for D=1:length(DATA)
    
    for u=1:length(DATA(D).units)
        fetch_data={};
        % check for lick_type
        if contains(light_type,"all",'IgnoreCase',true)
            user_light_type=DATA(D).units(u).finalLightResponse;
        else
            user_light_type = light_type;
        end
        
        check_type_light= DATA(D).units(u).finalLightResponse;

        if check_type_light == user_light_type
            
            % Specify base of structure to test for all speciified
            % data_fields
            %             DATA_base =
            DATA_base = DATA(D).units(u) ;
            
            % Loop through number of subfields, adding fields to DATA_base
            % to find target field.
            for f=1:length(data_fields)
                add_base_field = data_fields{f};
                if isfield(DATA_base, add_base_field)
                    DATA_base = DATA_base.(add_base_field);
                    fprintf("DATA_base added %s field.\n",add_base_field)
                end
            end
            disp(DATA_base);
            fetch_data{1,1} = [D, u];
            fetch_data{2,1} = [string(DATA(D).units(u).finalLightResponse); string(DATA(D).units(u).finalLickResponse)];
            fetch_data{3,1} = DATA_base;
            DATA_base = DATA(D).units(u) ;
            retreived_data = [retreived_data; {fetch_data}];
            
        else
            continue
        end
    end
    
    % check for light_type
    %         if
    retreived_data_cells = retreived_data;
end

