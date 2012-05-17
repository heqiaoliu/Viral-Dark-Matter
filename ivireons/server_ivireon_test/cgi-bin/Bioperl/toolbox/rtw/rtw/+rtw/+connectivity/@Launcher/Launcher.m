classdef Launcher < rtw.connectivity.Component
%LAUNCHER launches the application built by a BUILDER object
%
%   LAUNCHER(COMPONENTARGS,BUILDER) instantiates a LAUNCHER object that you can
%   use to control starting and stopping of an application on the target
%   processor.
%
%   The LAUNCHER supports starting and stopping of the application associated
%   with a BUILDER object.
%
%   You must make a subclass of LAUNCHER and implement the startApplication and
%   stopApplication methods.
%
%   Launcher abstract methods:
%
%       STARTAPPLICATION - called when a target application must be started. In
%                          this class it is an abstract method. When you make a
%                          subclass of LAUNCHER, you must provide an
%                          implementation of this method that starts the
%                          application.
%
%       STOPAPPLICATION  - STOPAPPLICATION is called when a target application
%                          must be stopped. In this class it is an abstract
%                          method. When you make a subclass of LAUNCHER, you
%                          must provide an implementation of this method that
%                          stops the application.
%
%   See also RTW.CONNECTIVITY.COMPONENTARGS, RTW.CONNECTIVITY.MAKEFILEBUILDER,
%   RTW.MYPIL.LAUNCHER

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

    % private properties
    properties (SetAccess = 'private', GetAccess = 'private')
        builder;
        internalData;
    end            
    
    methods
        % constructor
        function this = Launcher(componentArgs, ...
                                 builder)
            error(nargchk(2, 2, nargin, 'struct'));
            % call super class constructor                             
            this@rtw.connectivity.Component(componentArgs);                                         
            % validate arg
            rtw.connectivity.Utils.validateArg(builder, ...
                                     'rtw.connectivity.Builder');
            % store property
            this.builder = builder;
        end
    end

    % methods can't be overridden
    methods (Sealed = true)
        function builder = getBuilder(this)
            error(nargchk(1, 1, nargin, 'struct'));
            builder = this.builder;
        end
        
        function setInternalData(this, internalData)
            error(nargchk(2, 2, nargin, 'struct'));
            this.internalData = internalData;
        end
        
        function internalData = getInternalData(this)
            error(nargchk(1, 1, nargin, 'struct'));
            internalData = this.internalData;
        end                
    end
    
    methods (Sealed = true, Static)
        function setStartApplicationPause(pauseAmount)
            % enable start application pause support for this session
            %
            % validate arg
            rtw.connectivity.Utils.validateArg(pauseAmount, 'double');   
            rtw.connectivity.Launcher.persistentPause(pauseAmount);
        end          
        
        function pauseAmount = getPause
           pauseAmount = rtw.connectivity.Launcher.persistentPause; 
        end
    end        
   
    methods (Sealed=true, Access='protected', Static)
       function startApplicationPause
            % implement pause associated with setStartApplicationPause
            nl = sprintf('\n');           
            pauseAmount = rtw.connectivity.Launcher.persistentPause;            
            if pauseAmount > 0                                       
                linkText = 'rtw.connectivity.Launcher.setStartApplicationPause(0)';
                link = targets_hyperlink_manager('new', linkText, linkText);
                disp([nl '### To remove the pause during PIL application start, run: >> ' link nl]);                
                msg = ['Pausing during PIL application start for ' ... 
                    num2str(pauseAmount) 's (click OK to continue).' nl nl ...
                    'To disable this pause, see the hyperlink in the MATLAB command window.'];
                h = msgbox(msg, 'Start PIL Application Pause');
                uiwait(h, pauseAmount);
                if ishandle(h)
                    close(h);
                end
            else
                % default pause is 2 minutes
                linkText = 'rtw.connectivity.Launcher.setStartApplicationPause(120)';
                link = targets_hyperlink_manager('new', linkText, linkText);
                disp([nl '### To pause during PIL application start, run: >> ' link nl]);
            end
        end 
    end
    
    methods (Static, Access = 'private')
        function pauseAmountOut = persistentPause(pauseAmountNew)
            % no support for static / class properties so we use a 
            % persistent variable instead
            persistent pauseAmount;
            if isempty(pauseAmount)
                pauseAmount = 0;
            end
            if nargin > 0
                pauseAmount = pauseAmountNew;
            end
            pauseAmountOut = pauseAmount;
        end
    end
    
    % abstract methods
    methods (Abstract = true)        

    startApplication(this)
    %STARTAPPLICATION - called when a target application must be started
    %
    %   STARTAPPLICATION 
    

    stopApplication(this)
    %STOPAPPLICATION  - called when a target application must be stopped
    %
    %   
    end
    
    methods (Sealed=true, Access=protected)        
        function envCmds = getLaunchEnvironmentVars(this)
        % Return any setup commands for the launch environment 
        % (e.g. related to code coverage tool setup). Launch environment
        % setup commands may be specified by build hooks attached to the 
        % model
            model = this.getComponentArgs.getModelName;
            if bdIsLoaded(model)
                envCmds = rtw.pil.BuildHook.getLaunchEnvironmentVars(model);
            else
                envCmds = '';
            end
        end       
    end            
end
