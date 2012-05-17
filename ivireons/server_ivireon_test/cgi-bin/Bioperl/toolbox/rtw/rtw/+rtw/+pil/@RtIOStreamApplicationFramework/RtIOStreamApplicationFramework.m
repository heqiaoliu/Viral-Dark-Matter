classdef RtIOStreamApplicationFramework < rtw.pil.TargetApplicationFramework
%RTIOSTREAMAPPLICATIONFRAMEWORK provides a BUILDINFO for use with PIL
%
%   RTIOSTREAMAPPLICATIONFRAMEWORK provides a BUILDINFO object containing PIL
%   specific files (including PIL main.c) that will be combined, by
%   MAKEFILEBUILDER, with the PIL component libraries to create the PIL
%   application.
%
%   You must make a subclass and add source files, libraries, include paths and
%   preprocessor defines required to build an application for the target
%   environment to the BUILDINFO object. The additional files may include code
%   for hardware initialization as well as device driver code for an rtIOStream
%   communications channel.
%
%
%   See also RTW.CONNECTIVITY.MAKEFILEBUILDER, RTW.BUILDINFO,
%   RTW.MYPIL.TARGETAPPLICATIONFRAMEWORK

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

    methods
        function this = RtIOStreamApplicationFramework(componentArgs)
            error(nargchk(1, 1, nargin, 'struct'));
            
            % call super class constructor                             
            this@rtw.pil.TargetApplicationFramework(componentArgs);
            %
            % add to the BuildInfo property
            %             
            rtIOStream_path = fullfile(matlabroot, ...
                                       'rtw', ...
                                       'c', ...
                                       'src');

            % get the BuildInfo object to add to
            buildInfo = this.getBuildInfo;   
            buildInfo.addIncludeFiles('rtiostream.h', rtIOStream_path);  
            buildInfo.addIncludePaths(rtIOStream_path);
            buildInfo.addSourceFiles('pil_rtio_data_stream.c', this.getPILSrcPath);
        end
        
        % method to add the specified PIL main.c to the BuildInfo
        function addPILMain(this, type)
            buildInfo = this.getBuildInfo; 
            type = lower(type);
            switch type
                case 'target'
                    buildInfo.addSourceFiles('pil_main.c', this.getPILSrcPath);        
                case 'host'
                    buildInfo.addSourceFiles('pil_host_main.c', this.getPILSrcPath);      
                otherwise
                    rtw.pil.ProductInfo.error('pil', 'UnknownMainType', type);
            end                        
        end                
    end
    
    methods (Access = 'private')
        function pilSrcPath = getPILSrcPath(this) %#ok<MANU>
            pilSrcPath = fullfile(matlabroot, ...
                'toolbox', ...
                'rtw', ...
                'targets', ...
                'pil', ...
                'c');
        end
    end       
end
