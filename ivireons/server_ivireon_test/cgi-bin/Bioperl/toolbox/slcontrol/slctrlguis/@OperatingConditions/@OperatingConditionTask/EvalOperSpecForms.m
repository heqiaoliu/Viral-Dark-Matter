function opspec = EvalOperSpecForms(this)
% EVALOPERSPECFORMS  Evaluate the operating point specification forms.
%
 
% Author(s): John W. Glass 24-Jun-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:36 $

% Create a copy of the operating spec object
opspec = copy(this.OpSpecData);

% Get the states
states = opspec.States;

% Get the tabledata
mStateIndices = this.StateIndices+1;
Data = this.StateSpecTableData;

% Set the state values
for ct1 = 1:length(states)
    for ct2 = 1:states(ct1).Nx
        % Value Column
        variable = Data{mStateIndices(ct1)+ct2,2};
        d_numeric = str2double(variable);
        if isnan(d_numeric) || isinf(d_numeric)
            states(ct1).x(ct2) = LocalCheckInvalidData(variable);
        end
        % Known Column
        variable = Data{mStateIndices(ct1)+ct2,3};
        states(ct1).Known(ct2) = variable;
        % Steady State Column
        variable = Data{mStateIndices(ct1)+ct2,4};
        states(ct1).SteadyState(ct2) = variable;
        % Lower Bound Column
        variable = Data{mStateIndices(ct1)+ct2,5};
        states(ct1).Min(ct2) = LocalCheckInvalidDataAllowInf(variable);
        % Upper Bound Column
        variable = Data{mStateIndices(ct1)+ct2,6};
        states(ct1).Max(ct2) = LocalCheckInvalidDataAllowInf(variable);
    end
end

% Get the inputs
inputs = opspec.Inputs;

% Get the tabledata
mInputIndices = this.InputIndices+1;
Data = this.InputSpecTableData;

% Set the inputs values
for ct1 = 1:length(inputs)
    for ct2 = 1:inputs(ct1).PortWidth
        % Value Column
        variable = Data{mInputIndices(ct1)+ct2,2};
        d_numeric = str2double(variable);
        if isnan(d_numeric) || isinf(d_numeric)
            inputs(ct1).u(ct2) = LocalCheckInvalidData(variable);
        end
        % Known Column
        variable = Data{mInputIndices(ct1)+ct2,3};
        inputs(ct1).Known(ct2) = variable;
        % Lower Bound Column
        variable = Data{mInputIndices(ct1)+ct2,4};
        inputs(ct1).Min(ct2) = LocalCheckInvalidDataAllowInf(variable);
        % Upper Bound Column
        variable = Data{mInputIndices(ct1)+ct2,5};
        inputs(ct1).Max(ct2) = LocalCheckInvalidDataAllowInf(variable);
    end
end

% Get the outputs
outputs = opspec.Outputs;

% Get the tabledata
mOutputIndices = this.OutputIndices+1;
Data = this.OutputSpecTableData;

% Set the output values
for ct1 = 1:length(outputs)
    for ct2 = 1:outputs(ct1).PortWidth
        % Value Column
        variable = Data{mOutputIndices(ct1)+ct2,2};
        d_numeric = str2double(variable);
        if isnan(d_numeric) || isinf(d_numeric)
            outputs(ct1).y(ct2) = LocalCheckInvalidData(variable);
        end
        % Known Column
        variable = Data{mOutputIndices(ct1)+ct2,3};
        outputs(ct1).Known(ct2) = variable;
        % Lower Bound Column
        variable = Data{mOutputIndices(ct1)+ct2,4};
        outputs(ct1).Min(ct2) = LocalCheckInvalidDataAllowInf(variable);
        % Upper Bound Column
        variable = Data{mOutputIndices(ct1)+ct2,5};
        outputs(ct1).Max(ct2) = LocalCheckInvalidDataAllowInf(variable);
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = LocalCheckInvalidData(valin)

if ischar(valin)
    try
        data = evalin('base', valin);
    catch Ex %#ok<NASGU>
        ctrlMsgUtils.error('Slcontrol:linutil:InvalidWorkspaceParameter',valin)
    end
else
    data = valin;
end

if ~(isa(data,'double') && ...
              length(data) == 1 && ...
              isreal(data) && ...
              ~isnan(data) && ...
              ~isinf(data));
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidScalarFiniteRealValue',valin)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = LocalCheckInvalidDataAllowInf(valin)

try
    data = evalin('base', valin);
catch Ex %#ok<NASGU>
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidWorkspaceParameter',valin)
end

if ~(isa(data,'double') && ...
              length(data) == 1 && ...
              isreal(data) && ...
              ~isnan(data));          
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidScalarRealValue',valin)
end