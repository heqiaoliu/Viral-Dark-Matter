function state_struct = getStateStruct(this,model,varargin) 
% GETSTATESTRUCT  Get the state structure from a Simulink model and
% eliminate non-double and bus expanded states.  
%
% Use varargin to specify a boolean to call Simulink's getInitialState
% which will call the model output function to flush any integrator states.
%
 
% Author(s): John W. Glass 18-Oct-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 15:02:14 $

if nargin == 3
    flushoutputs = varargin{1};
else
    flushoutputs = false;
end

% Get the state structure from the Simulink model
if strcmp(get_param(model,'SimulationStatus'),'running') || flushoutputs;
    state_struct = feval(model,'get','state');
else
    state_struct = Simulink.BlockDiagram.getInitialState(model);
end

% If there are no states state_struct is undefined
if isempty(state_struct)
    state_struct = struct('signals',[]);
else
    state_struct = removeUnsupportedStates(this,state_struct);  
end