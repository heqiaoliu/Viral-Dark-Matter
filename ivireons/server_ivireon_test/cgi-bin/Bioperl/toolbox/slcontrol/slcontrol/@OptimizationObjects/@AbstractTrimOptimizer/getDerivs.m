function xk1 = getDerivs(this,xstruct,u)
% GETDERIVS  Compute the derivatives and the update deviations
%
 
% Author(s): John W. Glass 01-Mar-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2006/11/17 14:03:51 $

% Compute model update and derivatives
dx = feval(this.model, this.t, xstruct, u, 'derivs');
xk1 = feval(this.model, this.t, xstruct, u, 'update');

% Eliminate unsupported states
xk1 = removeUnsupportedStates(slcontrol.Utilities,xk1);

% Loop over each of the derivatives and replace the update values in ds
% with the values of the derivated.
if this.ncstates > 0
    for ct = 1:length(dx.signals)
        ind = find(strcmp(dx.signals(ct).blockName,{xk1.signals.blockName}));
        xk1.signals(ind).values = dx.signals(ct).values;
    end
end

% Now loop over the discrete states and compute the xk+1 - xk 
for ct = 1:length(xstruct.signals)
    if xk1.signals(ct).sampleTime(1) > 0
        xk1.signals(ct).values = xk1.signals(ct).values(:) - xstruct.signals(ct).values(:);
    end
end