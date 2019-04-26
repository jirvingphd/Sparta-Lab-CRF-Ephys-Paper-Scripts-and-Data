% %% This script is being written to try to automate burst analysis process, which requires both matlab and neuroexplorer.
% 
% 
% 
% %% Run the code used in makeUnitTimestampVarsForAll
% for Q=1:length(DATA)
%     
%     for u=1:length(DATA(Q).units)
%         
%         neuronTypeLight =   DATA(Q).units(u).lightResponse.type;
%         neuronTypeLick  =   DATA(Q).units(u).lickResponse.type;
%         
%         labelLight='';
%         switch neuronTypeLight
%             %             case 'all'
%             %                 continue
%             case 'CRF'
%                 labelLight='C';
%             case 'inhibited'
%                 labelLight='I';
%             case 'NR'
%                 labelLight='NR';
%             case 'excited'
%                 labelLight='E';
%         end
%         
%         
%         
%         labelLick='';
%         switch neuronTypeLick
%             %             case 'all'
%             %                 continue
%             case 'excited'
%                 labelLick='E';
%             case 'inhibited'
%                 labelLick='I';
%             case 'predictive'
%                 labelLick='P';
%             case 'predictExcited'
%                 labelLick='PE';
%             case 'NR'
%                 labelLick='NR';
%         end
%         % eval(sprintf('CUnit_%s_%d_%d = DATA(%d).units(%d).ts;',labelLick,Q,u,Q,u)); %had to change this so
%         % %that the file number came first, so knew which cells to group for
%         % %cross corr
%         eval(sprintf('FUnit_%d_%d_%s_%s = DATA(%d).units(%d).ts;',Q,u,labelLight,labelLick,Q,u));
%     end
% end
% 
% 
% clear label* neuronType* Q u
% save('FUnitsToNexForBursts.mat','FUnit*')
% fprintf('\n\n NOTE: "FUnitsToNexForBursts.mat" was saved to current folder.\n\n');
% clearvars FUnit*
% fprintf('Next: run NeuroExplorer, "open matlab as engine"\n In new Matlab window, load FUnitsToNexForBursts.mat.\n')
% fprintf('Then run the nexScript "BurstIntervals for All Units in Burst.nsc"\n')



%% Connect with NeuroExplorer to transfer data for Burst Analysis
nex = actxserver('NeuroExplorer.Application');
doc = nex.OpenDocument('D:\Users\James\Dropbox (Personal)\DID-4 to clean\DID Analysis Tutorial\CeA CRF OA2-1 RecDay2 Water -DID - CUT PT COMBINED UNITS_think-FIN.nex5');
% doc.DeselectAll();
res = nex.RunNexScript('_MakeDIDEventNamesFixed.nsc');
%% Select neurons
% res = nex.RunNexScript('select_sorted_neurons.nsc');
neuronList=[];
addBURSTS=struct();
%Get the names of all neurons
neuronCount=doc.NeuronCount;
for n=1:neuronCount
    currNeuron=doc.Neuron(n);
    currNeuronName=currNeuron.Name;
    neuronNames{n}=currNeuronName;
    %addBURSTS
end

% Select Only Sorted Neurons(does not contain 'i' at the end of the name
regRes=cellfun(@(x)regexpi(x,'(sig0|SPK)\d{2,}.?[a-g]','match'),neuronNames,'UniformOutput',0);
empty=cellfun(@isempty,regRes);
regRes(empty)=[];
sortedNeuronList=regRes;

%% Run Burst analysis template
doc.DeselectAll()
for n=1:length(sortedNeuronList)
    currNeuronName=char(sortedNeuronList{n});
    doc.Variable(currNeuronName).Select();
end  
    
doc.ModifyTemplate('_CRFburstsParamA','Add Burst Interval Vars.','True')
doc.ModifyTemplate(doc,"_CRFburstsParamA","Send to Matlab","False")
doc.ApplyTemplate('_CRFburstsParamA')
addBURSTS.results=doc.GetNumericalResults;
        
for m=1:length(sortedNeuronList)
    currNeuronName=char(sortedNeuronList{m});
    doc.Variable(currNeuronName).Select();

    command = sprintf('doc["%s_BurstSpikes"] = IntervalFilter(doc["%s"], doc["AllFile"])',currNeuronName,currNeuronName,currNeuronName);

    command = sprintf('doc["%s_BurstSpikes"] = IntervalFilter(doc["%s"], doc["%s bursts"])',currNeuronName,currNeuronName,currNeuronName);
    res = nex.RunNexScriptCommands('doc = GetActiveDocument()\n',command)

    res = nex.RunNexScriptCommands(command)
    
    doc[currNeuronName+"_BurstSpikes"] = doc.IntervalFilter(doc[currNeuronName], doc[currNeuronName+" bursts"])    
    doc[currNeuronName+"_IntNonBurst"] = doc.IntOpposite(doc, doc[currNeuronName+" bursts"])
    doc[currNeuronName+"_NonBurstSpikes"] = doc.IntervalFilter(doc[currNeuronName], doc[currNeuronName+"IntNonBurst"])

end
