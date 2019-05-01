function [fileinfo] = detect_drink_type_and_day(fileinfo,type_day_or_both)%,inputArg2)
%detect_drink_type_and_day(fileinfo,type_day_or_both) takes a DATA.fileinfo
%structure and type_day_or_both, which must be 'type','day',or 'both'
%(default=both)
% uses contains to check for 'water','ethanol','sucrose' in file name
% uses regexp to detect and extract day #
% returns updated fileinfo structure to be added to original DATA
% structure. 
if nargin<2
    type_day_or_both='both';
end
%% Detect from filenames
% if strcmpi(user_choice,'y')
% for Q=1:length(DATA)
curr_file = fileinfo.filename;
if strcmpi(type_day_or_both,'both') || strcmpi(type_day_or_both,'drink')
%%Detect drink
    drink_type=NaN;
    if contains(curr_file,'water')
        drink_type = 'water';
    elseif contains(curr_file, 'ethanol')
        drink_type = 'ethanol';
    elseif contains(curr_file,'sucr')
        drink_type = 'sucrose';
    else
        fprintf('Drink name not found.\n')
    end
    fprintf('File %s: drinkType=%s',curr_file,drink_type);
end

%%Detect day
if strcmpi(type_day_or_both,'both') || strcmpi(type_day_or_both,'day')

%         [match] = regexpi(curr_file,'(day.?\d{1,2})','match');
[tokens] = regexpi(curr_file,'(day)[\_\-\s]{1,}(\d{1,2})','tokens');
drink_day=NaN;
if isempty(tokens)
    fprintf('No day number found.\n')
else
    drink_day = tokens{1}{2};
end
fileinfo.drinkType = drink_type;
fileinfo.drinkDay = drink_day;
end
% end
% outputArg1 = filename;
% outputArg2 = inputArg2;
% end

