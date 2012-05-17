function c = pGetInteractiveObject(action, varargin)
; %#ok Undocumented
%pGetInteractiveObject Return a singleton lab or client object.
%   The return type depends on whether this is invoked on a lab or on the 
%   client and whether it is a MatlabPool job or not.

% Copyright 2006-2007 The MathWorks, Inc.

% $Revision: 1.1.6.2 $    $Date: 2008/08/08 12:51:24 $

mlock;
persistent theConnection;

switch action
    case 'clear'
        delete(theConnection);
        theConnection = [];
    case 'create'
        if isempty(theConnection) || ~ishandle(theConnection)
            if system_dependent('isdmlworker')
                job = getCurrentJob();
                % A MatlabPool job is never on a client.
                if job.pIsMatlabPoolJob
                    error('distcomp:interactive:InvalidState', ...
                    'Someone is requesting the interactive object before it is set on a worker');
                else
                    % This has to be an interactive lab, if is is on a
                    % worker and not a MatlabPool job.
                    conn = distcomp.interactivelab;
                end
            else
                % There is only one type to be used on the client.
                conn = distcomp.interactiveclient;
            end
            theConnection = conn;
        end
    case 'set'
        conn = varargin{1};
        %if ~isa(conn, 'distcomp.interactiveobject')
        %    error('distcomp:interactive:InvalidArgument', ...
        %        ['The interactive object must be a subclass of distcomp.interactiveobject']);
        %end
        theConnection = conn;
    otherwise
        error('distcomp:interactive:InvalidArgument', ...
            ['The action ' action ' does not exist. Needs to be either' ...
             ' ''clear'' or ''create''.']);
end

c = theConnection;
