function private_sl_inspect_siglogs(bd)
%Private function used by Simulink.

% Copyright 2005 The MathWorks, Inc.

if feature('InspectLoggedSignals')
    try
        %
        % Create a variable in the local workspace with the proper name.
        % The inspection tool requires the name of the variable be the
        % name to display in the gui.
        %
        tempSigLogs = get_param(bd,'ModelSignalLogs');
        if ~isempty(tempSigLogs)
            %
            % Get the signal logging name from config params
            %
            siglogsName = get_param(bd,'SignalLoggingName');
        
            %
            % Make a deep copy of the signal logging object
            %
            eval([siglogsName ' = copy(get_param(bd,''ModelSignalLogs''));']);
        
            %
            % Call the inspection tool
            %
            empty = eval(['isempty(' siglogsName ');']);
            if ~empty
                eval(['tstool(' siglogsName ',''replace'');']);
            end
        end
    catch ME
        errordlg(ME.message, 'Error', 'modal');
    end
end
