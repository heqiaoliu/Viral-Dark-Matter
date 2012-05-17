function rtw_precompile_libs(model, spec)
%  RTW_PRECOMPILE_LIBS - This function pre-compiles the specified libraries for
%  the model provided.
%
%  This function should be called as follows:
%  rtw_precompile_libs(model, build_spec)
%
%  model is a char array with the name of the model you want to pre-compile the
%  libraries for.
%
%  build_spec is a structure with additional info needed to pre-compile the
%  libraries.  The structure has the following fields (opt indicates
%  optional field):
%
%  Field           opt? Description
%  rtwmakecfgDirs  no   This is a cell array of strings containing the
%                       directories where the rtwmakecfg (for s-functions)
%                       files of the libraries that should be precompiled.
%                       The Library Name and Location fields are used to
%                       specify the final name and location of the
%                       pre-compiled libraries. The location will be
%                       overridden if the parameter
%                       'TargetPreCompLibLocation' is set on the model.
%                       Note: the model must contain blocks which use the
%                       precomiled libraries specified by these rtwmakecfg
%                       files.  This is necessary because the tmf to
%                       makefile conversion will only generate the lib
%                       rules if the libs are needed.
%  libSuffix       yes  This is the suffix that should be added to the
%                       library name for each library.  Note that this must
%                       include '.' in it.  This will be overridden if the
%                       parameter 'TargetLibSuffix' is set on the model.
%                       Either this field must be present, or
%                       'TargetLibSuffix' must be set on the model.
%  intOnlyBuild    yes  The Libraries will be compiled integer only if
%                       this is set to true (must be logical value) Only
%                       valid for ERT based targets
%  makeOpts        yes  Additional string to add to the rtwMakeCommand line
%  addLibs         yes  this is a cell array of structs, specifying
%                       additional libraries to build, which aren't in
%                       rtwmakecfg's. Each entry should have 2 fields:
%                       'libName' (the name of the lib without the suffix)
%                       and 'libLoc' (the final location for the lib) both
%                       of which are char arrays. The tmf may specify other
%                       libraries, and how to build them, this field should
%                       be used when pre-compiling those libraries.
%

% $Revision: 1.1.6.18 $ 
% Copyright 2001-2010 The MathWorks, Inc.

  % make sure the args are OK
  locCheckArgs(model,spec);
  
  % everything is done in a temp dir.
  [tmpDir, startDir, recycle_state] = locSetupForBuild();

  try
    load_system(model);    
    cs = getActiveConfigSet(model);

    % if these fields exist, they override the location from rtwmakecfg, and
    % spec.libSuffix
    location = get_param(cs,'TargetPreCompLibLocation');
    suffix = get_param(cs,'TargetLibSuffix');

    % get all of the precomplibs that should be built by looping through the
    % rtwmakecfgs provided.
    precompLibs = [];
    precompLibs.libs = '';

    % this method of getting the extension grabs the extension from the
    % final '.' to the end of the suffix.  If the suffix has
    % multiple '.'  in it, then the "extension" is assumed to be
    % only the final portion.
    if isempty(suffix)
      ext = find(spec.libSuffix == '.');
      lib_ext = spec.libSuffix(ext(end):end);
    else
      ext = find(suffix == '.');
      lib_ext = suffix(ext(end):end);
    end
    
    idx = 1;
    for i=1:length(spec.rtwmakecfgDirs)
      cd (spec.rtwmakecfgDirs{i});
      try
          makecfg = rtwmakecfg();
      catch err
          newExc =...
              MException('RTW:precompile:rtwmakecfgError',...
                         DAStudio.message('RTW:precompile:rtwmakecfgError',...
                                          spec.rtwmakecfgDirs{i}));
          newExc = newExc.addCause(err);
          throw(newExc);
      end
      for j=1:length(makecfg.library)
        % first set the lib name, including the src and dst filenames here.
        % This makes the subsequent copy loop below much simpler.  the
        % source file will always be the makcfg library Name with the
        % extension added, regardless of whether TargLibSuffix is
        % provided or not.
        precompLibs.libName{idx}.src = [makecfg.library(j).Name lib_ext];
        
        if isempty(suffix)
          % If the spec.libSuffix method is being used, then it is assumed the
          % precomplib that gets built will be named as specified by
          % the rtwmakecfg (with an extension implied by the suffix).
          precompLibs.libName{idx}.dst = [makecfg.library(j).Name ...
                              spec.libSuffix];
        else
          precompLibs.libName{idx}.dst = [makecfg.library(j).Name suffix];
        end
        % this is used for the RTWMakeCmd line.
        precompLibs.libs = [precompLibs.libs ' ' precompLibs.libName{idx}.src];
        
        % now set the location
        if isempty(location)
          precompLibs.libLoc{idx} = makecfg.library(j).Location;
        else
          precompLibs.libLoc{idx} = location;
        end
        idx = idx + 1;
      end
    end
    % return to the tmp dir to build from
    cd (tmpDir);

    % if additional libs are provided, then add them to the lists
    if isfield(spec,'addLibs')
        for i=1:length(spec.addLibs)
            % similar to the rtwmakecfg libs above, the source library is the same
            % whether TargetLibSuffix is provided or not.
            precompLibs.libName{idx}.src = [spec.addLibs{i}.libName lib_ext];

            if isempty(suffix)
                precompLibs.libName{idx}.dst =...
                    [spec.addLibs{i}.libName spec.libSuffix];
            else
                precompLibs.libName{idx}.dst = [spec.addLibs{i}.libName suffix];
            end
            % this is used for the RTWMakeCmd line.
            precompLibs.libs = [precompLibs.libs ' '...
                                precompLibs.libName{idx}.src];
            
            % now set the location
            if isempty(location)
                precompLibs.libLoc{idx} = spec.addLibs{i}.libLoc;
            else
                precompLibs.libLoc{idx} = location;
            end
            
            idx = idx + 1;
        end
    end

    % set the make command up with all of the precomplibs as targets
    makeCmd = get_param(model, 'RTWMakeCommand');
    if isfield(spec,'makeOpts')
      % the makeOpts must have LIB_ONLY_BUILD=1 defined appropriately for the
      % make utility.
      makeOpts = [' ' spec.makeOpts ' PRECOMP_LIB_BUILD=1 '];
    else
      makeOpts = ' PRECOMP_LIB_BUILD=1 ';
    end
    set_param(model, 'RTWMakeCommand', [makeCmd makeOpts precompLibs.libs]);
    
    %set the int only build appropriately only if this is an ERT target    
    isERT = get_param(model,'IsERTTarget');
    if strcmp(isERT,'on')
      if isfield(spec,'intOnlyBuild')
        set_param(model, 'PurelyIntegerCode', spec.intOnlyBuild);
      end
    end

    % we need to do a build, so make sure the gencodeonly flag is cleared
    set_param(model, 'GenCodeOnly', 'off');
    
    % build the model with a normal RTWBuild.  Because the rtwmakecommand
    % has specific targets listed (the precomplibs) only those targets
    % will be compiled.
    rtwbuild(model);

    % copy all of the libs that were built
    bdirInfo = RTW.getBuildDir(model);    
    locCopyLibs(precompLibs,bdirInfo.RelativeBuildDir);

    % remove all of the tmp files/dirs and do other cleanup
    locCleanup(model, tmpDir, startDir, recycle_state);
  catch err
      %clean up the mess we created, then re-throw the error
      locCleanup(model, tmpDir, startDir, recycle_state);
      rethrow(err);
  end
  
%End of function


%------------------------------------------------------------------------------
%
% function: locCopyLibs 
%
% inputs:
%    precompLibs
%    BuildDir
%
% returns:
%    
%
% abstract:
%
%
%------------------------------------------------------------------------------
function locCopyLibs(precompLibs,BuildDir)

    % copy the lib to the correct lib dir & name extensions (not to be confused
    % with the lib extension).  Note that the builddir name is obtained
    % from binfo.mat.  This will always have the actual build dir, so we
    % don't have to make assumptions based on the target name.
    
    % copy all of the libs that were built
    for i=1:length(precompLibs.libName)
        % the file paths for the build dir and final destination may have
        % paths in them.  Transform them to the alternate version just to be
        % safe.  This call is harmless if the path has no spaces in it.
        src    = RTW.transformPaths(fullfile(pwd,...
                                             BuildDir,...
                                             precompLibs.libName{i}.src));
        if ispc
            dstDir =  RTW.transformPaths(precompLibs.libLoc{i});
            dst    = fullfile(dstDir, precompLibs.libName{i}.dst);
        else
            dst = fullfile(precompLibs.libLoc{i}, precompLibs.libName{i}.dst);
        end
      locCopyFile(src, dst);
    end

%End of function


%------------------------------------------------------------------------------
%
% function: locSetupForBuild 
%
% inputs:
%
%
% returns:
%    tmpDir
%    startDir
%    recycle_state
%
% abstract:
%   this function sets up everything for building the lib
%
%
%------------------------------------------------------------------------------
function [tmpDir, startDir, recycle_state] = locSetupForBuild()
     
  % the args are OK, we can now start setting up for the build, then actually
  % building the rtwlib's
  recycle_state = recycle('off');
  startDir = pwd;
  addpath(startDir);

  % get/create the new temp dir
  [td name ext] = fileparts(tempname); % e.g. '/tmp', 'tp221015', ''
  dir_to_create = [name '_rtw_precompile' ext];
  mkdir(td,dir_to_create);
  tmpDir = fullfile(td,dir_to_create);

%End of function

%------------------------------------------------------------------------------
%
% function: locCleanup 
%
% inputs:
%    model
%    tmpDir
%    startDir
%    recycle_state
%
% returns:
%    
%
% abstract:
%   this function cleans everything up 
%
%------------------------------------------------------------------------------
function locCleanup(model, tmpDir, startDir, recycle_state)

  close_system(model,0);

  if ~exist(tmpDir,'dir')
      DAStudio.warning('RTW:utility:dirDoesNotExist',tmpDir);
  end

  rmpath(startDir);
  cd(startDir);

  if ispc
    % if the subdir of this dir is on the matlab path this can return an error
    % because matlab will have a lock on the directory, and the OS won't let us
    % remove it. this error should only occur if the wrong dir was passed as
    % tmpDir, since the precomplib routine doesn't add the temp dir to the
    % MATLAB path.
    cmd = ['rd /S /Q "' tmpDir '"'];
    [s w] = dos(cmd);
    if s
        DAStudio.error('RTW:precompile:cleanupError',cmd,num2str(s),deblank(w));
    end

  else
    % delete the unix path
      unix(['/bin/rm -rf ' tmpDir]);
    
  end
  
  recycle(recycle_state);
%End of function

%------------------------------------------------------------------------------
%
% function: locCopyFile 
%
% inputs:
%    src
%    dst
%    mkWritable
%    mkReadOnly
%
%
% returns:
%    
%
% abstract:
%   this function copies a file from src to dst.
%
%------------------------------------------------------------------------------
function locCopyFile(src, dst)
     
  if isunix
    mkWritable  = 'chmod u+w ';
    mkReadOnly  = 'chmod a-w ';
  else
    mkWritable = 'attrib -r ';
    mkReadOnly = 'attrib +r ';
  end

  locDelIfExist(dst, mkWritable)
  fprintf('### Trying to copy "%s" to "%s".\n', src, dst);
  copyfile(src,dst,'f');
  % make sure the copy succeeded
  if ~exist(dst, 'file')
      DAStudio.error('RTW:utility:copyError',src,dst);
  end

  if isunix
    % on MAC the lib will store some of its creation info (like date) in
    % its table of contents. and the linker is sensitive about the lib's
    % internal date and its data presented on the OS. To be safe, we use
    % ranlib to update it every time.
    if ismac
      fprintf('### Trying to run ranlib on "%s" on MAC to keep file consistent for linking.\n', dst);
      dos(['ranlib ' dst]);
    end
  end
  
  % last step is to make the file read only
  dos([mkReadOnly, '"' dst '"'], '-echo');

%End of function

%------------------------------------------------------------------------------
%
% function: locDelIfExist 
%
% inputs:
%    filename
%    mkWritable
%
%
% returns:
%    
%
% abstract:
%   this function attempts to delete the file, if it exists.
%
%------------------------------------------------------------------------------
function locDelIfExist(filename, mkWritable)
  if exist(filename, 'file')
    fprintf('### Trying to delete "%s" \n', filename);
    dos([mkWritable, filename], '-echo');
    delete(filename);
  end
  if exist(filename, 'file')
      DAStudio.error('RTW:utility:removeError',filename);
  end
%End of function

%------------------------------------------------------------------------------
%
% function: locCheckArgs 
%
% inputs:
%    model
%    spec
%
%
% returns:
%    
%
% abstract:
%
%
%------------------------------------------------------------------------------
function locCheckArgs(model, spec)
  
  load_system(model);    
  cs = getActiveConfigSet(model);
  argSpec = 2 ;
  % make sure that model is an actual model file (return is a 4).
  if ~(exist(model,'file') == 4)
      DAStudio.error('RTW:precompile:invalidModel');
  end

  % Spec must be a struct with specific fields in it.
  if ~isstruct(spec)
      DAStudio.error('RTW:precompile:invalidArgType',argSpec,'struct');
  end

  % check for the required fields, and make sure the type is correct.
  
  % rtwmnakecfgDirs must be a cell array of valid directories.
  if ~isfield(spec,'rtwmakecfgDirs')
      DAStudio.error('RTW:precompile:rtwmakecfgDirsRequired',argSpec);
  end    
  if ~iscell(spec.rtwmakecfgDirs)
      DAStudio.error('RTW:precompile:cellArrayFieldRequired',...
                     'rtwmakecfgDirs',argSpec);
  end
  for i=1:length(spec.rtwmakecfgDirs)
      if ~ischar(spec.rtwmakecfgDirs{i}) ||...
              ((exist(fullfile(spec.rtwmakecfgDirs{i},'rtwmakecfg.m'),'file') ~= 2) ...
               && ...
               (exist(fullfile(spec.rtwmakecfgDirs{i},'rtwmakecfg.p'),'file') ~= 6))
          DAStudio.error('RTW:precompile:invalidRtwmakecfgFile', num2str(i));
      end
  end

  % now check the optional fields
  
  % note that the libSuffix must have at least one '.' in it, to define the
  % correct extension type.
  if ~isfield(spec,'libSuffix')
      % if this parameter exists, it overrides spec.libSuffix
      suffix = get_param(cs,'TargetLibSuffix');
      if isempty(suffix)
          DAStudio.error('RTW:precompile:emptyLibSuffixField',argSpec);
      end
  else
      if ~ischar(spec.libSuffix) || ~any(spec.libSuffix == '.')
          DAStudio.error('RTW:precompile:invalidLibSuffixType',argSpec);
      end
  end
  % check for intOnlyBuild field, and make sure it contains a logical value
  if isfield(spec,'intOnlyBuild')
      if ~islogical(spec.intOnlyBuild)
          DAStudio.error('RTW:precompile:invalidIntOnlyBuildType',argSpec);
      end
  end

  % makeopts is a simple string
  if isfield(spec,'makeOpts')
    if ~ischar(spec.makeOpts)
        DAStudio.error('RTW:precompile:invalidMakeOptsType',argSpec );
    end
  end

  % the additional libs is a vector of structs with libName and libLoc fields
  % corresponding to the library name, and the final directory location.
  if isfield(spec,'addLibs')
      if ~iscell(spec.addLibs)
          DAStudio.error('RTW:precompile:cellArrayFieldRequired',...
                         'addLibs',argSpec);
      end
      for i=1:length(spec.addLibs)
          % check the libName field ------------------
          if ~isfield(spec.addLibs{i},'libName')
              DAStudio.error('RTW:precompile:libNameRequired',num2str(i)); 
          end
          if ~ischar(spec.addLibs{i}.libName)
              DAStudio.error('RTW:precompile:invalidLibNameType',num2str(i)); 
          end

          % check the libLoc field ------------------
          if ~isfield(spec.addLibs{i},'libLoc')
              % if this parameter exists, it overrides spec.libSuffix
              location = get_param(cs,'TargetPreCompLibLocation');
              if isempty(location)
                  DAStudio.error('RTW:precompile:emptyTargetPreCompLibLocation',num2str(i));
              end
          else
              if ~ischar(spec.addLibs{i}.libLoc) || ~exist(spec.addLibs{i}.libLoc,'dir')
                  DAStudio.error('RTW:precompile:invalidLibLocDir',num2str(i));
              end
          end
      end
  end
  
  
%End of function
