function msfcn_varsize_expand(block)
% Level-2 MATLAB file S-Function.
%  Takes a scalar input and outputs a vector of length indicated 
% by its input value. The output is given by 1:n where n is the input
% value.
% For example
%  f(5) = [1 2 3 4 5]
%
% The parameter defines the maximum input value allowed.
%
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/12/07 20:47:40 $

setup(block);

function setup(block)

% Register number of ports and parameters
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;
block.NumDialogPrms  = 1;

% Setup functional port properties to dynamically inherited
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Register the properties of the input port
block.InputPort(1).Complexity        = 'Inherited';
block.InputPort(1).DataTypeId        = -1;
block.InputPort(1).SamplingMode      = 'Sample';
block.InputPort(1).DimensionsMode    = 'Fixed';
block.InputPort(1).DirectFeedthrough = true;

% Register the properties of the output port
block.OutputPort(1).DimensionsMode = 'Variable';
block.OutputPort(1).SamplingMode   = 'Sample';

% Register sample times
%  [-1, 0] : Inherited sample time
block.SampleTimes = [-1 0];

% Register methods called during update diagram/compilation
block.RegBlockMethod('SetInputPortDimensions',      @SetInputPortDims);
block.RegBlockMethod('PostPropagationSetup',        @DoPostPropSetup);

% Register methods called at run-time
block.RegBlockMethod('Outputs', @Outputs);

% -------------------------------------------------------------------------
function SetInputDimsMode(block, port, dm)
% Set dimension mode
block.InputPort(port).DimensionsMode = dm;

% -------------------------------------------------------------------------
function SetInputPortDims(block, idx, di)
width = prod(di);
if width ~= 1  
     DAStudio.error('Simulink:blocks:multirateInvaliDimension'); 
end
% Set compiled dimensions 
block.InputPort(idx).Dimensions = di;
block.OutputPort(idx).Dimensions =[1 block.DialogPrm(1).Data];

% -------------------------------------------------------------------------
function DoPostPropSetup(block)
% Set the type of signal size to be dependent on input values, i.e.,
% dimensions have to be updated at output
block.SignalSizesComputeType = 'FromInputValueAndSize';

% -------------------------------------------------------------------------
function Outputs(block)
% Output function:
% -update output values
% -update signal dimensions
block.OutputPort(1).CurrentDimensions = [1 block.InputPort(1).Data];
block.OutputPort(1).Data = 1:block.InputPort(1).Data;
