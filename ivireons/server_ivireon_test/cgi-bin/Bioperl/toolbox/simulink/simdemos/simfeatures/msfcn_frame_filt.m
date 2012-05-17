function msfcn_frame_filt(block)
% Level-2 MATLAB file S-Function.
%  Two-tap FIR filter implementation for frame-based and sample-based signals.
%  Filter coefficients are passed as block parameters.
%
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/12/07 20:47:33 $
        
setup(block);

function setup(block)
  % Register number of ports.
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  % In Accelerator mode, the block runs on TLC.
  block.SetAccelRunOnTLC(true);

  % Set up the functional port properties.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  % Set up the inport data-type properties.
  block.InputPort(1).DatatypeID  = -1;
  block.InputPort(1).Complexity  = 'Real';

  % Set up the outport data-type properties.
  block.OutputPort(1).DatatypeID  = -1;
  block.OutputPort(1).Complexity  = 'Real';

  % Register the parameters.
  block.NumDialogPrms     = 2;
  block.DialogPrmsTunable = {'Nontunable','Nontunable'};
  
  % Register the methods.
  % Note that the Output method is registered in DoPostProp as it
  % requires knowledge about the signal sampling mode.
  block.RegBlockMethod('CheckParameters',         @CheckPrms);
  block.RegBlockMethod('SetInputPortDimensions',  @SetInpPortDims);
  block.RegBlockMethod('SetOutputPortDimensions', @SetOutPortDims);
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInpPortFrameData);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start',                   @Start);
  block.RegBlockMethod('WriteRTW',                @WriteRTW);
  
function CheckPrms(block)
  % Check the validity of the parameters.
  p1 = block.DialogPrm(1).Data;
  p2 = block.DialogPrm(2).Data;
  
  if sum(isnan(p1)+isnan(p2)+isinf(p1)+isinf(p2))
    error('Invalid parameter. Nan and inf are not allowed as parameter values.');
  end


function SetInpPortDims(block, idx, di)
  % Set the port dimensions for forward propagation of the dimensions.
  block.InputPort(idx).Dimensions = di;
  block.OutputPort(1).Dimensions  = di;

function SetOutPortDims(block, idx, di)
  % Set the port dimensions for backward propagation of the dimensions.
  block.InputPort(1).Dimensions    = di;
  block.OutputPort(idx).Dimensions = di;


function SetInpPortFrameData(block, idx, fd)
  % Set the block sampling mode to Frame or Sample depending on the
  % sampling mode of the input signal.
  block.InputPort(idx).SamplingMode  = fd;
  block.OutputPort(1).SamplingMode = fd;


function DoPostPropSetup(block)
  % Set the proper Output method based on the sampling mode.  
  if strcmp(block.InputPort(1).SamplingMode,'Sample')
    block.RegBlockMethod('Outputs', @OutputNonFrame);
  else
    block.RegBlockMethod('Outputs', @OutputFrame);
  end

  % Set up the dwork vector or scalar.
  block.NumDworks = 1;
  
  block.Dwork(1).Name = 'x';
  if strcmp(block.InputPort(1).SamplingMode,'Sample')
      block.Dwork(1).Dimensions      = prod(block.InputPort(1).Dimensions);
  else
      block.Dwork(1).Dimensions      = block.InputPort(1).Dimensions(2);
  end
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 0;
  block.Dwork(1).UsedAsDiscState = 1;


function Start(block)
  % Initialize the data.
  block.Dwork(1).Data = zeros(block.Dwork(1).Dimensions,1);
  
function OutputFrame(block)
  % Output method for the frame-based signals.
  
  % Retrieve the state and the parameters.
  x  = block.Dwork(1).Data;
  c1 = block.DialogPrm(1).Data;
  c2 = block.DialogPrm(2).Data;
  
  % Get the input data and allocate space for the output signal.
  inpData = block.InputPort(1).Data;
  fLen    = block.InputPort(1).Dimensions(1);
  nChan   = block.InputPort(1).Dimensions(2);
  outData = zeros(fLen,nChan);
  
  % Filter the frames in parallel for all channels, one sample at a time.
  for i = 1:fLen
    u            = inpData(i,:);
    outData(i,:) = (c1*u + c2*x.'); 
    x            = u.';
  end
  
  % Update the output.
  block.OutputPort(1).Data = outData;
  
  % Update the states. (No update function is needed.)
  block.Dwork(1).Data = x;
  
function OutputNonFrame(block)
  % Output function for sample-based (non-frame) signals.
  
  % Retrieve the state; get the input data and the parameters.
  x  = block.Dwork(1).Data';
  u  = block.InputPort(1).Data;
  c1 = block.DialogPrm(1).Data;
  c2 = block.DialogPrm(2).Data;
  
  y  = c1*u + c2*reshape(x,block.InputPort(1).Dimensions);
  
  % Update the output.
  block.OutputPort(1).Data = y;
    
  % Update the states. (No update function is needed.)
  block.Dwork(1).Data = u(:);
  
function WriteRTW(block)
  % Save the parameters to an RTW file for code generation.  
  c1 = sprintf('%d', block.DialogPrm(1).Data);
  c2 = sprintf('%d', block.DialogPrm(2).Data);
 
  block.WriteRTWParam('string', 'Coef1', c1);
  block.WriteRTWParam('string', 'Coef2', c2);
  
