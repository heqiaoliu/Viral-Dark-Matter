function gensettings = ConfigForTLC(h)
% CONFIGUREFORTLC:
%	Configure the
%          RTWGenSettings
%       and
%          RTWOptions
%       as well as other items needed for running TLC.
%
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.26 $  $Date: 2010/04/21 21:36:54 $

% Order of combines:
%   1) Common opts
%   2) System target file
%   3) RTWOptions parameter
% We do the first three in reverse order due to the way
% private/combinestruct.m works.  See comments in that file for more
% information.
%   4) RTWMakeCommand arguments for backwards compatibility

% Get code generation options from the existing system target file.
[nu, gensettings] = rtwprivate('getSTFInfo', [], 'getCachedValues',true);

matFileLogging = str2double(gensettings.matFileLogging);

% Clean up extra options that does not belong to the target or the commont options
configset = getActiveConfigSet(h.ModelHandle);
configset.extraOptions = RetainStackOptions(getProp(configset, 'TLCOptions'));
rtwOptions = get_param(h.ModelHandle, 'RTWOptions');
configset.extraOptions = '';

rtwOptionsArray = rtwprivate('optstr_struct', rtwOptions);
optionsArray    = rtwOptionsArray;

% cache the build directory, and possibly get the relative build dir
gensettings = CacheBuildDirectory(h,gensettings);

set_param(h.ModelHandle, 'RTWGenSettings', ...
                        rtwprivate('getSTFInfoCSFields', gensettings));

%---------------------------------------%
% Get target type from specified solver %
%---------------------------------------%
modelName = h.ModelName;

LocMapSolverToTargetType(h, h.ModelHandle, ...
                         get_param(h.ModelHandle,'Solver'), ...
                         gensettings.tlcTargetType);

%language=h.languageDir;
%language(1) = char(h.languageDir(1)-32);
language = 'C';
if ~strcmp(gensettings.tlcLanguage,language)
    DAStudio.error('RTW:makertw:tlcLanguageMismatch',...
                   gensettings.tlcLanguage, modelName, language);
end


%-------------------%
% Setup TLC options %
%-------------------%

extraOptions = [];

opt.name = 'InlineParameters';
opt.value = strcmp(get_param(h.ModelHandle,'RTWInlineParameters'),'on');
extraOptions = [extraOptions ' -a' opt.name '=' num2str(opt.value)];

if (matFileLogging == 0)
  set_param(configset, 'MatFileLogging', 'off');
  extraOptions = [extraOptions ' -aMatFileLogging=0'];
else
  set_param(configset, 'MatFileLogging', 'on');
  extraOptions = [extraOptions ' -aMatFileLogging=1'];
end

extraOptions = strtrim(extraOptions);
extraOptionsArray = rtwprivate('optstr_struct', extraOptions);
% Give precedence to options specified in dialog box or target file.
optionsArray = rtwprivate('combinestruct', optionsArray, extraOptionsArray, 'name');

if ~isfield(gensettings,'IsRTWSfcn') || ~strcmpi(gensettings.IsRTWSfcn,'yes')
    tlcArgsFromMakeArgs = LocMapMakeVarsToTLCVars(h, h.BuildArgs);
    if ~isempty(tlcArgsFromMakeArgs)
        tlcArgsFromMakeArgs = strtrim(tlcArgsFromMakeArgs);
    end
    tlcFromMakeArray = rtwprivate('optstr_struct', tlcArgsFromMakeArgs);
    % TLC options from makefile are of highest precedence
    optionsArray = rtwprivate('combinestruct', optionsArray, tlcFromMakeArray, 'name');
    % If MatFileLogging was set, make sure config set is updated
    for i = 1:length(tlcFromMakeArray)
        if strcmp(tlcFromMakeArray(i).name, 'MatFileLogging')
            set_param(configset, 'MatFileLogging', str2double(tlcFromMakeArray(i).value));
        end
    end
end

% get the custom tlc options
tlcArgs = get_param(h.ModelHandle, 'TLCOptions');
tlcArgs = [rtwprivate('struct_optstr', optionsArray) ' ' tlcArgs];

% After all the arguments are parsed, set the consolidated InlineParameters
% flag and the RTWOptions string in the model via the set_param API. This is
% required to make TLC and rtwgen look at the same values for these
% attributes

idx = findstr(tlcArgs,'-aInlineParameters=1');
val = 'on';
if isempty(idx),
    val = 'off';
end
set_param(h.ModelHandle, 'RTWInlineParameters', val);

setRTWOptions(getActiveConfigSet(h.ModelHandle), tlcArgs);

%endfunction: ConfigForTLC

function gensettings = CacheBuildDirectory(h,gensettings)
    if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType, 'NONE')
      h.BuildDirectory     = gensettings.BuildDirectory;
      h.GeneratedTLCSubDir = gensettings.GeneratedTLCSubDir;
      
      % some targets may generate code in different depth from anchorDir, and
      % will generate in <pwd>/<model><target_dir_str>/sources.  In these
      % situations, gensettings.relativePathToAnchor will have relative path
      % information, otherwise it will be empty.
      if ~isempty(gensettings.relativePathToAnchor)
        rtwprivate('rtwinfomatman','updateField','minfo', ...
                   h.ModelName,'NONE','relativePathToAnchor', ...
                   gensettings.relativePathToAnchor);
      end
    else
      infoStruct = rtwprivate('rtwinfomatman','load','minfo', ...
                              h.ModelName, ...
                              h.MdlRefBuildArgs.ModelReferenceTargetType);
      gensettings.RelativeBuildDir = infoStruct.srcCoreDir;

      fileGenCfg = Simulink.fileGenControl('getConfig');
      
      if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType, 'SIM')
          rootFolder = fileGenCfg.CacheFolder;
      else
          rootFolder = fileGenCfg.CodeGenFolder;
      end
      h.BuildDirectory = fullfile(rootFolder, gensettings.RelativeBuildDir);
      h.GeneratedTLCSubDir = fullfile('tmwinternal','tlc');
    end

%end CacheBuildDirectory


%%%%%%%%%%%%%%%%%%  HELPERS  %%%%%%%%%%%%%%%%%%

function y = RetainStackOptions(options)
  y = '';
  stackOptions = {'MaxStackSize', ...
                  'MaxStackVariableSize', ...
                  'DivideStackByRate', ...
                  'ProtectCallInitFcnTwice', ...
                  'ProfileGenCode'};

  optionsStruct = rtwprivate('optstr_struct', options);
  for i = 1:size(optionsStruct,2)
    for j = 1:size(stackOptions, 2)
      if strcmp(optionsStruct(i).name, stackOptions{j})
        y = [y '-a' stackOptions{j} '=' optionsStruct(i).value ' ']; %#ok<AGROW>
      end
    end
  end
%end RetainStackOptions
