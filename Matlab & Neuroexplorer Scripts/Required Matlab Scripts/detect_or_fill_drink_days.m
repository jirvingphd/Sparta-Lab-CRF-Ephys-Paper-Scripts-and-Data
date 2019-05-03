%%nexDATA_fillDrinkDay
% fprintf('First running renameDATAfileinfoDrinkTypeDay')
% user_choice = input('Detect drink and day from filenames?:(y/n)\n','s');
%% Detect from filenames
for Q=1:length(DATA)
    
    check_drink='both';
    
    if isempty(DATA(Q).fileinfo.drinkType)
        
        if isempty(DATA(Q).fileinfo.drinkDay)
            
            check_drink = 'both';
            
        else
            
            check_drink = 'drink';
            
        end
        
    elseif isempty(DATA(Q).fileinfo.drinkDay)
        
        check_drink = 'day';
    end
    
    [fileinfo_updated] = detect_drink_type_and_day(DATA(Q).fileinfo,check_drink);
    DATA(Q).fileinfo=fileinfo_updated;
    %         TEST(Q).fileinfo=fileinfo_updated;
    %         curr_file = DATA(Q).fileinfo.filename;
    %
    %         %%Detect drink
    %         drink_type=NaN;
    %         if contains(curr_file,'water')
    %             drink_type = 'water';
    %         elseif contains(curr_file, 'ethanol')
    %             drink_type = 'ethanol';
    %         elseif contains(curr_file,'sucr')
    %             drink_type = 'sucrose';
    %         else
    %             fprintf('Drink name not found.\n')
    %         end
    %         fprintf('File %d: drinkType=%s',Q,drink_type);
    %         %%Detect day
    % %         [match] = regexpi(curr_file,'(day.?\d{1,2})','match');
    %         [tokens] = regexpi(curr_file,'(day)[\_\-\s]{1,}(\d{1,2})','tokens');
    %         drink_day=NaN;
    %         if isempty(tokens)
    %             fprintf('No day number found.\n')
    %         else
    %             drink_day = tokens{1}{2};
    %         end
    %         DATA(Q).fileinfo.drinkType = drink_type;
    %         DATA(Q).fileinfo.drinkDay = drink_day;
end

files_missing_drinkType=[];
for Q=1:length(DATA)
    if isempty(DATA(Q).fileinfo.drinkType) || any(isnan(DATA(Q).fileinfo.drinkType))
        files_missing_drinkType = [files_missing_drinkType, Q];
    end
    fprintf('DATA(%d).fileinfo.drinkType = %s, drinkDay=%s.\n',Q,DATA(Q).fileinfo.drinkType,DATA(Q).fileinfo.drinkDay);
end
% else
% %% Manually fill.
% for Q=1:length(DATA)
%
%     fprintf('File(%d): %s.\n',Q,DATA(Q).fileinfo.filename);
%
%     %% Check for pre-existing drinkType or drinkFields to fill currDrinkPreInput
%     currDrinkPreInput=[];
%     if isfield(DATA(Q).fileinfo,'drinkType')
%         currDrinkPreInput = DATA(Q).fileinfo.drinkType;
%
%     elseif isfield(DATA(Q).fileinfo,'drink')
%         currDrinkPreInput = DATA(Q).fileinfo.drink;
%     end
%
%     %% Checking if currDrinkPreInput is empty or NaN, if so ask user for input
%     drink_type = [];
%     days_drinking = [];
%     if isempty(currDrinkPreInput) || isnan(currDrinkPreInput)
%         checkDrinkOutput=input('Drink type? Enter W, E, or S:\n','s');
%         if checkDrinkOutput == ('W'|'w')
%             drink_type = 'water';
%             days_drinking = NaN;
%         elseif checkDrinkOutput == ('E'|'e')
%             drink_type = 'ethanol';
%             days_drinking = input('Enter the ethanol drinking day(if 5th day mouse has consumed ethanol, enter 5):\n');
%
%         elseif checkDrinkOutput == ('S'|'s')
%             drink_type = 'sucrose';
%             days_drinking = NaN;
%         end
%     else
%         fprintf('DATA(%d).fileinfo.drinkType already filled with:%s.\n',Q,currDrinkPreInput);
%         drink_type=currDrinkPreInput;
%     end
%
%     DATA(Q).fileinfo.drinkType=drink_type;
%     DATA(Q).fileinfo.drinkDay=days_drinking;
%
% end
% % end
% % clearvars Q checkDrink
clearCRFdata