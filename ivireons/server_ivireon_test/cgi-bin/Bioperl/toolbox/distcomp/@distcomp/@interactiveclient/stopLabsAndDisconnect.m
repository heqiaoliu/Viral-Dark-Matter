function stopLabsAndDisconnect(obj, type, gui)
; %#ok Undocumented.
%stopLabsAndDisconnect Stop all the labs and perform client cleanup
%  Send the stop signal to all the labs so they exit and the parallel job 
%  finishes.  Clean up sockets and streams.  Closes the GUI unless closeGUI 
%  is false.

%   Copyright 2006 The MathWorks, Inc.

% We don't need to stop if it isn't already running.
if ~obj.isPossiblyRunning()
    error('distcomp:interactive:NotRunning', ...
          ['%s is not currently active.\nUse     %s open   to ' ...
             'start an interactive session.'], type, type);
end

if strcmp(type, 'force')
    % Special case that is used to indicate that we don't care if we are
    % coming from 'pmode' or 'matlabpool' - so no need to check the and set
    % the interactive type. 
else
    % Error if we are currently the wrong interactive type
    obj.pCheckAndSetInteractiveType(type)
end

if (nargin < 3)
    closeGUI = true;
else
    closeGUI = ~strcmp(gui, 'leaveguiopen');
end

obj.pStopLabsAndDisconnect(closeGUI);
