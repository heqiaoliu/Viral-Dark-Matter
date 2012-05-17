function valout = evalScalarParam(this,valin)
% EVALSCALARPARAM  Evaluate a string parameter in the base MATLAB
% Workspace.  The value must be scalar.
%
 
% Author(s): John W. Glass 14-Sep-2007
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:28:29 $

if ischar(valin)
    try
        valout = evalin('base',valin);
    catch EvalException
        throwAsCaller(EvalException)
    end
else
    valout = valin;
end

if ~isreal(valout) || ~isscalar(valout) || isinf(valout) || isnan(valout)
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidScalarRealValue',valin)
end
    