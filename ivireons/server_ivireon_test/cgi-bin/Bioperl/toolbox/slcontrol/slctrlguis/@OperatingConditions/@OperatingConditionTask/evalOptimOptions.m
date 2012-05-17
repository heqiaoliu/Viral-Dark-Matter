function options = evalOptimOptions(this)
% EVALOPTIMOPTIONS 
%
 
% Author(s): John W. Glass 13-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:43 $

% Evaluate the optimization parameters
options = copy(this.Options);

optimoptions = options.OptimizationOptions;
optimoptions.DiffMaxChange = LocalCheckValidScalar(optimoptions.DiffMaxChange);
optimoptions.DiffMinChange = LocalCheckValidScalar(optimoptions.DiffMinChange);
optimoptions.MaxFunEvals = LocalCheckValidScalar(optimoptions.MaxFunEvals);
optimoptions.MaxIter = LocalCheckValidScalar(optimoptions.MaxIter);
optimoptions.TolFun = LocalCheckValidScalar(optimoptions.TolFun);
optimoptions.TolX = LocalCheckValidScalar(optimoptions.TolX);
optimoptions.TolCon = LocalCheckValidScalar(optimoptions.TolCon);

% Store the updated structure
options.OptimizationOptions = optimoptions;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCheckValidScalar Check for valid workspace scalar variable
function value = LocalCheckValidScalar(str)

if isempty(str)
    % Use optimizer defaults
    value = [];
else
    try
        value = evalScalarParam(linutil,str);
    catch Ex
        errmsg = ltipack.utStripErrorHeader(Ex.message);
        ctrlMsgUtils.error('Slcontrol:operpointtask:InvalidOptimizationOption',errmsg);
    end
end
