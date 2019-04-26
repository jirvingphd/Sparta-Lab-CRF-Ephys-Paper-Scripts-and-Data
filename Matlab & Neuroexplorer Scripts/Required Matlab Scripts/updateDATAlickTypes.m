%% updateDATAlickTypes.m
% This script will replace the finalLickResponse field of DATA.units with the
% new licktype from RESUTLS, created by TESTclassificationDATA. It will add
% DATA.units.oldLickType to save the original value first.
%
for Q = 1:length(DATA)
    %     currEventPulse=DATA(Q).fileinfo.events.EventPulse;
    %     currEventLick=DATA(Q).fileinfo.events.EventLick;
    
    %     if length(currLickEvents)<20
    %         continue
    %     end
    if DATA(Q).fileinfo.include==0
        continue
    end
    if isempty(RESULTS(Q).units)
        continue
    end
    for u=1:length(DATA(Q).units)
        if isempty(DATA(Q).units(u).finalLickResponse)
            continue
        end
        if isfield(DATA(Q).units(u),'oldLickType')==0
            DATA(Q).units(u).originalLickResponse=DATA(Q).units(u).finalLickResponse;
        end
%         if DATA(Q).units(u).include==0
%             continue
%         end
%         if isfield(DATA(Q).units(u),'oldLickType')
%             currFinalType=DATA(Q).units(u).finalLickResponse;
%             currOldType=DATA(Q).units(u).oldLickType;
%             fprintf('WARNING: oldLickType already exists for DATA(%d).units(%d)...\n',Q,u)
%             fprintf('Current oldLickType:%s; \n current finalLickType:%s.\n',currOldType,currFinalType)
%             choice=input('Replace finalLickType and oldLickType?: "y" or "n"','s');
%             if strcmp(choice,'n')>0
%                 continue
%             elseif strcmp(choice,'y')>0
%                 fprintf('Replaced.\n')
%                 
%             end
%         end
            
            oldLickType=DATA(Q).units(u).finalLickResponse;
            newLickType=RESULTS(Q).units(u).lickTypeTest;
            
            DATA(Q).units(u).oldLickType=oldLickType;
            DATA(Q).units(u).finalLickResponse=newLickType;
            DATA(Q).units(u).finalLickStats=RESULTS(Q).units(u).Licks.WilcStats;
        end
end
    fprintf('You may want to run updateBURSTunitsLickTypes now.\n')
% end
    %         currSpikes=DATA(Q).units(u).ts;
    %         if isempty(currSpikes)
    %             continue
    %         end