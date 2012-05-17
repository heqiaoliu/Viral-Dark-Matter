function mergefcn(block)
% Level-2 MATLAB-file S-Function for merge demo.
%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.7.2.3 $ 

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of input and output ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 0;

  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Set to SimViewing device
  block.SetSimViewingDevice(true);

  %% Run accelerator on TLC
  block.SetAccelRunOnTLC(false);
  
  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',      @DoPostPropSetup);
  block.RegBlockMethod('Start',                     @Start);
  block.RegBlockMethod('Update',                    @Update); 
  block.RegBlockMethod('Terminate',                 @Terminate); 



function DoPostPropSetup(block)

block.NumDworks = 2;

block.Dwork(1).Name            = 'blockHandle';
block.Dwork(1).Dimensions      = 2;
block.Dwork(1).DatatypeID      = 0;      % double
block.Dwork(1).Complexity      = 'Real'; % real
block.Dwork(1).UsedAsDiscState = false;

block.Dwork(2).Name            = 'DirtyFlag';
block.Dwork(2).Dimensions      = 1;
block.Dwork(2).DatatypeID      = 8;      % boolean
block.Dwork(2).Complexity      = 'Real'; % real
block.Dwork(2).UsedAsDiscState = false;


function Start(block)
% Store Handle of the Subsystems
root = get_param(bdroot,'Handle');
subs = find_system(root,'Tag','MergeExample');
block.Dwork(1).Data = subs;

% Store the dirty status of the model
dirtyFlag = get_param(get_param(gcs,'Parent'),'Dirty');
if strcmp(dirtyFlag,'on')
    block.Dwork(2).Data = true;
else
    block.Dwork(2).Data = false;
end


function Update(block)

subs = block.Dwork(1).Data;
parent = get_param(get_param(gcbh,'Parent'),'Handle');

notme = subs(subs ~= parent);
me = subs(subs == parent);

if ~strcmp(get_param(me,'BackgroundColor'),'green')
  set_param(me,'BackgroundColor','green');
  set_param(notme,'backgroundcolor','white');
  drawnow
end

pause(0.1);


function Terminate(block)

subs = block.Dwork(1).Data;
set_param(subs(1),'Backgroundcolor','white');
set_param(subs(2),'Backgroundcolor','white');

if isequal(block.Dwork(2).Data,false)
    set_param(get_param(gcs,'Parent'),'Dirty','off');
end

