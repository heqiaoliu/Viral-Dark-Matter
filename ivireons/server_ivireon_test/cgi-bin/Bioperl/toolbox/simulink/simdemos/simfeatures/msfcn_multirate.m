function msfcn_multirate(block)
% Level-2 MATLAB file S-Function for multirate demo:
%
% The S-function will take one 1-D input, and output a 1-D signal that
% is 6 times downsampled version of the input signal.

%   Copyright 2007-2009 The MathWorks, Inc.

  setup(block);
%endfunction

function setup(block)
  %% Register number of input port and output port
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;
  
  %% Setup functional port properties
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  block.InputPort(1).DatatypeID    = 0;
  block.InputPort(1).Complexity    = 0;
  block.InputPort(1).Dimensions    = 1;
  block.InputPort(1).SamplingMode  = 0;
  
  block.OutputPort(1).DatatypeID   = 0;
  block.OutputPort(1).Complexity   = 0;
  block.OutputPort(1).Dimensions   = 1;
  block.OutputPort(1).SamplingMode = 0;
  
  block.InputPort(1).SampleTime  = [-1 0];
  block.OutputPort(1).SampleTime = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  block.SetAccelRunOnTLC(true);
  
  %% Reg methods
  block.RegBlockMethod('SetInputPortSampleTime',  @SetInpPortST);
  block.RegBlockMethod('SetOutputPortSampleTime', @SetOutPortST);
  block.RegBlockMethod('SetInputPortDimensions',  @SetInpPortDims);
  block.RegBlockMethod('SetOutputPortDimensions', @SetOutPortDims);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
%endfunction

% Set input port sample time
function SetInpPortST(block, idx, st)
  block.InputPort(1).SampleTime = st;
  block.OutputPort(1).SampleTime = [st(1)*6, st(2)];
%endfunction

% Set output port sample time
function SetOutPortST(block, idx, st)
  block.OutputPort(1).SampleTime = st;
  block.InputPort(1).SampleTime = [st(1)/6, st(2)];
%endfunction

% Set input port dimensions
function SetInpPortDims(block, idx, di)
  if idx ~= 1
    DAStudio.error('Simulink:blocks:multirateOnePort'); 
  end
  
  if block.InputPort(1).SamplingMode == 0
    width = prod(di);
    if width ~= 1
      DAStudio.error('Simulink:blocks:multirateInvaliDimension'); 
    end
  end
  
  block.InputPort(idx).Dimensions = di;
  block.OutputPort(1).Dimensions = di;
%endfunction

% Set output port dimensions
function SetOutPortDims(block, idx, di)
  if block.InputPort(1).SamplingMode == 0
    width = prod(di);
    if width ~= 1
      DAStudio.error('Simulink:blocks:multirateInvaliDimension'); 
    end
  end
  
  block.InputPort(1).Dimensions  = di;
  block.OutputPort(1).Dimensions = di;
%endfunction

% Do post-propagation process
function DoPostPropSetup(block)
%% Setup DWork
  block.NumDworks = 2;
  block.Dwork(1).Name = 'x1';

  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 0;
  block.Dwork(1).UsedAsDiscState = 1;
  
  block.Dwork(2).Name = 'x2';

  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 0;
  block.Dwork(2).UsedAsDiscState = 1;
  
  block.RegBlockMethod('Outputs', @OutputNonFrame);  

%endfunction

function Start(block)

  block.Dwork(1).Data = 0;
  block.Dwork(2).Data = 0;
  
%endfunction

function OutputNonFrame(block)

  if block.InputPort(1).IsSampleHit
    block.Dwork(2).Data = block.Dwork(1).Data;
    block.Dwork(1).Data = block.InputPort(1).Data;
  end

  if block.OutputPort(1).IsSampleHit
    block.OutputPort(1).Data = block.Dwork(2).Data;
  end
  
%endfunction

