classdef Config < handle
%CONFIG ties individual components together in a configuration
%
%   CONFIG(COMPONENTARGS,BUILDER,LAUNCHER,COMMUNICATOR) collects together
%   instances of a BUILDER, a LAUNCHER and a COMMUNICATOR to create a complete
%   target connectivity configuration.
%
%   You must make a subclass that provides the BUILDER, LAUNCHER and
%   COMMUNICATOR arguments.  The subclass must create instances of these classes
%   and instantiate this super class with them.
%
%   See also RTW.CONNECTIVITY.COMPONENTARGS, RTW.CONNECTIVITY.MAKEFILEBUILDER,
%   RTW.CONNECTIVITY.LAUNCHER, RTW.CONNECTIVITY.RTIOSTREAMHOSTCOMMUNICATOR,
%   RTW.MYPIL.CONNECTIVITYCONFIG

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

   % private properties
   properties(SetAccess = 'private', GetAccess = 'private')
        ComponentArgs;
        % documented components
        Builder;
        Launcher;
        Timer;
        % partially documented components
        Communicator;
        % undocumented components
        ExtendedHardwareConfig;
    end

    methods
        % constructor
        function this = Config(componentArgs, ...
                               builder, ...
                               launcher, ...
                               communicator)
            error(nargchk(4, 4, nargin, 'struct'));
            % validate args
            rtw.connectivity.Utils.validateArg(componentArgs, ...
                'rtw.connectivity.ComponentArgs');
            rtw.connectivity.Utils.validateArg(builder, ...
                'rtw.connectivity.Builder');
            rtw.connectivity.Utils.validateArg(launcher, ...
                'rtw.connectivity.Launcher');
            rtw.connectivity.Utils.validateArg(communicator, ...
                'rtw.connectivity.Communicator');
            % store properties
            this.ComponentArgs = componentArgs;
            this.Builder = builder;
            this.Launcher = launcher;
            this.Communicator = communicator;
            % create default hardware config
            this.ExtendedHardwareConfig = rtw.connectivity.ExtendedHardwareConfig;
        end
   
        % property set function for extendedHardwareConfig because
        % it is set from multiple code locations
        function set.ExtendedHardwareConfig(this, value)
            error(nargchk(2, 2, nargin, 'struct'));         
            % validate args
            rtw.connectivity.Utils.validateArg(value, ...
                'rtw.connectivity.ExtendedHardwareConfig');
            this.ExtendedHardwareConfig = value;
        end
        
        % property set function for Timer 
        % this provides a way to switch on execution profiling
        function set.Timer(this, value)
            error(nargchk(2, 2, nargin, 'struct'));         
            % validate args
            rtw.connectivity.Utils.validateArg(value, ...
                'rtw.connectivity.Timer');
            this.Timer = value;
        end
        
    end

    methods (Sealed = true)
      function componentArgs = getComponentArgs(this)
         error(nargchk(1, 1, nargin, 'struct'));
         componentArgs = this.ComponentArgs;
      end
        
      function builder = getBuilder(this)
         error(nargchk(1, 1, nargin, 'struct'));
         builder = this.Builder;
      end 
   
      function launcher = getLauncher(this)
         error(nargchk(1, 1, nargin, 'struct'));   
         launcher = this.Launcher;
      end

      function timer = getTimer(this)
         error(nargchk(1, 1, nargin, 'struct'));   
         timer = this.Timer;
      end

      function communicator = getCommunicator(this)
         error(nargchk(1, 1, nargin, 'struct'));
         communicator = this.Communicator;
      end

      function extendedHardwareConfig = getExtendedHardwareConfig(this)
         error(nargchk(1, 1, nargin, 'struct'));
         extendedHardwareConfig = this.ExtendedHardwareConfig;
      end   
      
      function setTimer(this, timer)
          error(nargchk(2, 2, nargin, 'struct'));
          this.Timer = timer;
      end
      
      % unpublished function allowing (internal) override of the default
      % extended hardware configuration settings
      %
      % once this information is available via RTW then the extended 
      % hardware configuration settings will no longer be required
      function setExtendedHardwareConfig(this, extendedHardwareConfig)
         error(nargchk(2, 2, nargin, 'struct'));
         this.ExtendedHardwareConfig = extendedHardwareConfig;
      end      
    end
end
