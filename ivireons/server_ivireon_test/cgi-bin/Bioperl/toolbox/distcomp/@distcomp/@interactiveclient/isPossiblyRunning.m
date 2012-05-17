function running = isPossiblyRunning(obj)
; %#ok Undocumented
%isPossiblyRunning Check if an interactive session is currently running.
%   Return true if obj's status indicates that we have an open connection to 
%   lab 1.  
%   Note that this method does not check whether the connection is intact and
%   the labs are running and responsive.

%   Copyright 2006 The MathWorks, Inc.

% Note that we must be very careful not to make this test strict because the
% user cannot run 'pmode exit' when this test returns false.
propsToLookAt = {'ConnectionManager', 'ParallelJob'};
% Say we are running if any of the properties is non-empty or the GUI is
% open
running = any(~cellfun(@isempty, obj.get(propsToLookAt))) ...
          || obj.IsGUIOpen;

if ~running
    % Check the last possibility: The session object may exist.
    session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
    running = ~isempty(session) && session.isSessionRunning;
end
