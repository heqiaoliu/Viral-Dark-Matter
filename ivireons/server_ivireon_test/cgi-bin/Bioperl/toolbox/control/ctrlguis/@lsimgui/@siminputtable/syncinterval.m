function cont = syncinterval(inputtable)

% Copyright 2003-2005 The MathWorks, Inc.

% Forces the simulation length to match the shortest selected interval
cont = true;
if length(inputtable.inputsignals)>0   
	intervals = [inputtable.inputsignals.interval];
	minintervals = min(intervals(2:2:end)-intervals(1:2:end))+1;
    if minintervals < inputtable.simsamples
          qstr = sprintf('Proceeding will reduce the number of data samples to %s. Do you wish to continue?',num2str(minintervals));
          continueimp = questdlg(qstr, 'Linear simulation tool','OK','Cancel','OK');
          if strcmp(continueimp,'Cancel')
              cont = false; 
              return
          end
          % force input signals to have the new shorter length
          for k=1:length(inputtable.inputsignals)
              % Don't modify empty rows
              if length(inputtable.inputsignals(k).interval)>=2
                  inputtable.inputsignals(k).interval = [inputtable.inputsignals(k).interval(1), ...
                          inputtable.inputsignals(k).interval(1)+minintervals-1];
              end
          end
          inputtable.update
          inputtable.simsamples = minintervals; % listeners will update the boxes
    end   
end