classdef (Hidden = true) Component < handle
%COMPONENT base class for all Target Connectivity Components
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

    % private properties
    properties (SetAccess = 'private', GetAccess = 'private')
        componentArgs;
    end    
    
    methods
        % constructor
        function this = Component(componentArgs)
            error(nargchk(1, 1, nargin, 'struct'));
            % validate arg
            rtw.connectivity.Utils.validateArg(componentArgs, ...
                                     'rtw.connectivity.ComponentArgs');
            % store componentArgs
            this.componentArgs = componentArgs;
        end
    end

    % methods can't be overridden
    methods (Sealed = true)                              
        function componentArgs = getComponentArgs(this)
           error(nargchk(1, 1, nargin, 'struct'));
           componentArgs = this.componentArgs; 
        end        
    end 
end
