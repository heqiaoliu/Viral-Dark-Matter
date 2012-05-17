classdef TargetApplicationFramework < rtw.pil.RtIOStreamApplicationFramework
%TARGETAPPLICATIONFRAMEWORK is a skeleton application framework for PIL
%
%   The TARGETAPPLICATIONFRAMEWORK allows you to specify additional files needed
%   to build an application for the target environment. These files may include
%   code for hardware initialization as well as device driver code for a
%   communications channel. 
%
%   This is a skeleton class that you can make into a full implementation of
%   TARGETAPPLICATIONFRAMEWORK by uncommenting the lines tagged with
%   "UNCOMMENT".  This is explained further in the demo RTWDEMO_CUSTOM_PIL.
%
%   See also RTW.PIL.RTIOSTREAMAPPLICATIONFRAMEWORK, RTWDEMO_CUSTOM_PIL
 
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
    
    methods
        % constructor
        function this = TargetApplicationFramework(componentArgs)
            error(nargchk(1, 1, nargin, 'struct'));
            % call super class constructor
            this@rtw.pil.RtIOStreamApplicationFramework(componentArgs);
            
            % INSERT YOUR CODE HERE TO CUSTOMIZE THE CONNECTIVITY
            % CONFIGURATION FOR YOUR TARGET
            
            % ALTERNATIVELY UNCOMMENT THE FOLLOWING LINES TO IMPLEMENT A HOST-BASED
            % EXAMPLE. TO UNCOMMENT LINES IN THE MATLAB EDITOR, SELECT THE LINES
            % AND ENTER CTRL-T.

%            % To build the PIL application you must specify a main.c file.       %UNCOMMENT
%            % The following PIL main.c files are provided and can be             %UNCOMMENT
%            % added to the application framework via the "addPILMain"            %UNCOMMENT    
%            % method:                                                            %UNCOMMENT
%            %                                                                    %UNCOMMENT
%            % 1) A main.c adapted for on-target PIL and suitable                 %UNCOMMENT
%            %    for most PIL implementations. Select by specifying              %UNCOMMENT
%            %    'target' argument to "addPILMain" method.                       %UNCOMMENT
%            %                                                                    %UNCOMMENT
%            % 2) A main.c adapted for host-based PIL such as the                 %UNCOMMENT
%            %    "mypil" host example. Select by specifying 'host'               %UNCOMMENT
%            %    argument to "addPILMain" method.                                %UNCOMMENT
%            this.addPILMain('host');                                             %UNCOMMENT
%                                                                                 %UNCOMMENT
%            % Additional source and library files to include in the build        %UNCOMMENT
%            % must be added to the BuildInfo property                            %UNCOMMENT
%                                                                                 %UNCOMMENT
%            % Get the BuildInfo object to update                                 %UNCOMMENT
%            buildInfo = this.getBuildInfo;                                       %UNCOMMENT
%                                                                                 %UNCOMMENT
%            % Add device driver files to implement the target-side of the        %UNCOMMENT
%            % host-target rtIOStream communications channel                      %UNCOMMENT
%            buildInfo.addSourceFiles('rtiostream_tcpip.c');                      %UNCOMMENT
%                                                                                 %UNCOMMENT
%            % If using the lcc compiler on PC we must explicity add the sockets  %UNCOMMENT
%            % library                                                            %UNCOMMENT
%            if ispc                                                              %UNCOMMENT
%                                                                                 %UNCOMMENT
%                buildInfoFileContents = ...                                      %UNCOMMENT
%                    rtw.connectivity.Builder...                                  %UNCOMMENT
%                    .getComponentBuildInfoFileContents(componentArgs);           %UNCOMMENT
%                                                                                 %UNCOMMENT
%                % Check for lcc compiler and add required libraries              %UNCOMMENT
%                if ~isempty(strfind(buildInfoFileContents.templateMakefile, ...  %UNCOMMENT
%                                    '_lcc.tmf'))                                 %UNCOMMENT
%                                                                                 %UNCOMMENT
%                    TCPIPLib = fullfile(matlabroot, 'sys', 'lcc', 'lib', ...     %UNCOMMENT
%                        'wsock32.lib');                                          %UNCOMMENT
%                    [libPath libName libExt] = fileparts(TCPIPLib);              %UNCOMMENT
%                    priority = 1000;                                             %UNCOMMENT
%                    precompiled = true;                                          %UNCOMMENT
%                    linkOnly = true;                                             %UNCOMMENT
%                    buildInfo.addLinkObjects([libName libExt], libPath, ...      %UNCOMMENT
%                                             priority, precompiled, linkOnly);   %UNCOMMENT
%                end                                                              %UNCOMMENT
%                                                                                 %UNCOMMENT
%            end                                                                  %UNCOMMENT
             
        end
    end
end
