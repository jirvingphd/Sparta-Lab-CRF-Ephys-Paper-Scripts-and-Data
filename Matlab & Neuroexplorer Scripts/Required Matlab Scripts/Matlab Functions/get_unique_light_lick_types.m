function [fields_list] = get_unique_light_lick_types(DATA)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fields_list={};
light_types={};
lick_types={};
for Q=1:length(DATA)
    for u=1:length(DATA(Q).units)
        light_types = vertcat(light_types, DATA(Q).units(u).finalLightResponse);
        lick_types  = vertcat(lick_types, DATA(Q).units(u).finalLickResponse);
    end
end
fields_list{1}=unique(light_types);
fields_list{2}=unique(lick_types);

% b = 1; %branch index
% for s = 1:length(STRUCT)
%     b=1;
%     BRANCH = STRUCT(s);
%     fields = fieldnames(BRANCH);
%     fields_list(s,b) = fields;
%     
%     b=b+1; %second column of fieldnames
%     for f = 1:length(fields)
%         
%         subfields = fieldsnames(BRANCH.(fields{f}));
%         fields_list(s,b)=subfields;
%         
%         for sub=1:length(subfields)
%             subsubfields=fieldnames(BRANCH(s_
% %         add_base_field=fields{f};
% %         if isfield(BRANCH, add_base_field)
%             %first, get list of fieldnames 
%             
%             % next, add fieldnames to fields_list
%             
%             %
%             
%             BRANCH = BRANCH.(add_base_field);
%         
%         fields_list{s,2}{f,1}=fieldnames(STRUCT(s).(fields_list{s,1}{f,1}));
%     end
% end
% %         BASE = STRUCT(s).(fields_list{s2})
% 
% fields_list_out = fields_list;

