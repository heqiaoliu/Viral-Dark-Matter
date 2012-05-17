function IterInfo = getIterInfo(this, values, state, type)
%GETITERINFO  Translates optim info into a common format.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2006/12/27 20:58:17 $

% Update IterInfo.
if isempty(state.stepsize)
  state.stepsize = NaN;
end

% todo: cost calculation will not hold if QR is used (because
% Nobs~=numel(state.residual))
IterInfo.Cost      = state.resnorm/numel(state.residual);
IterInfo.FCount    = state.funccount;
IterInfo.FirstOrd  = state.firstorderopt;
IterInfo.Gradient  = state.gradient';
IterInfo.Iteration = state.iteration;
IterInfo.StepSize  = state.stepsize;
IterInfo.Values    = values';
