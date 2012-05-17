classdef (Hidden = true) LinkApplicationFramework < rtw.pil.TargetApplicationFramework
%LINKAPPLICATIONFRAMEWORK provides an RTW.BuildInfo object for use with a PIL rtw.connectivity.Builder.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $


    methods
        function this = LinkApplicationFramework(componentArgs, ...
                                                 dataBufferSize)
            error(nargchk(2, 2, nargin, 'struct'));
            
            % call super class constructor                             
            this@rtw.pil.TargetApplicationFramework(componentArgs);
            %
            % add to the BuildInfo property
            % 
            pil_src_path = fullfile(matlabroot, ...
                                    'toolbox', ...
                                    'rtw', ...
                                    'targets', ...
                                    'pil', ...
                                    'c');     

            % get the BuildInfo object to add to
            buildInfo = this.getBuildInfo;                                                                   
            buildInfo.addSourceFiles('pil_ide_data_stream.c', pil_src_path);             
            % tell PIL infrastructure this is a Link implementation
            buildInfo.addDefines('LINK_DATA_STREAM=1');
            % set the data buffer size in the target
            buildInfo.addDefines(['LINK_DATA_BUFFER_SIZE=' int2str(dataBufferSize)]);
        end
    end
end
