%% renameDATAfileinfoDrinkTypeDay.m
% James M Irving 10-04-18
% This script will loop through the DATA structure to rename the
% DATA.fileinfo.drink field to ..drinkType, filling in full word instead of
% only abbreviations , and then adds a field for the drink day #
%Define Drink Types
drinkTypeList={'water','ethanol','sucrose'};
drinkLet={'W','E','S'};
%Rename the drink field to drinkType;
for Q=1:length(DATA)
    currDrinkOutput=[];
    if isfield(DATA(Q).fileinfo,'drink')
        
        if isempty(DATA(Q).fileinfo.drink)
            
            currDrinkInput=NaN;
            
        else
            
            currDrinkInput=DATA(Q).fileinfo.drink;
            
            %%Replace abbreviations with full words
            if strcmpi(currDrinkInput,'W')
                currDrinkOutput='water';
            elseif strcmpi(currDrinkInput,'E')
                currDrinkOutput='ethanol';
            elseif strcmpi(currDrinkInput,'S')
                currDrinkOutput='sucrose';
            end
            
        end
        
        DATA(Q).fileinfo=rmfield(DATA(Q).fileinfo,'drink');
        
    elseif isfield(DATA(Q).fileinfo, 'drinkType') && isempty(DATA(Q).fileinfo.drinkType)==0
        
        currDrinkOutput=DATA(Q).fileinfo.drinkType;
        
    elseif isfield(DATA(Q).fileinfo, 'drinkType') && isempty(DATA(Q).fileinfo.drinkType)==1
        
        currDrinkOutput=NaN;
    end
    
    %%Fill in correct drinkType and remove original drink field
    DATA(Q).fileinfo.drinkType=currDrinkOutput;
   
    
    %Rename the eDayNum field to drinkDay;
    if isfield(DATA(Q).fileinfo,'eDayNum')
        
        currDayNum=DATA(Q).fileinfo.eDayNum;
        DATA(Q).fileinfo.drinkDay=currDayNum;
        DATA(Q).fileinfo=rmfield(DATA(Q).fileinfo,'eDayNum');
        
    elseif isfield(DATA(Q).fileinfo,'drinkDay')
        
        if isempty(DATA(Q).fileinfo.drinkDay)==1
            DATA(Q).fileinfo.drinkDay=NaN;
        elseif isempty(DATA(Q).fileinfo.drinkDay)==0
            fprintf('Skipping DATA(%d), drinkDay already contains data.\n',Q);
            continue
        end
    else 
           DATA(Q).fileinfo.drinkDay=NaN;
    end
    
    
end
% 
clearvars drinkLet drinkTypeList Q
