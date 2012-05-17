function ParseBuildArgs(h, args)
% PARSEBUILDARGS:
%	Parse the build arguments passed into make_rtw
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.21 $  $Date: 2010/04/21 21:36:56 $

usesDefault = false;
if ~isempty(args) && ~ischar(args{1})
  h.MdlRefBuildArgs = args{1};
  startArgs = 2;
  h.DispHook = h.MdlRefBuildArgs.mDispHook;
else
  %% Have a default function
  usesDefault = true;
  h.MdlRefBuildArgs.UpdateTopModelReferenceTarget = false;
  h.MdlRefBuildArgs.ModelReferenceTargetType = 'NONE';
  h.MdlRefBuildArgs.OkayToPushNags = false;
  h.MdlRefBuildArgs.StoredChecksum = [];
  h.MdlRefBuildArgs.UseChecksum = false;
  h.MdlRefBuildArgs.Verbose     = false;
  h.MdlRefBuildArgs.FirstModel  = '';
  h.MdlRefBuildArgs.BuildHooks = [];
  h.MdlRefBuildArgs.TopOfBuildModel = [];
  h.MdlRefBuildArgs.TopModelPILBuild = false;
  h.MdlRefBuildArgs.OnlyCheckConfigsetMismatch = false;
  h.MdlRefBuildArgs.CheckCodeDonotRebuild = false;
  h.MdlRefBuildArgs.protectedModelReferenceTarget = false;
  startArgs = 1;
  h.DispHook = {@disp};
  % check here to catch the direct use of "make_rtw" instead of slbuild/rtwbuild case
  rtwprivate('modelrefutil','','rtw_checkslprjdir', pwd);
end

% store OkayToPushNags information in the rtwattic so that it can be
% retrieved by rtw_disp_info later on
rtwprivate('rtwattic', 'setOkayToPushNag', h.MdlRefBuildArgs.OkayToPushNags);

h.BuildArgs = '';
for i = startArgs:length(args)
    h.BuildArgs = [h.BuildArgs, args{i}, ' '];
end
if ~isempty(h.BuildArgs)
    h.BuildArgs(end) = [];
end

h.InitRTWOptsAndGenSettingsOnly = 0;

% Get the model name and handle. Pluck:
%  mdl:modelName  => Build
% or
%  ini:modelName  => Initialize RTWOptions and RTWGenSettings, then exit.
%
if length(h.BuildArgs) > 4 && ...
        (all(h.BuildArgs(1:4)=='mdl:') || all(h.BuildArgs(1:4)=='ini:'))
    if all(h.BuildArgs(1:4)=='ini:')
        h.InitRTWOptsAndGenSettingsOnly = 1;
    end
    sp = findstr(h.BuildArgs,' ');
    if ~isempty(sp)
        h.ModelName = h.BuildArgs(5:sp(1)-1);
        h.BuildArgs(1:sp(1)) = [];
    else
        h.ModelName = h.BuildArgs(5:end);
        h.BuildArgs = '';
    end
else
    h.ModelName = bdroot;
end %if
if isempty(h.ModelName)
    DAStudio.error('RTW:makertw:nonExistentMdlName');
end %if

% get Model handle
h.ModelHandle = get_param(h.ModelName,'handle');

h.BuildInfo = RTW.BuildInfo(h.ModelHandle);

if usesDefault
    % This cannot be initialized above. This is because we do not have 
    % the model name during default initialization
    h.MdlRefBuildArgs.slbuildProfileIsOn = ...
        strcmp(get_param(h.ModelHandle, 'DisplayCompileStats'), 'on');
end

