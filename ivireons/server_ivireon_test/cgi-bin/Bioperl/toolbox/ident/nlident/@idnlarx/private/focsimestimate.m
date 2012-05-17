function [sys, ei, nv, covmat] = focsimestimate(sys, data)
%FOCSIMESTIMATE estimates IDNLARX model by minimizing simulation error (Focus='Simulation').
%
%  [sys, ei, nv, covmat] = focsimestimate(sys, data)
%
%  Support MIMO IDNLARX models.
%  CustomRegressors involving output are not allowed.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:53:23 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(2, 2, ni,'struct'))

[ny, nu] = size(sys);
ei = [];
nv = [];
covmat = [];

% Fast exit if non recurrent model
na = pvget(sys, 'na');
if all(all(na==0)) && ~anyoutputcustomreg(pvget(sys, 'CustomRegressors'), ny)
    ctrlMsgUtils.warning('Ident:estimation:nonRecurrentModelFocSim')
    return
end

% Store data center and radius in data.UserData
% Note: these values must be computed once on the entire data, not on MaxSize blocks.
if size(data, 'ne')>1
    yalldata = cell2mat(data.y(:));
else
    yalldata = data.y;
end
[minval, maxval] = robustdatabounds(yalldata);
center = 0.5*(minval + maxval);
radius = 0.5*(maxval - minval);
data.UserData = struct('Center', center, 'Radius', radius);
clear yalldata

% Make use of the optim engine
Estimator = createEstimator(sys,data);
OptimInfo = minimize(Estimator);

% update the model with the set of new values for states and parameters
sys = updatemodel(sys,OptimInfo,Estimator);

% Note: this must be at the end of this function, since the other calls to pvset
% may change the value of the Estimated property.
sys = pvset(sys, 'Estimated', 1);

% FILE END

