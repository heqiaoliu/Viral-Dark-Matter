function op = EvalOperPointForms(this)
% EVALOPERPOINTFORMS  Evaluate the operating point forms
 
% Author(s): John W. Glass 24-Jun-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:23 $

% Create a copy of the operating point and check for a consistent set of
%  operating point
op = copy(this.OpPoint);
update(op,true);

% Get the tabledata
if isempty(this.Dialog)
    this.getDialogSchema;
end

% Get the states
states = op.States;

% Convert to Matlab data types
mStateIndices = this.StateIndices+1;
Data = this.StateTableData;

% Set the state values
for ct1 = 1:length(states)
    for ct2 = 1:states(ct1).Nx
        variable = Data{mStateIndices(ct1)+ct2,2};
        states(ct1).x(ct2) = LocalCheckInvalidData(variable);
    end
end

% Get the inputs
inputs = op.Inputs;

% Convert to Matlab data types
mInputIndices = this.InputIndices+1;
Data = this.InputTableData;

% Set the input values
for ct1 = 1:length(inputs)
    for ct2 = 1:inputs(ct1).PortWidth
        variable = Data{mInputIndices(ct1)+ct2,2};
        inputs(ct1).u(ct2) = LocalCheckInvalidData(variable);
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = LocalCheckInvalidData(valin)

try
    data = evalin('base', valin);
catch Ex %#ok<NASGU>
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidWorkspaceParameter',valin)
end

if ~(isa(data,'double') && ...
              length(data) == 1 && ...
              isreal(data) && ...
              ~isnan(data) && ...
              ~isinf(data));
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidScalarFiniteRealValue',valin)
end
