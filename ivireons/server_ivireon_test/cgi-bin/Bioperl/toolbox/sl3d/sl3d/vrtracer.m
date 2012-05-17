function vrtracer(cmd, bh)
%VRTRACER VR Tracer block Level-2 MATLAB code S-function
%
%   Not to be used directly.

%  Block UserData structure additions:
%   Step               used to construct unique DEF names of marker nodes created 
%                      in the associated virtual scene (e.g. 'Marker_1', 'Marker_2', etc.)
%   MarkerName         name of the marker shape PROTO to be used

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/02/08 23:02:06 $ $Author: batserve $

% distinguish between block setup and mask callback
if ischar(cmd)
  feval(cmd, bh)
else
  setup(cmd);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setup(block)

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;

% Register parameters
block.NumDialogPrms = 11;
block.DialogPrmsTunable = {'Nontunable','Nontunable','Nontunable','Nontunable',...
    'Nontunable','Nontunable','Nontunable','Nontunable','Nontunable', 'Nontunable', 'Nontunable'};

% Register number and dimension of ports
if block.DialogPrm(7).Data == 1
  block.NumInputPorts  = 2;
  block.InputPort(2).Dimensions = 3;  
else
  block.NumInputPorts  = 1;  
end
block.InputPort(1).Dimensions = 3;
block.NumOutputPorts = 0;

% Register sample time
ts = block.DialogPrm(10).Data; 
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DoPostPropSetup(block)

block.NumDworks = 2;

% Dwork(1) stores the ID of the associated virtual world
block.Dwork(1).Name            = 'WorldID';
block.Dwork(1).Dimensions      = 1;
block.Dwork(1).DatatypeID      = 0;      % vrworld ID - double
block.Dwork(1).Complexity      = 'Real'; % real
block.Dwork(1).UsedAsDiscState = false;

% Dwork(2) stores the position of an object in the previous block time step
% used to form 2-point lines connecting the previous and current position 
block.Dwork(2).Name            = 'LastPos';
block.Dwork(2).Dimensions      = 3;
block.Dwork(2).DatatypeID      = 0;      % double
block.Dwork(2).Complexity      = 'Real'; % real
block.Dwork(2).UsedAsDiscState = false;  

% Register all tunable parameters as runtime parameters.
block.AutoRegRuntimePrms;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start(block)

bh = block.BlockHandle;
ud = vrmfunc('getsetuserdata', bh);
if ~isfield(ud, 'Step')   % add custom fields on first Start
  ud.Step = 1;
  ud.MarkerName = '';
end
VrmlFile = block.DialogPrm(1).Data;

% load and open the VR World defined in the block mask
wh = vrworld(VrmlFile);
wid = get(wh,'id');

% save the virtual world ID for later use by Outputs()
if isvalid(wh)
  % vrworld handle can't be stored in Dwork, let's use the world ID -
  % double
  block.Dwork(1).Data = wid;  
  ud.World = wh;
else
  block.Dwork(1).Data = NaN;
  ud.World = vrworld;
end

% Fill-in LastPos at time = 0 with a meaningful value
block.Dwork(2).Data = block.InputPort(1).Data;

% Open the vrworld only if this block hasn't opened it previously
if ~ud.WorldOpen
  open(wh);
  ud.WorldOpen = true;
end

% open the viewer window if required and not yet open
% update windows status according to simulation status
if strcmpi(block.DialogPrm(11).Data,'on') 
  if get(wh,'Clients') == 0
    vrmfunc('getsetuserdata', bh, ud);
    vrmfunc('FnOpenFigure', bh, wh); 
    ud = vrmfunc('getsetuserdata', bh);
  end
end


pathtomfile = mfilename('fullpath');
pathtodir = fileparts(pathtomfile);
pathtomarkers = fullfile(pathtodir, filesep, 'vr_markers.wrl');

MarkerName = '';
if ~strcmpi(block.DialogPrm(3).Data,'None')
  % read selected shape from the block mask   
  MarkerName = horzcat('Marker_', block.DialogPrm(3).Data);
  % create an EXTERNPROTO with specified marker
  try
    addexternproto(ud.World, pathtomarkers, MarkerName);
  catch ME
    if ~strcmpi(ME.identifier, 'VR:protoexists')
      throwAsCaller(ME);
    end
  end
end

if strcmpi(block.DialogPrm(4).Data,'on') 
  % create a MarkerLine EXTERNPROTO
  try
    addexternproto(ud.World, pathtomarkers, 'MarkerLine');
  catch ME
    if ~strcmpi(ME.identifier, 'VR:protoexists')
      throwAsCaller(ME);
    end    
  end
end

if strcmpi(block.DialogPrm(5).Data,'on') 
  % create a MarkerTriad EXTERNPROTO 
  try
    addexternproto(ud.World, pathtomarkers, 'MarkerTriad');
  catch ME
    if ~strcmpi(ME.identifier, 'VR:protoexists')
      throwAsCaller(ME);
    end
  end
end
ud.MarkerName = MarkerName;

% save UserData
vrmfunc('getsetuserdata', bh, ud);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Outputs(block)

% get user data
bh = block.BlockHandle;
ud = vrmfunc('getsetuserdata', bh);

MarkerName = ud.MarkerName;
ParentNode = block.DialogPrm(2).Data;
MarkerScale = block.DialogPrm(6).Data;
                                      
MarkerColor = [1 0 0]; % red is default

switch block.DialogPrm(7).Data
  case 1
    MarkerColor = block.InputPort(2).Data';
  case 2
    switch block.DialogPrm(8).Data 
      case 'yellow'
        MarkerColor = [1 1 0];
      case 'magenta'
        MarkerColor = [1 0 1];
      case 'cyan'
        MarkerColor = [0 1 1];  
      case 'red'
        MarkerColor = [1 0 0];
      case 'green'
        MarkerColor = [0 1 0];
      case 'blue'
        MarkerColor = [0 0 1];
      case 'white'
        MarkerColor = [1 1 1];
      case 'black'
        MarkerColor = [0 0 0];
    end
  case 3   
    MarkerColor = block.DialogPrm(9).Data;
    if any(size(MarkerColor)~=[1 3]) || any(MarkerColor<0) || any(MarkerColor>1)
      throwAsCaller(MException('VR:invalidinarg',...
        'Marker color must be a 3-element row vector with RGB values in the interval <0;1>.'));
    end
end

% get virtual world and Parent node handles 
% leave error checking up to the vrnode()
wid = block.Dwork(1).Data;
try
  wh = vrworld(wid);
catch ME
  throwAsCaller(ME);
end

% increment step used to construct unique DEF names
ud.Step = ud.Step+1;

if ~strcmpi(MarkerName, '')
  % create a marker name if enabled in block mask (if marker name is not empty) 
  % use the block handle and ud.Step to give it a unique name 
  if ~isempty (ParentNode)
    % create node as a child of given parent node
    nh = vrnode(wh, ParentNode);
    newMarker = vrnode(nh, 'children', sprintf('%s_%bX_%d', MarkerName, bh, ud.Step), MarkerName);
  else
    % if parent node is empty create node in root of vrworld
    newMarker = vrnode(wh, sprintf('%s_%bX_%d', MarkerName, bh, ud.Step), MarkerName); 
  end

  % set marker node position and color
  newMarker.markerTranslation = block.InputPort(1).Data';
  newMarker.markerColor = MarkerColor;
  newMarker.markerScale = MarkerScale;
end

% create a line segment if enabled in block mask 
if strcmpi(block.DialogPrm(4).Data,'on') 

  % create a line segment node - use the block handle and ud.Step to give it a unique name
  if ~isempty (ParentNode)
    % create node as a child of given parent node
    nh = vrnode(wh, ParentNode);
    newLineMarker = vrnode(nh, 'children', sprintf('%s_%bX_%d', 'MarkerLine', bh, ud.Step), 'MarkerLine');
  else
    % if parent node is empty create node in root of vrworld
    newLineMarker = vrnode(wh, sprintf('%s_%bX_%d', 'MarkerLine', bh, ud.Step), 'MarkerLine'); 
  end

  % set line segment vertices ([lastpos current_pos]) and color according to input data
  LastPos = block.Dwork(2).Data;
  newLineMarker.markerPoint = [LastPos'; block.InputPort(1).Data'];
  newLineMarker.markerColor = MarkerColor;

end  
  
% create a Triad marker node - use the block handle and ud.Step to give it a unique name
if strcmpi(block.DialogPrm(5).Data,'on') 

  if ~isempty (ParentNode)
    % create node as a child of given parent node
    nh = vrnode(wh, ParentNode);
    newMarker = vrnode(nh, 'children', sprintf('%s_%bX_%d', 'MarkerTriad', bh, ud.Step), 'MarkerTriad');
  else
    % if parent node is empty create node in root of vrworld
    newMarker = vrnode(wh, sprintf('%s_%bX_%d', 'MarkerTriad', bh, ud.Step), 'MarkerTriad'); 
  end

  % set marker node position and scale according to input data (setting color doesn't have sense here)
  newMarker.markerTranslation = block.InputPort(1).Data';
  newMarker.markerScale = MarkerScale;

end

% current position becomes the LastPos...
block.Dwork(2).Data = block.InputPort(1).Data;

% save UserData
vrmfunc('getsetuserdata', bh, ud);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  MASK CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MarkerColorSelectionCallback(bh) %#ok<DEFNU> called by name from switchboard

valuesStr = get_param(bh, 'MaskValues');
vsblStr = get_param(bh, 'MaskVisibilities');
if strcmpi(valuesStr{7}, 'Block input');  
  vsblStr(8:9) = {'off', 'off'};
elseif strcmpi(valuesStr{7}, 'Selected from color list')
  vsblStr(8:9) = {'on', 'off'};
else
  vsblStr(8:9) = {'off', 'on'};
end    
set_param(bh, 'MaskVisibilities', vsblStr);
