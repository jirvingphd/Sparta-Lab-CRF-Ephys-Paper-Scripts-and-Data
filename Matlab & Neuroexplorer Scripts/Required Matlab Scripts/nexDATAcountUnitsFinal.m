%%This script creates the COUNTS structure, with 3 main branches,light, lick, and lightLick

%fields needed:
%DATA(Q).units(u).finalLightResponse; Values['NR','CRF','excited','inhibited']
%DATA(Q).units(u).finalLickResponse; Values['inhibited','predictive','NR',predictExcited','excited']

%% Create a pre-fill COUNTS
COUNTS=struct();
light={'CRF','excited','inhibited','NR'};
lick={'excited','inhibited','predictive','predictiveExcited','NR'}; %replaceed predictiveExcited with pred-inc
subFields.count=0;
subFields.index={};

for i=1:length(light)
    currEntry=light{i};
    COUNTS.light.(currEntry)=subFields;
    
end

for i=1:length(lick)
    currEntry=lick{i};
    COUNTS.lick.(currEntry)=subFields;
end


% whidxLE j<(length(light)*length(lick))
for i=1:length(light)
    COUNTS.lightLick.(light{i})=[];
    for k=1:length(lick)
        COUNTS.lightLick.(light{i}).(lick{k})=subFields;
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
        currCountLight = COUNTS.light.(currLightType).count;
        currIdxMatLight= COUNTS.light.(currLightType).index;
        newCountLight= currCountLight+1;
        newIdxMatLight=[currIdxMatLight ; Q, u];
        COUNTS.light.(currLightType).count=newCountLight;
        COUNTS.light.(currLightType).index=newIdxMatLight;       
        
        
      %%% UPDATE GENERAL LICK COUNT
        currCountLick = COUNTS.lick.(currLickType).count;
        currIdxMatLick= COUNTS.lick.(currLickType).index;
        newCountLick= currCountLick+1;
        newIdxMatLick=[currIdxMatLick ; Q, u];
        COUNTS.lick.(currLickType).count=newCountLick;
        COUNTS.lick.(currLickType).index=newIdxMatLick;    
        
    %%% UPDATE LIGHTLICK COUNTS.
        currCount=COUNTS.(currDataType).(currLightType).(currLickType).count;
        currIdxMat=COUNTS.(currDataType).(currLightType).(currLickType).index;
        
        newIdxMat=[currIdxMat ; Q, u];
        newCount=currCount+1;
        
        COUNTS.(currDataType).(currLightType).(currLickType).count=newCount;
        COUNTS.(currDataType).(currLightType).(currLickType).index=newIdxMat;
        
    end
end

fprintf('Clearing variables except those defined in "clearCRFdata.m"...\n')
clearCRFdata

