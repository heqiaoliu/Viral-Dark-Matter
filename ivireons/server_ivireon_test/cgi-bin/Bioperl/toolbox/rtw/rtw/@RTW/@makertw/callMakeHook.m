function callMakeHook(h,hook)
%   AFTERMAKE is the method get called inside make_rtw method after make
%   process.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $  $Date: 2010/05/20 02:54:06 $

profileOn     = h.MdlRefBuildArgs.slbuildProfileIsOn;
mdlRefTgtType = h.MdlRefBuildArgs.ModelReferenceTargetType;

slprivate('slbuild_profile', h.ModelName, 'log', ['make_rtw: ' hook], ...
          profileOn, mdlRefTgtType);

args = locGetHookArgs(h,hook);

% if this is the 'entry' hook, then only run the hook if this is not just an
% init call.  Otherwise run the hookfile
if ~strcmp(hook,'entry') || ~h.InitRTWOptsAndGenSettingsOnly
    
    defaultHookArgs = {args.RTWroot,...
                      args.TMF, args.buidOpts, args.buildArgs, args.buildInfo};
    
    try
        % If the make hook cd's to a different dir, we want to force it
        % back to the current dir.
        cur_pwd = pwd;
        
        if ~isempty(h.MakeRTWHookMFile)
            % the BuildInfo is the 7th argument. Since it is a new argument
            % for R14 sp2, we need to check if the hook function actually has
            % this arg before calling it.
            switch (nargin(h.MakeRTWHookMFile))
              case 6
                % the BuildInfo (arg 7) is not available for user
                % interaction for this callback, so the arg
                % is empty.
                hookArgs = [{hook}, {h.ModelName}, defaultHookArgs(1:4)];
              case {7,-1}
                hookArgs = [{hook}, {h.ModelName}, defaultHookArgs];
              otherwise
                % Because the BuildInfo is undocumented for this release, we
                % want to indicate that the hook function
                % should take only 6 argument, even though 7
                % is a valid configuration as well.
                DAStudio.error('RTW:utility:invalidArgCount',...
                               'make_rtw_hook function','6');
            end 
            feval(h.MakeRTWHookMFile, hookArgs{:});
        end
        
        
        % Dispatch any build hooks attached to the model
        isSimBuild= slprivate('isSimulationBuild',...
                              h.ModelName, ...
                              h.MdlRefBuildArgs.ModelReferenceTargetType);        
        if ~isSimBuild && isfield(h.MdlRefBuildArgs,'TopOfBuildModel') ...
                && ~isempty(h.MdlRefBuildArgs.TopOfBuildModel)
            
            hookVarArgs = defaultHookArgs(1:4);
            hookVarArgs{end+1} = h.MdlRefBuildArgs.ModelReferenceTargetType;
            hookArgs = [{hook}, ...
                        {h.ModelName, h.MdlRefBuildArgs}, ...
                        {h.MdlRefBuildArgs.BuildHooks}, hookVarArgs];
            rtw.pil.BuildHook.dispatch(hookArgs{:});
        end
    catch exc
        cd(cur_pwd);
        errID = 'RTW:makertw:makeHookError';
        % the original error message is formatted with various HTML
        % formatting and possible drive letter specification.  clean it
        % up before including it
        errMsg = rtwprivate('escapeOriginalMessage',exc);
        errMsg = DAStudio.message(errID, h.MakeRTWHookMFile,...
                                  hook, errMsg);
        
        newExc = MException(errID, errMsg);
        newExc = newExc.addCause(exc);
        throw(newExc);
    end
    % For now, if the make hook cd'd, just issue a warning and continue
    if ~strcmp(cur_pwd,pwd)
        DAStudio.warning('RTW:makertw:changeDirNotAllowed',...
                         ['''' hook ''' hook call to '''...
                          h.MakeRTWHookMFile ''''], pwd, cur_pwd);
        cd(cur_pwd);
    end
    
    if isempty(h.MakeRTWHookMFile)
        % for entry and exit hooks, alternate processing happens if the
        % hook file is empty
        if strcmp(hook,'entry') || strcmp(hook,'exit')
            targetType = h.MdlRefBuildArgs.ModelReferenceTargetType;
            switch (targetType)
              case {'SIM', 'RTW'}
                % Don't print out the entry hook message if we are
                % using the checksum because we may not rebuild and
                % the message could be confusing.
                if strcmp(hook,'entry')
                    if h.MdlRefBuildArgs.UseChecksum
                        msgID = 'RTW:makertw:enterMdlRefTargetChecksum';
                    else
                        msgID = 'RTW:makertw:enterMdlRefTarget';
                    end
                else
                    msgID = 'RTW:makertw:exitMdlRefTarget';
                end
                msg = DAStudio.message(msgID,targetType, h.ModelName);
              otherwise
                tgt = get_param(h.ModelName,'SystemTargetFile');
                switch(tgt)
                  case 'accel.tlc'
                    if strcmp(hook,'entry')
                        msgID = 'RTW:makertw:enterAccelTarget';
                    else
                        msgID = 'RTW:makertw:exitAccelTarget';
                    end
                  case 'raccel.tlc'
                    if isequal(hook,'entry')
                        % This case is handled separately (in tlc_c.m)
                        msgID = ''; 
                    else 
                        msgID = 'Simulink:tools:rapidAccelBuildFinish';
                    end
                  otherwise 
                    if strcmp(hook,'entry')
                        msgID = 'RTW:makertw:enterRTWBuild';
                    else
                        if strcmp(get_param(h.ModelName,'GenCodeOnly'),'off')
                            msgID = 'RTW:makertw:exitRTWBuild';
                        else
                            msgID = 'RTW:makertw:exitRTWGenCodeOnly';
                        end
                    end
                end
                if ~isempty(msgID)
                    msg = DAStudio.message(msgID,h.ModelName);
                else
                    msg = '';
                end
            end
            if ~isempty(msg)
                feval(h.DispHook{:}, msg);
            end
        else
            % if this is an error_cleanup call, then display the error
            % message and exit
            if strcmp(hook,'error')
                msg = DAStudio.message('RTW:makertw:buildAborted',h.ModelName);
                feval(h.DispHook{:}, msg);
                return;
            end
        end
    end
end

cs = getActiveConfigSet(h.ModelName);
isERT = strcmp(cs.getProp('IsERTTarget'), 'on');
isMdlRefSim = strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM');

if isERT
    if strcmp(hook,'entry') &&...
            ~isMdlRefSim &&...
            ~ecoderinstalled()
      DAStudio.error('RTW:makertw:licenseUnavailable',h.SystemTargetFilename);
    end
  make_ecoder_hook(hook,h,cs);
end

% Invoke RTW build custom hook after_make method
if ~(isMdlRefSim ||...
    isequal(strtok(get_param(h.ModelName, 'RTWSystemTargetFile'),'.'),'accel') || ...
    ~isequal(get_param(h.ModelName, 'RapidAcceleratorSimStatus') , 'inactive'))
  invoke_rtwbuild_custom_hook(h,args.customHook, args.buildInfo);
end

%endfunction


%------------------------------------------------------------------------------
%
% function: locGetHookArgs 
%
% inputs:
%   h - handle to makertw object
%   hook = hook method being called
%
%------------------------------------------------------------------------------
     
%End of function
function args = locGetHookArgs(h,hook)

%set up the defaults, and override them below for the different hooks
args.RTWroot   = h.RTWRoot;
args.TMF       = h.TemplateMakefile;
args.buidOpts  = h.BuildOpts;
args.buildArgs = h.BuildArgs;
args.buildInfo = [];
args.msgID     = '';

switch (hook)
  case 'entry'
    args.RTWroot    = [];
    args.TMF        = [];
    args.buidOpts   = [];
    args.buildInfo  = [];
    args.customHook = 'CodeGenEntry';
    args.msgID      = 'RTW:makertw:enterMdlRefTarget';
  case 'before_tlc'
    args.customHook = 'CodeGenBeforeTLC';
  case 'after_tlc'
    args.customHook = 'CodeGenAfterTLC';
  case 'before_make'
    args.customHook = 'CodeGenBeforeMake';
  case 'after_make'
    args.buildInfo = h.BuildInfo;
    args.customHook = 'CodeGenAfterMake';
  case 'exit'
    args.customHook = 'CodeGenExit';
  case 'error'
    args.RTWroot    = [];
    args.TMF        = [];
    args.buidOpts   = [];
    args.buildInfo  = [];
    args.msgID      = '';
  otherwise
    DAStudio.error('RTW:makertw:invalidRTWMakeHook',hook);
end

% LocalWords:  AFTERMAKE hookfile cd's th sp cd'd raccel
