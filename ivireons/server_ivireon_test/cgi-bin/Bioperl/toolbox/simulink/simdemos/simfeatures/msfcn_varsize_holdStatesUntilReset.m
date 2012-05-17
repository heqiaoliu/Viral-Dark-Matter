function msfcn_varsize_holdStatesUntilReset(block)
% Level-2 MATLAB file S-Function.
%
%  This block delays the input signal. The input size can change only when 
% a reset occurs.
%
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/12/07 20:47:41 $

setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup functional port properties to dynamically inherit
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Register the properties of the input port
block.InputPort(1).Complexity        = 'Inherited';
block.InputPort(1).DataTypeId        = -1    ;
block.InputPort(1).SamplingMode      = 'Sample';
block.InputPort(1).DimensionsMode    = 'Inherited';
block.InputPort(1).DirectFeedthrough = true;

% Register the properties of the output port
block.OutputPort(1).DimensionsMode = 'Variable';
block.OutputPort(1).SamplingMode   = 'Sample';

% Register sample times
%  [-1, 0]   : Inherited sample time
block.SampleTimes = [-1 0];

% Flag to show support of signals for which the number of dimensions is 
% greater than 2.
block.AllowSignalsWithMoreThan2D = true;

% Register methods called during update diagram/compilation
block.RegBlockMethod('SetInputPortDimensions',      @SetInputPortDims);
block.RegBlockMethod('SetInputPortDimensionsMode',  @SetInputDimsMode);
block.RegBlockMethod('SetOutputPortDimensions',     @SetOutPortDims);
block.RegBlockMethod('InitializeConditions',        @InitializeConditions);
block.RegBlockMethod('PostPropagationSetup',        @DoPostPropSetup);

% Register methods called at run time
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('Update',  @Update);

% -------------------------------------------------------------------------
function SetInputDimsMode(block, port, dm)
% Set dimension mode
block.InputPort(port).DimensionsMode = dm;
block.OutputPort(port).DimensionsMode = dm;

% -------------------------------------------------------------------------
function SetInputPortDims(block, idx, di)
% Set output compiled dimensions from input information
block.InputPort(idx).Dimensions = di;
block.OutputPort(idx).Dimensions = di;

% -------------------------------------------------------------------------
function DoPostPropSetup(block)
% Setup Dwork
block.SignalSizesComputeType = 'FromInputSize';
block.AddOutputDimsDependencyRules(1, 1, @setOutputVarDims);

dWorkDType      = block.InputPort(1).DatatypeID;
dWorkComplexity = block.InputPort(1).Complexity;
block.NumDworks = 1;

block.Dwork(1).Name            = 'valAfterReset';
block.Dwork(1).Dimensions      = 16;
block.Dwork(1).DatatypeID      = dWorkDType;
block.Dwork(1).Complexity      = dWorkComplexity';
block.Dwork(1).UsedAsDiscState = true;
block.DWorkRequireResetForSignalSize(1, 1);

% -------------------------------------------------------------------------
function SetOutPortDims(block, idx, di)
% Set compiled dimensions
block.OutputPort(idx).Dimensions = di;

% -------------------------------------------------------------------------
function InitializeConditions(block)
% Initialize the block states
dWorkSizeAtStart = block.InputPort(1).Dimensions;
block.Dwork(1).Data = reshape(zeros(dWorkSizeAtStart), 1, ...
    prod(dWorkSizeAtStart));

% -------------------------------------------------------------------------
function Outputs(block)
% Run-time method that copies the stored states into the output.
tmpData = block.Dwork(1).Data(...
    1:prod(block.OutputPort(1).CurrentDimensions));
block.OutputPort(1).Data = reshape(tmpData, ...
    block.OutputPort(1).CurrentDimensions);

% -------------------------------------------------------------------------
function Update(block)
% Update the states with the input values
dWorkDataNextStep = zeros(16, 1);
dWorkDataNextStep(1:prod(block.InputPort(1).CurrentDimensions)) = ...
    reshape(block.InputPort(1).Data, 1, ...
    prod(block.InputPort(1).CurrentDimensions));
block.Dwork(1).Data = dWorkDataNextStep;

% -------------------------------------------------------------------------
function setOutputVarDims(block, opIdx, inputIdx)
% Set current (run-time) dimensions
outDimsAfterReset = block.InputPort(inputIdx(1)).CurrentDimensions;
block.OutputPort(opIdx).CurrentDimensions = outDimsAfterReset;

% -------------------------------------------------------------------------
