function [V, truelam, e, jac] = getErrorAndJacobian(sys, data, ...
    parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN  Returns the error and the Jacobian of the IDGREY
%   model at the point specified by parinfo.
%
%   [V,TRUELAM, E, JAC, ERR, JACFLAG] = GETERRORANDJACOBIAN(NLSYS, DATA, ...
%      PARINFO, OPTION, DOJAC, OEFLAG);
%
%   Inputs:
%      SYS     : IDSS object.
%      DATA    : IDDATA object or cell array of data values
%      PARINFO : a structure with fields Value, Minimum and Maximum for a
%                combined list of free parameters and initial states. Use
%                obj2var to generate PARINFO.
%      OPTION  : structure with optimization algorithm properties.
%      DOJAC   : compute Jacobian (true) or not (false).
%
%   Outputs:
%      V       : loss function (Ny-by-Ny matrix).
%      TRUELAM : true innovations based loss, a Ny-by-Ny matrix.
%      E       : a sum(N(k))*Ny-1 matrix with prediction errors, for k = 1,
%                2, ..., Ne. The data for one experiment remains together
%                in a way that errors for individual outputs are vertically
%                stacked beneath each other.
%      JAC     : a sum(N(k))*Ny-by-Nest Jacobian matrix, where Nest is the
%                number of estimated entities (parameters as well as initial
%                states).
%      ERRFLAG : boolean vector with Ne elements; true means that the
%                corresponding prediction error element could not be
%                computed.
%      JACFLAG : boolean Ne-by-Nest matrix, where Nest is the number of
%                estimated entities (parameters as well as initial states).
%                A true entry at (j, k) means that the Jacobian entry for
%                the j:th data experiment and the k:th  parameter failed to
%                be computed and has therefore been replaced by zeros.
%
%   See also PEM.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:19:02 $

%e = []; 
jac = [];

% Failure case handling
% If any parameter value is NaN or Inf, set Eflag, Jflag to true and return.
failedIter = ~all(isfinite(parinfo.Value));

if failedIter
    [V, truelam, e, jac] = LocalHandleFailure(option,parinfo);
    return
end

% par has all parameters - fixed+free+estimated states
par = var2obj(sys, parinfo.Value, option.struc);

struc = option.struc;
dom = struc.domain;
e = [];
if strncmpi(dom,'f',1)
    if ~doJac
        [V, truelam] = gnnew_f(data, par, option, 0);
    else
        [V, truelam, e, jac] = gnnew_f(data, par, option, 0);
    end
else
    % time domain data

    if ~doJac
        [V, truelam] = gnns(data, par, option, 0);
    else
        [V, truelam, e, jac] = gnns(data, par, option, 0);
    end
end

if any(isinf(V(:)))
    [V, truelam, e, jac] = LocalHandleFailure(option, parinfo);
end

e = -e;

%--------------------------------------------------------------------------
function [V, truelam, e, jac ] = LocalHandleFailure(option, parinfo)
% return appropriately sized values for cost, error and jacobian

struc = option.struc;
%nex = struc.Ne;
%Nobs = option.DataSize;
ny = struc.ny;
npar = length(parinfo.Value);
truelam = inf(ny);
V = truelam;
e = -inf(npar+1,1);
jac = zeros(npar+1,npar);


%--------------------------------------------------------------------------



