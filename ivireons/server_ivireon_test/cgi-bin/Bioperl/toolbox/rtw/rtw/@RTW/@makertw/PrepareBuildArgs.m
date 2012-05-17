function PrepareBuildArgs(h, gensettings,rtwVerbose)
%   PREPAREBUILDARGS - prepare build arguments
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.22 $  $Date: 2010/04/21 21:36:57 $

if isfield(gensettings,'BuildDirSuffix')
    h.StartDirToRestore = RTW.transformPaths(pwd,'pathType','full');
    rtwprivate('rtwattic','setStartDir', h.StartDirToRestore);
    rtwprivate('rtwattic','setBuildDir', h.BuildDirectory);
    if rtwVerbose
      % Do not print any message unless we know we are building code.
      if h.MdlRefBuildArgs.CheckCodeDonotRebuild
        msg = DAStudio.message('RTW:makertw:checkStatusCode', h.BuildDirectory);
        feval(h.DispHook{:}, msg);
      elseif ~h.MdlRefBuildArgs.UseChecksum || ...
              strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType, 'NONE')
        msg = DAStudio.message('RTW:makertw:generatingCode', h.BuildDirectory);  
        feval(h.DispHook{:}, msg);
      end
    end
else
    DAStudio.error('RTW:makertw:buildDirSuffixUnavailable');
end

% Now handle build arguments from various source.
rtwBuildArgs = get_param(h.ModelHandle, 'RTWBuildArgs');

% Get build arguments from current active configuration set
configset = getActiveConfigSet(h.ModelHandle);
build_args = getStringRepresentation(configset, 'make_options');
if ~isempty(rtwBuildArgs)
 % build_args = [rtwBuildArgs ' ' build_args];
end

set_param(h.ModelHandle,'RTWBuildArgs',build_args);

% Get RTW root directory
GetRTWRoot(h, rtwVerbose);

%
% Get the template makefile - this must be done before invoking tlc_c or
% tlc_ada because these files cd into the build directory
% DO NOT do this for plc.tlc target
[~, sysFileName] = fileparts(h.SystemTargetFilename);
if ~strcmp(sysFileName, 'plc')
    LocGetTMF(h, h.ModelHandle,h.RTWRoot);
end

%endfunction PrepareBuildArgs


% LocalWords:  rtwattic ada plc
