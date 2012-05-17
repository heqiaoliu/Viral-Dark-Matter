function vrtxtout(block)
%VRTXTOUT VR Text Output block Level-2 MATLAB code S-function
%
%   Not to be used directly.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/02/08 23:02:07 $ $Author: batserve $

setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 0;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;

% Register parameters
block.NumDialogPrms     = 5;
block.DialogPrmsTunable = {'Nontunable','Nontunable','Nontunable','Nontunable','Nontunable'};

% Register sample time
ts = block.DialogPrm(4).Data;
if length(ts)<2
  ts(2)= 0;
end
block.SampleTimes = ts;

% Block options
block.SetSimViewingDevice(true);
block.SetAccelRunOnTLC(false);
block.SimStateCompliance = 'HasNoSimState';  % this block is a viewer - do not save any state info

% Register methods
block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);


function DoPostPropSetup(block)

block.NumDworks = 1;

block.Dwork(1).Name            = 'WorldID';
block.Dwork(1).Dimensions      = 1;
block.Dwork(1).DatatypeID      = 0;      % vrworld ID - double
block.Dwork(1).Complexity      = 'Real'; % real
block.Dwork(1).UsedAsDiscState = false;

% Register all tunable parameters as runtime parameters.
block.AutoRegRuntimePrms;


function Start(block)

bh = block.BlockHandle;
ud = vrmfunc('getsetuserdata', bh);

VrmlFile = block.DialogPrm(1).Data;
FormatString = block.DialogPrm(3).Data;

% generate error if there is a %s or %c conversion character
% in the format string (%%s and %%c are OK...)
if ( ~isequal(strfind(FormatString,'%%s')+1, strfind(FormatString,'%s')) ...
   || ~isequal(strfind(FormatString,'%%c')+1, strfind(FormatString,'%c')) ) 
 error('VR:invalidconvchar', '%s', ...
    '%s and %c conversion characters not allowed in the format string.');
end

% load and open the VR World defined in the block mask
wh=vrworld(VrmlFile);
wid = get(wh,'id');

% save the virtual world ID for later use by Outputs()
if isvalid(wh)
  % vrworld handle can't be stored in Dwork, let's use the world ID - double
  block.Dwork(1).Data = wid;  
  ud.World = wh;
else
  block.Dwork(1).Data = NaN;
  ud.World = vrworld;
end

% Open the vrworld only if this block hasn't opened it previously
if ~ud.WorldOpen
  open(wh);
  ud.WorldOpen = true;
end

% open the viewer window if required and not yet open
% update windows status according to simulation status
if strcmpi(block.DialogPrm(5).Data,'on')
  if get(wh,'Clients') == 0
    vrmfunc('getsetuserdata', bh, ud);
    vrmfunc('FnOpenFigure', bh, wh); 
    ud = vrmfunc('getsetuserdata', bh);
  end
end

% save UserData
vrmfunc('getsetuserdata', bh, ud);


function Outputs(block)

TxtNode = block.DialogPrm(2).Data;
FormatString = block.DialogPrm(3).Data;

% get virtual world and Text node handles 
% leave error checking up to the vrnode()
wid = block.Dwork(1).Data;
wh = vrworld(wid);
nh = vrnode(wh,TxtNode);
  
% Set the value of the string field of given Text node
% based on the format string and block input
% 
% Output of sprintf() is scanned for new line characters
% and text is separated into lines in a cell array
% required by VRT

[str,err] = sprintf(FormatString, block.InputPort(1).Data);
if isempty(err)
  % create cell array containing separate text lines
  str = textscan(str, '%s', 'delimiter', '\n');
  setfield(nh,'string', str{1});  %#ok<STFLD,SFLD> this is overloaded SETFIELD
else
  setfield(nh,'string', sprintf('Error evaluating format string: %s', err));  %#ok<STFLD,SFLD> this is overloaded SETFIELD
end
