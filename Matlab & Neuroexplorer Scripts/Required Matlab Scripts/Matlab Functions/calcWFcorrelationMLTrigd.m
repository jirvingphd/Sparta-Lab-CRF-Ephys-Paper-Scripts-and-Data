%%%%calcWFcorrelationMLTrigd.m 
%%Created 02/26/17
%%Takes nex WF output variables and calculates/plots average WFs and calculates correlation for phototagging
%Called by NexCombinedDATAstruct.m which already collected and created the WFs structure and interval variables

% WFs=sendWFs;
intList=sendIntervals;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%CALCULATE AND SAVE FILTERED WFs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(WFs)

	currWaves=WFs(j).waves;
	currWaveName=WFs(j).name;
	currWavesTimes=WFs(j).times; 

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%FIND ALL ENTRIES OF data THAT MEET ANY INTERVAL IN int%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	dataToTest=currWavesTimes;
    t=1;
	while t<=length(intList)
		currIntName=intList(t).intName;
        if strcmp(currIntName,'AllFile')
            t=t+1;
            continue
        end
        currIntTimes=intList(t).intTimes;
		int=currIntTimes;
        % int=eval(currIntName);

		indCumul=[];
		dataCumul=[];
        
        %%%Test against each interval 
		for i=1:size(int,1)
		    [ind] = find(dataToTest >= int(i,1) & dataToTest < int(i,2));
		   
		    resData=dataToTest(ind)';
		    dataCumul=[dataCumul;resData];
		    indCumul=[indCumul ind];

		    indFiltTimes=indCumul;
		    filtTimes=currWavesTimes(indFiltTimes);
        end

        %%%Save filtered timestamps and waveforms
		% filtTimes=currWavesTimes(indCumul);
		filtWaves=currWaves(indFiltTimes,:);
	 
		WFs(j).filtered.(currIntName).filtTimes=filtTimes;
		WFs(j).filtered.(currIntName).filtWaves=filtWaves;
        t=t+1;
	end
    addDATA.units(j).filteredWaves=WFs(j).filtered;
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%THE BELOW SECTION IS ALSO SEPARATED IN calcWFcorrelation_postWFs.m%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%PLOT & CALCULATE STATS FOR UNITS WITH PT Neurons (int10ms waves >2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
w=1;
while w<=length(WFs)

    % intNames=fieldnames(WFs(w).filtered);
    calcMatrix=[];
    intFields=fieldnames(WFs(w).filtered);
    %%%Use testEmpty to check for empty filtered waves
    % for t=1:length(intList)
    t=1;
    for t=1:length(intFields)
        if size(WFs(w).filtered.(intFields{t}).filtWaves,1)>2
            calcMatrix(:,t)=mean(WFs(w).filtered.(intFields{t}).filtWaves);
            % calcMatrix(:,t)=mean(WFs(w).filtered.(intNames{t}).filtWaves);
            testEmpty(t)=1;
        else
            testEmpty(t)=0;
        end
    end
    
    %%%If any filtered wave is empty, skip and go to next w
    if all(testEmpty)==0
        indNoWFs=w;
        w=w+1;
        continue
    end
    
    
    %%%%%%%%%%CALCULATE CORRELATION COEFFIICENT
    [R P]=corrcoef(calcMatrix(:,1),calcMatrix(:,2));

    WFs(w).stats.corrcoef.res=R;
    WFs(w).stats.corrcoef.Rsquare=R.^2;
    WFs(w).stats.corrcoef.p_mat = P;
    WFs(w).stats.corrcoefPval=P(2);
     clearvars P R
    %%%%%%%%%%CALCULATE CROSS CORRELATION
    [xR xL]=xcorr(calcMatrix(:,1),calcMatrix(:,2),31,'coeff');
    
    WFs(w).stats.xcorr.res=xR;
    WFs(w).stats.xcorr.lag=xL;
    WFs(w).stats.xcorr.pearsons_R = xR; 
    WFs(w).stats.xcorr.Rsquare=xR.^2;
    WFs(w).stats.xcorrR=xR(32); % 32 is where lag/xL==0;

    % %%%IS CRF WAVEFORM CRITERION 
    %     if xR(32)>=0.9
    %         WFs(w).stats.pass.xcorr='Y';
    %     elseif xR(32)<0.9
    %         WFs(w).stats.pass.xcorr='N';
    %     end
    % %%%
    addDATA.units(w).lightResponse.tests.waves=WFs(w).stats;
    % addDATA.units(w).tests.pass=WFs(w).isCRF;
    w=w+1;
    %WFs(w).stats.xcorr.sig=P;
    %%%%%
            % %%%%%%%%%%CALCULATE ENERGY (INTEGRAL(V^2))
            % i=integral()
end

disp('calcWFcorrelationMLTrigd has finished.')

