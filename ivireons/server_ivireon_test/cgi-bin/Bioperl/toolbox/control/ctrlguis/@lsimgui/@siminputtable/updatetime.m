function updatetime(inputtable,TXTendTime,TXTtimeStep,LBLnumSamples)
%UPDATETIME
% callback which updates the table when the simulation time interval is
% changed
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/08/20 16:25:21 $

endTime = str2num(char(TXTendTime.getText));
timeStep = str2num(char(TXTtimeStep.getText));

if ~isempty(endTime) && ~isempty(timeStep) % Times in the boxes
    if endTime <= 0
        errordlg(sprintf('The end time must be strictly positive'),'Linear Simulation Tool', 'modal');
        TXTendTime.setText('');
        return
    end
    if timeStep <= 0
        errordlg(sprintf('The time step must be strictly positive'),'Linear Simulation Tool', 'modal');
        TXTtimeStep.setText('');
        return
    end
    
    % Adjust the signal length to match the user entry
    desiredLength = floor((endTime-inputtable.Starttime)/timeStep+1e-6)+1; %ensure small deviations are not rounded down

    % For @simplots synchronize the time vector and the input table

    nonemptysignals = find(~cellfun('isempty',{inputtable.Inputsignals.name}));
    if length(inputtable.Inputsignals(nonemptysignals))>0 && ~isempty(nonemptysignals)
        intervals = [inputtable.Inputsignals(nonemptysignals).interval];
        intervalsL = intervals(1:2:end);
        intervalsU = intervals(2:2:end);
        availLength = cellfun('length',{inputtable.inputsignals(nonemptysignals).values});
        minintervals = min(availLength-intervalsL)+1;
        if desiredLength>minintervals % there is not enough data to support the specified stop time
            desiredLength = minintervals;
            msgbox(sprintf('The length of the specified data limits the simulation length to %s',num2str(minintervals)), ...
                 'Linear Simulation Tool','modal');
        end

        % Adjust the input signals to the right length
        for k=1:length(nonemptysignals)
            if intervalsU(k)-intervalsL(k)<=desiredLength-1 % only update interval if its too short
               inputtable.Inputsignals(nonemptysignals(k)).interval = [intervalsL(k) intervalsL(k)+desiredLength-1];
            end
        end
        inputtable.update  %table to reflect new lengths  
    end

        
    inputtable.Interval = timeStep;
    if inputtable.Simsamples ~= desiredLength
        inputtable.Simsamples = desiredLength; % listeners will update the boxes
    else % reconcile the boxes even though the number of samples havn't changed
        inputtable.durationupdate(TXTendTime, TXTtimeStep,LBLnumSamples);
    end      
else % one or more boxes are empty -> No time vector
    LBLnumSamples.setText(sprintf('Number of samples: %s',''));
    inputtable.Simsamples = 0;
end
