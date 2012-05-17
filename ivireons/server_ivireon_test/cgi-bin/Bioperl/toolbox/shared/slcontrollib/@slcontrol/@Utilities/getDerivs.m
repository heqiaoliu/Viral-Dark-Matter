function xk1 = getDerivs(this,model,t,xstruct,u)
% GETDERIVS  Compute the derivatives and the update deviations using the
% structure format.  The return argument is a structure with the updates
% and derivatives
 
% Author(s): John W. Glass 01-Mar-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2007/12/14 15:02:13 $

if isstruct(xstruct) && numel(xstruct.signals) == 0
    xstruct = [];
end

% Compute model update and derivatives
dx = feval(model, t, xstruct, u, 'derivs');
xk1 = feval(model, t, xstruct, u, 'update');

% Eliminate unsupported states
if ~isempty(xk1)
    xk1 = removeUnsupportedStates(slcontrol.Utilities,xk1);
end

% Loop over each of the derivatives and replace the update values in xk1
% with the values of the derivatives.
if ~isempty(dx)
    for ct = 1:length(dx.signals)
        if ~isempty(dx.signals(ct).stateName)
            ind = find(strcmp(dx.signals(ct).stateName,{xk1.signals.stateName}));
        else
            ind = find(strcmp(dx.signals(ct).blockName,{xk1.signals.blockName}));
        end
        for ct2 = 1:numel(ind)
            if strcmp(xk1.signals(ind(ct2)).label,'CSTATE')
                xk1.signals(ind(ct2)).values = dx.signals(ct).values;
                continue
            end
        end
    end
end

% Now loop over the discrete states and compute the xk+1 - xk 
if ~isempty(xk1)
    for ct = 1:length(xstruct.signals)
        if ~strcmp(xk1.signals(ct).label,'CSTATE')
            xk1.signals(ct).values(:) = xk1.signals(ct).values(:) - xstruct.signals(ct).values(:);
        end
    end
end