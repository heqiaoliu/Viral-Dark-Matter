classdef (Hidden = true) Communicator < rtw.connectivity.Component
%COMMUNICATOR communicates with target application
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

    properties (SetAccess = 'private', GetAccess = 'private')
        launcher;
    end

    methods
        % constructor
        function this = Communicator(componentArgs, ...
                                     launcher)
            error(nargchk(2, 2, nargin, 'struct'));
            % call super class constructor
            this@rtw.connectivity.Component(componentArgs);
            % validate arg
            rtw.connectivity.Utils.validateArg(launcher, ...
                                     'rtw.connectivity.Launcher');
            this.launcher = launcher;
        end
    end

    % methods can't be overridden
    methods (Sealed = true)
        function launcher = getLauncher(this)
            error(nargchk(1, 1, nargin, 'struct'));
            launcher = this.launcher;
        end
    end

    methods (Abstract = true)
        % Called to set up the communication channel to the target
        initCommunications(this)

        % Called to shutdown the communication channel to the target
        closeCommunications(this)

        % Called when a cosimulation run is started
        startCommands(this)
            
        % Called a when a cosimulation run is stoped / finished
        endCommands(this)

        % Called to send a command to the target
        result = processCommand(this, ...
                                dataOut, ...
                                dataInAmount, ...
                                memUnitType)
    end
end
