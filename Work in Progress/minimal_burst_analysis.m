%minimal_burst_analysis

BURSTSbackup=BURSTS;
BURSTunits=struct();


%% Processing the nex results
for B=1:length(BURSTS)
    
    if length(BURSTS(B))==length(DATA(B))
        nex_Burst_cols=BURSTS(B).results(1,:);
        nex_Burst_results = BURSTS(B).results(2,:);
        for n = 1:length(nex_Burst_cols)%,2)
            [u,unit_name,column_data] = get_unit_index(DATA,B,nex_Burst_cols(n));
            BURSTunits(B).units(u).name=unit_name;
            if iscell(nex_Burst_results{n})
                BURSTunits(B).units(u).(column_data)=nex_Burst_results{n};
            else
                BURSTunits(B).units(u).(column_data)=nex_Burst_results{n};
            end
        end
        
        
        % Add BurstSpikes, NonBurstSPikes from BURSTS(B).intervals
        nex_Burst_spikes = BURSTS(B).filtered_spikes(:,1);
        nex_Burst_results = BURSTS(B).filtered_spikes(:,2); 
        
        for n = 1:length(nex_Burst_spikes)%,2)
            [u,unit_name,column_data] = get_unit_index(DATA,B,nex_Burst_spikes(n));
            BURSTunits(B).units(u).name=unit_name;
            
            if iscell(nex_Burst_results{n})
               BURSTunits(B).units(u).(column_data)=cell2mat(nex_Burst_results{n});
            else
                BURSTunits(B).units(u).(column_data)=nex_Burst_results{n};
            end
        end
%                 [u,unit_name,column_data] = get_unit_index(DATA,B,nex_Burst_cols(1,n));

        
    end
    
end

%% Processing the nex results
for B=1:length(BURSTunits)
    
    if length(BURSTunits(B))~=length(DATA(B))
        error(sprintf('BURSTunits length = %d, but DATA length = %d',length(BURSTunits(B)),length(DATA(B))))
    else
        for u=1:length(BURSTunits(B).units)
            burst_unit_name = BURSTunits(B).units(u).name
            data_unit_name = DATA(B).units(u).name
            
            if burst_unit_name ~= data_unit_name
                error(sprintf('BURSTunits(%d).units(%d).name=%s, but DATA.units.name= %s',B,u,burst_unit_name,data_unit_name))
            end
        end
    end
end
fprintf('Finished, all BURSTunits.units match DATA.units.\n')
clearCRFdata