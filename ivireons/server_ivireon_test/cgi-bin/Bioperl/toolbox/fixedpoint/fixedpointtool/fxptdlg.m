function varargout = fxptdlg(action, varargin)
%FXPTDLG   Fixed-Point Tool for Simulink.
%
%   FXPTDLG('MODEL') opens Fixed-Point Tool for Simulink with the specified
%   MODEL. The tool provides a user interface for converting floating point
%   models and subsystems to fixed-point.

%   Copyright 1994-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/02/18 02:06:51 $

if ~usejava('jvm')
    error('simulink:fxptdlg:javaRequired', xlate('Fixed-Point Tool requires Java to run.'))
end
error(nargchk(1, 2, nargin,'struct'));

%flag whether or not we are in the process of launching the tool
persistent islaunching;
%if we are called again while launching, return
if(islaunching);return;end
%set the flag (persists between calls as long as ML is up)
islaunching = true;
%try to launch tool
try
  error(nargoutchk(0,1,nargout,'struct'));
  varargout = {};
  if(isoldcallback(action))
    islaunching = false;
    return;
  end
  %get the model
  try
      system = parseSystem(action);
  catch e
      % return in case of expected errors.
      if strcmp(e.identifier,'FixedPoint:fixedPointTool:libraryOrLockedModelError') || strcmp(e.identifier,'FixedPoint:fixedPointTool:lockedModelError')
          islaunching = false;
          return;
      else
          islaunching = false;
          throw(e);
      end
  end
  me = fxptui.explorer(system);
  if(ishandle(action))
      blk = get_param(action, 'Object');
      if(isa(blk, 'Simulink.SubSystem'))
          me.selectnode(blk.getFullName);
      end
  end
  %remove version 1 instrumentation if it exists
  clearoldcallbacks(system);
  %display the tool
  me.show;
  %return an output when requested.
  if nargout>0, varargout{1} = me; end
  %reset flag so we can call in again later
  islaunching = false;
catch fpt_exception
  %reset flag so we can call in again later
  islaunching = false;
  rethrow(fpt_exception);
end

%--------------------------------------------------------------------------
function b = isoldcallback(arg)
b = false;
oldcallbacks = { ...
  'fxptdlg_presave_cb', ...
  'fxptdlg_close_cb', ...
  'fxptdlg_simInit_cb', ...
  'fxptdlg_sim_cb', ...
  'fxptdlg_store_cb'};
%make sure 'arg' isn't a handle to model or block
if(ischar(arg))
  b =  ismember(arg, oldcallbacks);
end
%--------------------------------------------------------------------------
function clearoldcallbacks(system)
expression = 'fxptdlg\(.*?\);';
repstring = '';
try
  bd =  get_param(system, 'Object');
  olddirt = bd.Dirty;
  bd.PreSaveFcn = regexprep(bd.PreSaveFcn, expression, repstring);
  bd.CloseFcn = regexprep(bd.CloseFcn, expression, repstring);
  bd.InitFcn = regexprep(bd.InitFcn, expression, repstring);
  bd.StartFcn = regexprep(bd.StartFcn, expression, repstring);
  bd.StopFcn = regexprep(bd.StopFcn, expression, repstring);
  bd.Dirty = olddirt;
catch
  %consume errors. we are trying to remove instrumentation transparently.
end

%--------------------------------------------------------------------------
function [rootSystem, parentPath, fullPath, name] = getPathsFromHandle(hdle)

parentPath = '';    % path to the parent of current system.
rootSystem = '';    % top level block diagram
fullPath = '';      % full path including current subsystem
name   = '';

% determine the parentPath and name.
if isnumeric(hdle)
  parentPath = get_param(hdle,'Parent');
  name = get_param(hdle,'Name');
else
  [t,r] = strtok(fliplr(hdle),'/');
  parentPath = fliplr(r);
  name = fliplr(t);
end

% We allow blocks to have '/' in their names. We need to escape the slash
% so that the block opens right
name = strrep(name,'/','//');

% get the rootSystem
if isempty(parentPath)
  rootSystem = name;
else
  rootSystem = strtok(parentPath,'/');
end

% get the full path
if isempty(parentPath)
  fullPath = name;
else
  if strcmp(parentPath(length(parentPath)),'/')
    fullPath = [parentPath,name];
  else
    fullPath = [parentPath,'/',name];
  end
end


%--------------------------------------------------------------------------
function system = parseSystem(action)
% Input parsing copied from pre-R2006b code.  In this local function we
% perform error checking and open system

parentPath = '';    % path to the parent of current system.
rootSystem = '';    % top level block diagram
fullPath = '';      % full path including current subsystem

[rootSystem, parentPath, fullPath, action] = getPathsFromHandle(action);

% get the system name without the .mdl (just in case)
system = strtok(rootSystem,'.');

% Do some error checking.
if ~ischar(system),
  DAStudio.error('FixedPoint:fixedPointTool:errorArgNotString');
end
existcode = exist(system);
if(existcode ~= 4 && existcode ~= 2)
  DAStudio.error('FixedPoint:fixedPointTool:errorSysNotFound', system);
end

% Open the model and prepare to initialize the dialog.
open_system(system);
open_system(fullPath);

%
% Don't allow the dialog on a library or locked model
%    This code MUST come after open_system.
%
if ~strcmpi(get_param(system,'BlockDiagramType'),'model')
    msg_ID = 'FixedPoint:fixedPointTool:libraryOrLockedModelError';
    msg = DAStudio.message(msg_ID);
    helpdlg(msg,'Fixed-Point Tool');
    % Create a MException and throw the error to the calling function to terminate execution.
    fpt_exception = MException(msg_ID, msg);
    throw(fpt_exception);
elseif strcmpi(get_param(system,'Lock'),'on')
    msg_ID = 'FixedPoint:fixedPointTool:lockedModelError';
    msg = DAStudio.message(msg_ID);
    errordlg(msg);
    % Create a MException and throw the error to the calling function to terminate execution.
    fpt_exception = MException(msg_ID, msg);
    throw(fpt_exception);
end

% [EOF]
