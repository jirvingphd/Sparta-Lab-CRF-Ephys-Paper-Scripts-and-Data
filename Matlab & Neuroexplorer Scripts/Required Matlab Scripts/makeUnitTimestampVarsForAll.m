
%%Generate CRFcounts and make labeled unit variables for Nex
%If it doesn't exist, make CRFcounts

%X CRFcounts.all=COUNTS.light.CRF;
%X lightLickFields=fieldnames(COUNTS.lightLick.CRF)
%X for i=1:length(lightLickFields)
    %X CRFcounts.(lightLickFields{i})=COUNTS.lightLick.CRF.(lightLickFields{i})
%X end

%X CRFtypes=fieldnames(CRFcounts);
%X for c=2:length(CRFtypes)
for Q=1:length(DATA)

    for u=1:length(DATA(Q).units)
    %     if strcmp(CRFtypes{c},'all')
    %         c=c+1;
    %         continue
    %     end
%X    %Get indices of current Type
%X    COUNTSindex=CRFcounts.(CRFtypes{c}).index;
%X    neuronType=char(CRFtypes{c});
neuronTypeLight =   DATA(Q).units(u).lightResponse.type;
neuronTypeLick  =   DATA(Q).units(u).lickResponse.type;
% neuronTypeLight=DATA(Q).units(u).finalLightResponse; %lightResponse.type;
% neuronTypeLick=DATA(Q).units(u).finalLickResponse;


%X    numUnits=size(COUNTSindex,2);
%X    %X
    
%X    %     for i=1:numUnits
%X    %         idxUnits(i,1)=(COUNTSindex{i}(1));
%X    %         idxUnits(i,2)=(COUNTSindex{i}(2));
%X    %     end
%X    
%X    %X
    
%X    for i=1:numUnits
%X        Q=(COUNTSindex{i}(1));
%X        u=(COUNTSindex{i}(2));
        
        %         currentType=(CRFtypes{c});

%%08/28/17 : Must figure out how to name units with letter code without COUNTS
        labelLight='';
        switch neuronTypeLight
            %             case 'all'
            %                 continue
            case 'CRF'
                labelLight='C';
            case 'inhibited'
                labelLight='I';
            case 'NR'
                labelLight='NR';
            case 'excited'
                labelLight='E';
        end



        labelLick='';
        switch neuronTypeLick
            %             case 'all'
            %                 continue
            case 'excited'
                labelLick='E';
            case 'inhibited'
                labelLick='I';
            case 'predictive'
                labelLick='P';
            case 'predictExcited'
                labelLick='PE';
            case 'NR'
                labelLick='NR';
        end
        % eval(sprintf('CUnit_%s_%d_%d = DATA(%d).units(%d).ts;',labelLick,Q,u,Q,u)); %had to change this so
        % %that the file number came first, so knew which cells to group for
        % %cross corr
        eval(sprintf('FUnit_%d_%d_%s_%s = DATA(%d).units(%d).ts;',Q,u,labelLight,labelLick,Q,u));
    end
end


clear label* neuronType* Q u 
save('FUnitsToNexForBursts.mat','FUnit*')
fprintf('\n\n NOTE: "FUnitsToNexForBursts.mat" was saved to current folder.\n\n');
clearvars FUnit*
fprintf('Next: run NeuroExplorer, "open matlab as engine"\n In new Matlab window, load FUnitsToNexForBursts.mat.\n')
fprintf('Then run the nexScript "BurstIntervals for All Units in Burst.nsc"\n')