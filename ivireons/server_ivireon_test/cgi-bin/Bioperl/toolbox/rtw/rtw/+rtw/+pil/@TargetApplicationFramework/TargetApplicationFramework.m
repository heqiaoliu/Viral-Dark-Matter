classdef (Hidden = true) TargetApplicationFramework < rtw.connectivity.TargetApplicationFramework
%TARGETAPPLICATIONFRAMEWORK provides a BUILDINFO for use with a BUILDER
%
%   The TARGETAPPLICATIONFRAMEWORK allows you to specify additional files needed
%   to build an application for the target environment. These files may include
%   code for hardware initialization as well as device driver code for a
%   communications channel. 
%
%   You must make a subclass of
%   RTW.CONNECTIVITY.TARGETAPPLICATIONFRAMEWORK. This subclass must add any
%   required driver files to the BUILDINFO object. For example, these driver
%   files may include device drivers for communication with a host machine.
%
%   See also RTW.BUILDINFO, RTW.CONNECTIVITY.MAKEFILEBUILDER,
%   RTW.MYPIL.TARGETAPPLICATIONFRAMEWORK

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

    methods
        function this = TargetApplicationFramework(componentArgs)
            error(nargchk(1, 1, nargin, 'struct'));
            
            % call super class constructor                             
            this@rtw.connectivity.TargetApplicationFramework(componentArgs);
            %
            % add to the BuildInfo property
            % 
            LIB_DIR = fullfile(matlabroot, ...
                               'toolbox', ...
                               'rtw', ...
                               'targets', ...
                               'pil', ...
                               'c');     
                           
            APPLICATION_DIR = componentArgs.getApplicationCodePath;

            % get the BuildInfo object to add to
            buildInfo = this.getBuildInfo;          
            % add source path
            buildInfo.addSourcePaths(LIB_DIR);     
            % add PIL lib
            buildInfo.addSourceFiles('pil_interface_lib.c', LIB_DIR);
            % add PIL lib header files
            buildInfo.addIncludeFiles('pil_interface.h', LIB_DIR);
            buildInfo.addIncludeFiles('pil_interface_common.h', LIB_DIR);
            buildInfo.addIncludeFiles('pil_interface_lib.h', LIB_DIR);
            % add generated PIL interface files           
            buildInfo.addSourceFiles('pil_interface.c', APPLICATION_DIR);
            buildInfo.addIncludeFiles('pil_interface_data.h', APPLICATION_DIR);
            % add PIL lib include path
            buildInfo.addIncludePaths(LIB_DIR);
            % add PIL include path
            buildInfo.addIncludePaths(APPLICATION_DIR);
        end
    end
end
            
