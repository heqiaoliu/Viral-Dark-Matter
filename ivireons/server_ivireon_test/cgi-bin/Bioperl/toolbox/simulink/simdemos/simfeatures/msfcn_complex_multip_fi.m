function msfcn_complex_multip_fi(block)
%  
%% The setup method is used to setup the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%

%   Copyright 2008-2009 The MathWorks, Inc.

setup(block);

%% Function: setup ===================================================
%% Abstract:
%%   Set up the S-function block's basic characteristics such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%% 
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 2;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Behave consistently with C S-functions and suppress
% warnings about inconsistent sample times
block.SetAllowConstantSampleTime(false);

block.InputPort(1).Complexity  = 'complex';
block.InputPort(1).SamplingMode = 'Sample';
  
block.InputPort(2).Complexity  = 'complex';
block.InputPort(2).SamplingMode = 'Sample';
  
block.OutputPort(1).Complexity  = 'complex';
block.OutputPort(1).SamplingMode = 'Sample';

% Register parameters
block.NumDialogPrms     = 0;

%% Set the block simStateCompliance to default (i.e., same as a built-in block)
block.SimStateCompliance = 'DefaultSimState';


%% -----------------------------------------------------------------
%% Options
%% -----------------------------------------------------------------
% Specify if Accelerator should use TLC or call back into
% MATLAB file
block.SetAccelRunOnTLC(false);

%% -----------------------------------------------------------------
%% The MATLAB file S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file.
%% -----------------------------------------------------------------

%% -----------------------------------------------------------------
%% Register methods called during update diagram/compilation
%% -----------------------------------------------------------------

block.RegBlockMethod('CheckParameters', @CheckPrms);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('Terminate', @Terminate);

% Inherit datatype id for non-built-in datatypes
block.RegBlockMethod('SetInputPortDataType', @SetInpPortDataType);
block.RegBlockMethod('SetOutputPortDataType', @SetOutputPortDataType);

function SetOutputPortDataType(block, idx, dt)
  
  block.OutputPort(idx).DataTypeID = dt;
  
function SetInpPortDataType(block, idx, dt)

  block.InputPort(idx).DataTypeID = dt;
  % Obtain data types of input ports
  dt1 = block.InputPort(1).DataTypeID;
  dt2 = block.InputPort(2).DataTypeID;
  
  % Calculate output data types when both input port data types are ready
  if dt1 ~= -1 && dt2 ~= -1 && block.DataTypeIsFixedPoint(dt1) ...
            && block.DataTypeIsFixedPoint(dt2)
    p1 = block.FixedPointNumericType(dt1);
    p2 = block.FixedPointNumericType(dt2);
    
    w1 = p1.WordLength;
    f1 = p1.FractionLength;
    s1 = p1.Signed;
    
    w2 = p2.WordLength;
    f2 = p2.FractionLength;
    s2 = p2.Signed;
    
    newId = block.RegisterDataTypeFxpSlopeBias(s1 || s2,w1+w2+1, 1.0*2^(-f1-f2), 0, false);
    
    block.OutputPort(1).DataTypeID = newId;
  end


function CheckPrms(block)
  

function Start(block)
  

function InitializeConditions(block)
  

function Outputs(block)

    inp1 = block.InputPort(1).Data;
    inp2 = block.InputPort(2).Data;
    tmp = inp1.*inp2;
    block.OutputPort(1).Data = tmp;

function Terminate(block)
