class_types = fieldnames(COUNTS);
COUNTS_table= struct();
% for light,lick and lightLick
for c=1:length(class_types)
    
    %if lightLick needs another loop
    if strcmpi(class_types{c},'lightLick')
        %         continue
        % get names of cell types
        fields = fieldnames(COUNTS.(class_types{c}));
        %         loop through cell types
        temp_tables = {};
        for f=1:length(fields)
            T = struct2table(COUNTS.(class_types{c}).(fields{f}).count);
            T2 = table(class_types{c},'VariableNames',{'Classification_By'});
            T3 = table(fields{f},'VariableNames',{'lightType'});
            Tcomb = [T2,T3,T];
            temp_tables(f,:)=table2cell(Tcomb);
        end
        
        COUNTS_table.(class_types{c})=cell2table(temp_tables,'VariableNames',Tcomb.Properties.VariableNames);
        
        
    else %for all other fields
        T = struct2table(COUNTS.(class_types{c}).count);
        T2 = table(class_types{c},'VariableNames',{'Classification_By'});
        T = [T2,T];
        COUNTS_table.(class_types{c})=T;
    end
end

fprintf('Displaying contents of COUNTS_table.\n')
count_fields = fieldnames(COUNTS_table);
for c=1:length(count_fields)
    disp(COUNTS_table.(count_fields{c}))
end
