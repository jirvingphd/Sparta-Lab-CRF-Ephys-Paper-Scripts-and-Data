%minimal_burst_analysis


%% Processing the nex results
% BURSTSbackup=BURSTS;
BURSTunits=struct();
for B=1:length(BURSTS)
    
    if length(BURSTS(B))==length(DATA(B))
        
        %%% First process BRUSTS.results
        [results_array_processed] = split_cell_array_by_column(BURSTS(B).results);
        for n = 1:length(results_array_processed)%,2)
            unit_name = results_array_processed{n}{2,1};
            result_name = results_array_processed{n}{1,1};
            result_data = results_array_processed{n}{3,1};
            [u,~,~] = get_unit_index(unit_name,B,DATA);
            BURSTunits(B).units(u).file_num = B;
            BURSTunits(B).units(u).unit_num = u;
            BURSTunits(B).units(u).name=unit_name;
            BURSTunits(B).units(u).(result_name)=result_data;
        end
        clearvars results_array_processed unit_name result_name result_datas
        
        %%% Now process BURSTS.intervals
        Bfs = BURSTS(B).filtered_spikes';
        [results_array_processed] = split_cell_array_by_column(Bfs);
        
        for n = 1:length(results_array_processed)%,2)
            % create vars from current cell array
            
            unit_name = results_array_processed{n}{2,1};
            if isnan(unit_name)
                continue
            end
                
            result_name = results_array_processed{n}{1,1};
            result_data = results_array_processed{n}{3,1};
            
            [u,check_name,~] = get_unit_index(unit_name,B,DATA);
            % verify correct cell output
            if check_name~=unit_name
                error('unit names do not match');
            end
            
            % temporarily load BURSTunits(B) as currB_units
            currB_units= BURSTunits(B).units;
            %if the name and
            if (currB_units(u).file_num == B) && (currB_units(u).unit_num==u) && (currB_units(u).name ==string(unit_name))
                BURSTunits(B).units(u).(result_name)=result_data;
            else
                error('Mismatch between BURSTunits(%S).units(%s) and filtered spikes',B,u)
            end
        end
        clearvars results_array_processed unit_name result_name result_datas
        
    end
    
end

%% Processing the nex results
for B=1:length(BURSTunits)
    
    if length(BURSTunits(B))~=length(DATA(B))
        error(sprintf('BURSTunits length = %d, but DATA length = %d',length(BURSTunits(B)),length(DATA(B))));
    else
        for u=1:length(BURSTunits(B).units)
            burst_unit_name = BURSTunits(B).units(u).name;
            data_unit_name = DATA(B).units(u).name;
            
            if burst_unit_name ~= data_unit_name
                error(sprintf('BURSTunits(%d).units(%d).name=%s, but DATA.units.name= %s',B,u,burst_unit_name,data_unit_name));
            end
        end
    end
end
% fprintf('Finished, all BURSTunits.units match DATA.units.\n')
clearCRFdata


%% Calculate and fill in spikes in bursts statistics
for Q=1:length(BURSTunits)
    
    for u=1:length(BURSTunits(Q).units)
        
        % Calcualte NUmber of Burst Spikes
        if isfield(BURSTunits(Q).units(u),'BurstSpikes')
            numBurstSpikes=length(BURSTunits(Q).units(u).BurstSpikes);
        else
            numBurstSpikes=0;
        end
        
        % Calculate Number of Non-Burst Spikes
        if isfield(BURSTunits(Q).units(u),'NonBurstSpikes')
            numNonBurstSpikes=length(BURSTunits(Q).units(u).NonBurstSpikes);
        else
            numNonBurstSpikes=0;
        end
        
        % Calculate total spikes (from bursts and non-bursts)
        totalSpikes=numBurstSpikes+numNonBurstSpikes;
        
        % Calculate % of spikes in bursts.
        currPercBurstSpike=numBurstSpikes/totalSpikes*100;
        
        % Calcualte meanFreqInBurst
        meanFreqInBurst =  BURSTunits(Q).units(u).SpikesInBurst./BURSTunits(Q).units(u).BurstDuration;
        
        %Verify if there are bursts b
        if isempty(BURSTunits(Q).units(u).BurstStart)
            BURSTunits(Q).units(u).totalSpikes=totalSpikes;
            BURSTunits(Q).units(u).percSpikesInBursts=NaN;
            BURSTunits(Q).units(u).meanFreqInBurst = NaN;
            BURSTunits(Q).units(u).BurstsPerSecond = NaN;
            
        else            
            % Calcualte BurstsPerSecond
            BurstsPerSecond = length(BURSTunits(Q).units(u).BurstStart) /(BURSTunits(Q).units(u).BurstStart(end)-BURSTunits(Q).units(u).BurstStart(1));
            %%Fill in results
            BURSTunits(Q).units(u).totalSpikes=totalSpikes;
            BURSTunits(Q).units(u).percSpikesInBursts=currPercBurstSpike;
            BURSTunits(Q).units(u).meanFreqInBurst = meanFreqInBurst;
            BURSTunits(Q).units(u).BurstsPerSecond = BurstsPerSecond;
        end
    end
end
clearCRFdata