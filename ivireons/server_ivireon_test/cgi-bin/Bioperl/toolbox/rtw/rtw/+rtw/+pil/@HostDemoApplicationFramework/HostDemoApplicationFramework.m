classdef (Hidden = true) HostDemoApplicationFramework < rtw.pil.RtIOStreamApplicationFramework
%HOSTDEMOAPPLICATIONFRAMEWORK provides a BUILDINFO for use with host-based PIL
%   HOSTDEMOAPPLICATIONFRAMEWORK provides the application framework for
%   host-based PIL.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $


  methods
    % constructor
    function this = HostDemoApplicationFramework(componentArgs)
      error(nargchk(1, 1, nargin, 'struct'));
      % call super class constructor
      this@rtw.pil.RtIOStreamApplicationFramework(componentArgs);
      % add to the BuildInfo property
      %
      
      % get the BuildInfo object to update
      buildInfo = this.getBuildInfo;

      % use host main    
      this.addPILMain('host');      
      
      % add data stream source file
      buildInfo.addSourceFiles('rtiostream_tcpip.c');

      % Add sockets library if required
      if ispc
          
          buildInfoFileContents = ...
              rtw.connectivity.Builder.getComponentBuildInfoFileContents(componentArgs);

          % Check for lcc compiler and add required libraries
          if ~isempty(strfind(buildInfoFileContents.templateMakefile, ...
                               '_lcc.tmf'))
          
              TCPIPLib = fullfile(matlabroot, 'sys', 'lcc', 'lib', 'wsock32.lib');
              [libPath libName libExt] = fileparts(TCPIPLib);
              priority = 1000;
              precompiled = true;
              linkOnly = true;
              buildInfo.addLinkObjects([libName libExt], libPath, priority, ...
                                       precompiled, linkOnly);
          end
                
      end
    end 
  end
end
