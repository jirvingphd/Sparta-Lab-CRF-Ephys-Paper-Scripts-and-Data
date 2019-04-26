
for Q = 1:length(DATA)
    
    for u=1:length(DATA(Q).units)
        if length(DATA(Q).units)== length(DATA(Q).results.spikeRate.nexCutRateHisto)
            DATA(Q).units(u).spikeRate = DATA(Q).results.spikeRate.nexCutRateHisto(u);
        % else 
        % COUNTS.lightLick.(lightType).(lickType).index=horzcat(COUNTS.lightLick.(lightType).(lickType).index,[Q,u])

        % 	spikeRateError(:,1:2)
        end
    end
end