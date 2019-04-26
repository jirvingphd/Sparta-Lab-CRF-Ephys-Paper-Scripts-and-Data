%%nexDATA_fillDrinkDay
% fprintf('First running renameDATAfileinfoDrinkTypeDay')

for Q=1:length(DATA)
    
    fprintf('File(%d): %s.\n',Q,DATA(Q).fileinfo.filename);
    
    %% Check for pre-existing drinkType or drinkFields to fill currDrinkPreInput
    currDrinkPreInput=[];
    if isfield(DATA(Q).fileinfo,'drinkType')
        currDrinkPreInput = DATA(Q).fileinfo.drinkType;
        
    elseif isfield(DATA(Q).fileinfo,'drink')
        currDrinkPreInput = DATA(Q).fileinfo.drink;  
    end
    
    %% Checking if currDrinkPreInput is empty or NaN, if so ask user for input
    if isempty(currDrinkPreInput) || isnan(currDrinkPreInput)
        checkDrinkOutput=input('Drink type? Enter W, E, or S:\n','s');
        if checkDrinkOutput == 'W'
            drink_type = 'water'
            days_drinking = NaN;
        elseif checkDrinkOutput == 'E'
            drink_type = 'ethanol'
            days_drinking = input('Enter the ethanol drinking day(if 5th day mouse has consumed ethanol, enter 5):\n')
            
        elseif checkDrinkOutput == 'S'
            drink_type = 'sucrose'
            days_drinking = NaN;
        end
    else
        fprintf('DATA(%d).fileinfo.drinkType already filled with:%s.\n',Q,currDrinkPreInput);
        drink_type=currDrinkPreInput;
    end
    
    DATA(Q).fileinfo.drinkType=drink_type;
    DATA(Q).fileinfo.drinkDay=days_drinking;
    
end

% clearvars Q checkDrink
clearCRFdata