classdef (Hidden = true) Builder < rtw.connectivity.Component
%BUILDER builds an application
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $

    % private properties
    properties (SetAccess = 'private', GetAccess = 'private')
        TargetApplicationFramework;
    end    
    
    methods
        % constructor
        function this = Builder(componentArgs, targetApplicationFramework)
            error(nargchk(2, 2, nargin, 'struct'));
            % call super class constructor                             
            this@rtw.connectivity.Component(componentArgs);
            % validate arg
            rtw.connectivity.Utils.validateArg(...
                targetApplicationFramework, ...
                'rtw.connectivity.TargetApplicationFramework');
            % store application framework            
            this.TargetApplicationFramework = targetApplicationFramework;
        end
    end

    % methods can't be overridden
    methods (Sealed = true)        
        function buildApplication(this)
            error(nargchk(1, 1, nargin, 'struct'));
            % get the component integration build info
            componentBuildInfo = this.getComponentBuildInfo;
            componentIntegrationBuildInfo = this.getComponentIntegrationBuildInfo(componentBuildInfo);
            targetApplicationFrameworkBuildInfo = this.TargetApplicationFramework.getBuildInfo;
            % combine componentIntegrationBuildInfo &
            % targetApplicationFrameworkBuildInfo to form
            % "applicationBuildInfo" buildInfo
            buildInfo = this.createApplicationBuildInfo(componentIntegrationBuildInfo, ...
                                                                   targetApplicationFrameworkBuildInfo);                                            
            % save applicationBuildInfo
            save(this.getApplicationBuildInfoPath, 'buildInfo');                 
            % build
            this.build(buildInfo);            
        end
        
        % Get full file name of the executable
        function exe = getApplicationExecutable(this)
            error(nargchk(1, 1, nargin, 'struct'));
            % get the app BuildInfo
            applicationBuildInfoPath = this.getApplicationBuildInfoPath;
            if ~exist(applicationBuildInfoPath, 'file')
                rtw.connectivity.ProductInfo.error('target', 'FileNotFound', ...
                      applicationBuildInfoPath);                  
            else
                % load the BuildInfo
                applicationBuildInfo = targets_load_buildinfo(applicationBuildInfoPath);
                % determine executable
                exe = this.getExecutable(applicationBuildInfo);
            end                                                                   
        end       
    end
    
    % methods that may be overridden
    methods (Static)      
      % Note: this function is similar to instance method
      % getComponentBuildInfoMATFileContents but hardcodes the
      % buildInfo.mat path rather than using instance method
      % getComponentBuildInfoPath that may be overridden by a subclass.
      %
      % It is designed for use only by the SIL connectivity
      % configurations.
      function contents = getComponentBuildInfoFileContents(componentArgs)
          componentBuildInfoPath = fullfile(componentArgs.getComponentCodePath, ...
                                    'buildInfo.mat');
            
          if ~exist(componentBuildInfoPath, 'file')
              rtw.connectivity.ProductInfo.error('target', 'MissingComponentBuildInfo', ...
                  componentBuildInfoPath, ...
                  componentArgs.getComponentPath);
          else
              [~, contents] = targets_load_buildinfo(componentBuildInfoPath);
          end
      end       
    end
        
    methods (Access = 'protected')                
       function applicationBuildInfoPath = getApplicationBuildInfoPath(this)
           error(nargchk(1, 1, nargin, 'struct'));             
           % default implementation
           applicationBuildInfoPath = fullfile(this.getComponentArgs.getApplicationCodePath, 'buildInfo.mat');
       end
       
       function componentBuildInfoPath = getComponentBuildInfoPath(this)
           error(nargchk(1, 1, nargin, 'struct'));
           % default implementation
           componentBuildInfoPath = fullfile(this.getComponentArgs.getComponentCodePath, ...
                                    'buildInfo.mat');
       end
       
       % Get the component buildInfo object
       function componentBuildInfo = getComponentBuildInfo(this)
           contents = this.getComponentBuildInfoMATFileContents;
           componentBuildInfo = contents.buildInfo;                                       
       end
       
       function contents = getComponentBuildInfoMATFileContents(this)
           % getComponentBuildInfoPath may be overridden by a subclass!
           componentBuildInfoPath = this.getComponentBuildInfoPath;                                
           if ~exist(componentBuildInfoPath, 'file')
               rtw.connectivity.ProductInfo.error('target', 'MissingComponentBuildInfo', ...
                   componentBuildInfoPath, ...
                   this.getComponentArgs.getComponentPath);
           else
               [~, contents] = targets_load_buildinfo(componentBuildInfoPath);
           end
       end
       
       function applicationBuildInfo = createApplicationBuildInfo(this, ...
                                                                  componentIntegrationBuildInfo, ...
                                                                  targetApplicationFrameworkBuildInfo) %#ok<MANU>
           % combine componentIntegrationBuildInfo &
           % targetApplicationFrameworkBuildInfo to form
           % applicationBuildInfo
           %
           % start with componentIntegrationBuildInfo and just add required
           % parts of targetApplicationFrameworkBuildInfo
           applicationBuildInfo = componentIntegrationBuildInfo;           
           %
           src = targetApplicationFrameworkBuildInfo.getSourceFiles(true, true);
           for i=1:length(src)
               [p f e] = fileparts(src{i});
               % always add to Sfcn group (supports makefile build)
               applicationBuildInfo.addSourceFiles([f e], p, 'Sfcn');
           end
           % add framework source paths
           srcPaths = targetApplicationFrameworkBuildInfo.getSourcePaths(true);
           for i=1:length(srcPaths)
               applicationBuildInfo.addSourcePaths(srcPaths{i});
           end
           % add framework include files
           inc = targetApplicationFrameworkBuildInfo.getIncludeFiles(true, true);
           for i=1:length(inc)
               [p f e] = fileparts(inc{i});
               applicationBuildInfo.addIncludeFiles([f e], p);
           end
           % add framework libraries
           libs = targetApplicationFrameworkBuildInfo.LinkObj;
           for i=1:length(libs)
               l = applicationBuildInfo.addLibraries(libs(i).Name, libs(i).Path);
               % respect LinkOnly flag
               l.LinkOnly = libs(i).LinkOnly;
           end
           % add framework includes
           replaceMATLABROOT = true;
           paths = targetApplicationFrameworkBuildInfo.getIncludePaths...
               (replaceMATLABROOT);
           applicationBuildInfo.addIncludePaths(paths);
           % add framework defines
           defines = targetApplicationFrameworkBuildInfo.getDefines;
           applicationBuildInfo.addDefines(defines);
           % add framework link flags
           linkFlags = targetApplicationFrameworkBuildInfo.getLinkFlags;
           applicationBuildInfo.addLinkFlags(linkFlags);           
       end
    end
        
    % abstract methods
    methods (Abstract = true, Access = 'protected')
        % Get a buildInfo object that represents how to integrate with the
        % component
        componentIntegrationBuildInfo = getComponentIntegrationBuildInfo(this, componentBuildInfo)
                
        % Build the application
        build(this, applicationBuildInfo)
        
        % Get full file name of the executable
        exe = getExecutable(this, applicationBuildInfo)
    end
end
