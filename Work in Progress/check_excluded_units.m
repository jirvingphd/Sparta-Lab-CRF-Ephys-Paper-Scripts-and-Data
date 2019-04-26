% count_excluded_units.m
%
% This is from calcWFcorrelationMLTrigd (which is triggerd by
% NexCombinedDATAstruct to extract unit data from Nex:
% 
%    % intNames=fieldnames(WFs(w).filtered);
%     calcMatrix=[];
%     intFields=fieldnames(WFs(w).filtered);
%     %%%Use testEmpty to check for empty filtered waves
%     % for t=1:length(intList)
%     t=1;
%     for t=1:length(intFields)
%         if size(WFs(w).filtered.(intFields{t}).filtWaves,1)>2
%             calcMatrix(:,t)=mean(WFs(w).filtered.(intFields{t}).filtWaves);
%             % calcMatrix(:,t)=mean(WFs(w).filtered.(intNames{t}).filtWaves);
%             testEmpty(t)=1;
%         else
%             testEmpty(t)=0;
%         end
%     end
%     ....
%   %%%%%%%%%%CALCULATE CORRELATION COEFFIICENT
%     [R P]=corrcoef(calcMatrix(:,1),calcMatrix(:,2));
% 
%     WFs(w).stats.corrcoef.res=R;
%     WFs(w).stats.corrcoef.Rsquare=R.^2;
%     WFs(w).stats.corrcoefPval=P(2);
%      
%     %%%%%%%%%%CALCULATE CROSS CORRELATION
%     [xR xL]=xcorr(calcMatrix(:,1),calcMatrix(:,2),31,'coeff');
%     
%     WFs(w).stats.xcorr.res=xR;
%     WFs(w).stats.xcorr.lag=xL;
%     WFs(w).stats.xcorr.Rsquare=xR.^2;
%     WFs(w).stats.xcorrR=xR(32);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Light response code
%         %% LOGIC TESTS FOR LIGHT CLASSIFICATION "TYPE"
%         
%         % 1A) Does the unit's spike activity change pre vs post laser pulse? (p<=.05)
%         if DATA(Q).units(u).lightResponse.tests.PrePost.p<=0.05
%             
%             % If so...
%             % 1B) How did the unit's activity change with the light pulse? What was the sign (+/-) of the change pre vs post?
%             switch sign(DATA(Q).units(u).lightResponse.tests.PrePost.PrePostChange)
%                 case 1
%                     type='inc';
%                 case 0
%                     type= '0';
%                 case -1
%                     type='dec';
%             end
%             
%             % If not...
%             % Unit light response type = "NR"
%         elseif DATA(Q).units(u).lightResponse.tests.PrePost.p>0.05
%             type='NR';
%         end
%         
%         
%         % 2) Was the cross correlation between light-evoked and non-evoked waveforms significant? (cross corr R value >0.9)
%         % First, make sure current unit has waveform data, if not
%         if isfield(DATA(Q).units(u).lightResponse.tests,'waves')==0 || isempty(DATA(Q).units(u).lightResponse.tests.waves)==1;
%             DATA(Q).units(u).lightResponse.tests.waves=[];
%             CRF=false;
%             
%             % 3) Final result: Did the firing rate increase  pre vs post AND was the waveform  xcorr R value is >0.9??
%         elseif strcmp(type,'inc') && (DATA(Q).units(u).lightResponse.tests.waves.xcorrR>0.9 )
%             % if so, classify as CRF.
%             CRF=true;
%         else
%             % if not, classify as non-CRF
%             CRF=false;
%         end
%         
%         
%         % RENAME the lightTypes to match later script references.
%         switch type
%             case 'inc'
%                 lightType='excited';
%                 
%             case 'dec'
%                 lightType='inhibited';
%                 
%             case 'NR'
%                 lightType='NR';
%         end
%         
%         % SAVE the light type results to DATA(Q).units(u).lightResponse: .type and .CRF
%         DATA(Q).units(u).lightResponse.type     =   lightType;
%         DATA(Q).units(u).lightResponse.CRF      =   CRF;
%         
%         %%% FILL IN FINAL LICK RESPONSE CLASSIFICATION
%         DATA(Q).units(u).finalLightResponse=[''];
%         if CRF==true
%             DATA(Q).units(u).finalLightResponse='CRF';
%         elseif CRF==false
%             DATA(Q).units(u).finalLightResponse=lightType;
%             lightType=[]; type=[];    CRF=[];
%         end
%   
%% Extract pertinent info to waves structure
%extract_waveform_data.m
disp('Scripts to reference: calcWFcorrelationMLTrigd & nexDATAclassificationFixWIP2')
WAVES = struct();
%% START LOOPING THROUGHT EVERy DATA FILE
for Q = 1:length(DATA)
    WAVES(Q).fileinfo=DATA(Q).fileinfo;
    
    %% CALCULATE WILCOXON SIGN RANK TEST FOR LIGHT AND LICK RESPONSES FOR EACH UNIT(u)
    for u=1:length(DATA(Q).units)
        WAVES(Q).units(u).idx=[Q,u];
        if isfield(DATA(Q).units,'lightResponse')
            
            WAVES(Q).units(u).finalLightResponse = DATA(Q).units(u).finalLightResponse;
            WAVES(Q).units(u).finalLickResponse = DATA(Q).units(u).finalLickResponse;
            WAVES(Q).units(u).include = DATA(Q).units(u).include;
            
            WAVES(Q).units(u).filteredWaves = DATA(Q).units(u).filteredWaves;
            WAVES(Q).units(u).lightResponse = DATA(Q).units(u).lightResponse;

        end
    end
end


% %% START LOOPING THROUGHT EVERy DATA FILE
% for Q = 1:length(DATA)
%     
%     
%         
%     
%     %% CALCULATE WILCOXON SIGN RANK TEST FOR LIGHT AND LICK RESPONSES FOR EACH UNIT(u)
%     for u=1:length(DATA(Q).units)
%         
%         % Extract and save the Waveform analysis results calculated in NexCombineDATAstruct
%         if isfield(DATA(Q).units(u).lightResponse.tests,'waves')
%                 WilcStatsLight.waves=DATA(Q).units(u).lightResponse.tests.waves;
% 
%         end
%     end
% end
%% Section from nexDATAclassificationFixWIP2