function utPushOperatingPoint(this,model,op,opt)
% UTPUSHOPERATINGPOINT Push the operating point onto a Simulink model that
% has been compiled.

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/02/20 01:32:25 $

% Check to see that the operating condition is up to date
if strcmp(opt.ByPassConsistencyCheck,'off')
    try
        sync(op,true);
    catch UpdateException
        % We do not need to terminate the compilation since the update
        % function will terminate when an error is found.
        throwAsCaller(UpdateException);
    end
end

% Get the states and input levels.
[x,u] = LocalGetXU(op);

% Compute the outputs to flush any externally specified integrators
feval(model,[],[],[],'all'); % force all rates to have a sample hit
feval(model,op.Time,x,u,'outputs');
feval(model,op.Time,x,u,'outputs');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [xstruct,u] = LocalGetXU(OP)
function [xstruct,u] = LocalGetXU(op)

% Get the state structure
xstruct = getstatestruct(op);

% Extract the input levels handle multivariable case
u = [];
for ct = 1:length(op.Inputs)    
    u = [u;op.Inputs(ct).u(:)];
end
