function SourceChange(hMPlay)
%SOURCECHANGE Called whenever MPlay source changes.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/15 20:50:25 $

% Get selected signals from
selectedSigs = source(hMPlay.hMPlay);

% Valid Simulink signals are of form:
% selectedSigs{1} = string with full block path to Simulink block
% selectedSigs{2} = array of port numbers (1 or 3 elements long)
if isempty(selectedSigs) || size(selectedSigs{1}, 2) ~= 2
    
    % If the selected signals are empty, reset the iosignals to empty.  It
    % will be {} when there is no source and {[]} when we have the simulink
    % source, but are not connected to a signal/block.
    newioSigs = struct('Handle', -1, 'RelativePath', '');
else
    % Valid, MPlay selected signal, update IOSignals
    selectedSigs = selectedSigs{1};
    
    newioSigs = [];
    for indx = 1:size(selectedSigs,1)
        
        % Get block and port;
        block_name = selectedSigs{indx, 1};
        portIndexArray = selectedSigs{indx, 2};
        
        % If they're empty, they were invalid
        if ~isempty(block_name) && ~isempty(portIndexArray)
            hSig=get_param(block_name,'handle');
            hPorts=get_param(hSig,'porthandles');
            hOutports=hPorts.Outport;
            nMPlaySigs=length(portIndexArray);
            for jndx=1:nMPlaySigs
                % IOSignal is {hPort, Relative path} for each signal (RelativePath= '' for now)
                newioSigs = [newioSigs struct('Handle', hOutports(portIndexArray(jndx)), 'RelativePath', '')];
            end
        end
    end
end

% Set IOSignals to block with block handle (BlockHandle)
set_param(hMPlay.hBlk, 'IOSignals', {newioSigs});

% [EOF]
