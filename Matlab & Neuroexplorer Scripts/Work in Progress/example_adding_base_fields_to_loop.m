data_fields={'user specified','fieldnames'}
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