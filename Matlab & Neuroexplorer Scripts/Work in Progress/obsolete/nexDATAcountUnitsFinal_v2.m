%%This script creates the COUNTS structure, with 3 main branches,light, lick, and lightLick

%fields needed:
%DATA(Q).units(u).finalLightResponse; Values['NR','CRF','excited','inhibited']
%DATA(Q).units(u).finalLickResponse; Values['inhibited','predictive','NR',predictExcited','excited']

%% This new version of the script is intended to make COUNTS more user-friendly to visually inspect.
% the new structure will be so that the counts and index fields will now be
% split BEFORE the acutally light and lick types. That way examine
% COUNTS.light.counts will actually show all of the counts on one screen. 
%COUNTS.(light / lick).counts.(light/lick types)=0
%COUNTS.(light / lick).counts.(light/lick types)={}
%% Create a pre-fill COUNTS
COUNTS=struct();
light={'CRF','excited','inhibited','NR'};
lick={'excited','inhibited','predictive','predictiveExcited','NR'}; %replaceed predictiveExcited with pred-inc
% subFields.count=0;
% subFields.index={};

for i=1:length(light)
    currEntry=light{i};
    COUNTS.light.count.(currEntry)=0;
    COUNTS.light.index.(currEntry)={};
    
end

for i=1:length(lick)
    currEntry=lick{i};
    COUNTS.lick.count.(currEntry)=0;
    COUNTS.lick.index.(currEntry)={};
end

for i=1:length(light)
    COUNTS.lightLick.(light{i})=[];
    for k=1:length(lick)
        COUNTS.lightLick.(light{i}).count.(lick{k})=0;
        COUNTS.lightLick.(light{i}).index.(lick{k})= {};
        currEntry=light{i};
    end
end


%% New section 02-26-18
dataTypeNames={'lightLick'}; %only runs on the light - lick categoriesfprintf('This version of the script will only count light.lick types.\n')
d=1;
% for d=1:length(dataTypeNames)
currDataType= dataTypeNames{d};

for Q=1:length(DATA)
    
    %Ignore files marked for exclusion
    if DATA(Q).fileinfo.include==0
        continue
    end
    
    for u=1:length(DATA(Q).units)
        
         %Ignore units marked for exclusion
        if DATA(Q).units(u).include==0
            continue
        end

        %Get units response types 
        currLightType=DATA(Q).units(u).finalLightResponse;
        currLickType=DATA(Q).units(u).finalLickResponse;

%        
%         %%%Verify and report any missing classifications. 
%         if isempty(currLightType)
%             DATA(Q).units(u).include=0;
%             msg=sprintf('WARNING: Light Class missing: DATA(%d).units(%d).\n',Q,u);
%             warning(msg);
%             
%         elseif isempty(currLickType)
%             DATA(Q).units(u).include=0;
%             msg=sprintf('WARNING: Lick Class missing: DATA(%d).units(%d).\n',Q,u);
%             warning(msg);
%             continue
%         else
%             fprintf('--DATA(%d).units(%d) is light-%s, lick-%s. \n',Q,u,currLightType,currLickType);
%         end
        
        
      %% UPDATE COUNTS
      clearvars currCount* newCount* currIdx* newIdx*
      
      %%% UPDATE GENERAL LGIHT COUNT
        currCountLight = COUNTS.light.count.(currLightType);
        currIdxMatLight= COUNTS.light.index.(currLightType);
        newCountLight= currCountLight+1;
        newIdxMatLight=[currIdxMatLight ; Q, u];
        COUNTS.light.count.(currLightType)=newCountLight;
        COUNTS.light.index.(currLightType)=newIdxMatLight;       
        
        
      %%% UPDATE GENERAL LICK COUNT
        currCountLick = COUNTS.lick.count.(currLickType);
        currIdxMatLick= COUNTS.lick.index.(currLickType);
        newCountLick= currCountLick+1;
        newIdxMatLick=[currIdxMatLick ; Q, u];
        COUNTS.lick.count.(currLickType)=newCountLick;
        COUNTS.lick.index.(currLickType)=newIdxMatLick;    
        
    %%% UPDATE LIGHTLICK COUNTS.
        currCount=COUNTS.(currDataType).(currLightType).count.(currLickType);
        currIdxMat=COUNTS.(currDataType).(currLightType).index.(currLickType);
        
        newIdxMat=[currIdxMat ; Q, u];
        newCount=currCount+1;
        
        COUNTS.(currDataType).(currLightType).count.(currLickType)=newCount;
        COUNTS.(currDataType).(currLightType).index.(currLickType)=newIdxMat;
        
    end
end

fprintf('Clearing variables except those defined in "clearCRFdata.m"...\n')
fprintf('Running counts2table')
counts2table
clearCRFdata

