function nlobj = setpar(nlobj, par)
%SETPAR sets parameters of nonlinearity estimator
%   Uses: 
%       1. Create a fully populated estimator for Jacobian calculation,
%       such as when called from Simulink for linearization.
%       2. Set or transfer parameters for simulation, independent of
%       estimation.

% Written by: Rajiv Singh
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 14:49:03 $


nlobj.prvParameters = par;
