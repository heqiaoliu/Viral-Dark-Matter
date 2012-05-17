classdef (Hidden = true) TargetApplicationFramework < rtw.connectivity.Component
%TARGETAPPLICATIONFRAMEWORK provides a BUILDINFO for use with a BUILDER
%
%   You must make a subclass of TARGETLAUNCHER. This subclass must add any
%   required driver files to the BUILDINFO object. For example, these driver
%   files may include device drivers for communication with a host machine.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2008 The MathWorks, Inc.

    % private properties
    properties(SetAccess = 'private', GetAccess = 'private')
        buildInfo;        
    end

    % constructor
    methods
        function this = TargetApplicationFramework(componentArgs)
            error(nargchk(1, 1, nargin, 'struct'));
            % call super class constructor                             
            this@rtw.connectivity.Component(componentArgs);
            % create a default BuildInfo object
            this.buildInfo = RTW.BuildInfo;
        end
    end

    % methods can't be overridden
    methods (Sealed = true)
        function buildInfo = getBuildInfo(this)
            error(nargchk(1, 1, nargin, 'struct'));
            buildInfo = this.buildInfo;
        end
    end
end
