function nlobj = setpar(nlobj, par)
%SETPAR sets parameters of nonlinearity estimator
%   Uses: 
%       1. Create a fully populated estimator for Jacobian calculation,
%       such as when called from Simulink for linearization.
%       2. Set or transfer parameters for simulation, independent of
%       estimation.

% Written by: Rajiv Singh
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:20:38 $

if ~isfield(par,'RegressorMinMax')
    par.RegressorMinMax = nlobj.Parameters.RegressorMinMax;
end

par1 = par;
rmFields = {};
if isfield(par,'NumberOfUnits')
    rmFields{end+1} = 'NumberOfUnits';
    nlobj.NumberOfUnits = par.NumberOfUnits;
end
if isfield(par,'Threshold')
    rmFields{end+1} = 'Threshold';
    nlobj.Options.Threshold = par.Threshold;
end
if ~isempty(rmFields)
    par1 = rmfield(par,rmFields);
end

nlobj.Parameters = par1;
