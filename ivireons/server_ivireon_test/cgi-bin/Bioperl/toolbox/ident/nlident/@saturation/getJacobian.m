function [yhat, jcb, dy_x]= getJacobian(nlobj, regmat, doParJac)
%GETJACOBIAN: Compute parameter and state Jacobians for saturation estimator.
%
%  [yhat, jcb, dy_x]= getJacobian(nlobj, regmat)
%
% doParJac: if false, jcb is not calculated.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:55:27 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,3,ni,'struct'))

if ni<3
    doParJac = true;
end
jcb = [];

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:nonInitNLForJacobian')
end

if isempty(regmat)
    yhat = zeros(size(regmat));
    return
end
if iscell(regmat)
    % Tolerate cellarray data
    regmat = regmat{1};
end

[nobs, regdim] = size(regmat);
if regdim~=1
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','SATURATION')
end

param = nlobj.prvParameters;
interval = param.Interval;

if isempty(interval) % Two sides
    center = param.Center;
    scale = param.Scale;
    alim = center - abs(scale);
    blim = center + abs(scale);
    yhat = min(max(alim, regmat), blim);
    
    if no>1 && doParJac
        deriva = double(regmat<alim);
        derivb = double(regmat>blim);
        jcb = [(deriva+derivb), (sign(scale)*(-deriva+derivb))];
    end
    
    if no>2
        dy_x = double((alim<=regmat)&(regmat<=blim));
    end
    
else % Single side or degenerate
    alim = interval(1);
    blim = interval(2);
    yhat = min(max(alim, regmat), blim);
    
    if no>1 && doParJac
        if isfinite(alim)
            jcb = double(regmat<alim);
        elseif isfinite(blim)
            jcb = double(regmat>blim);
        else
            jcb = zeros(nobs,0);
        end
    end
    
    if no>2
        dy_x = double((alim<=regmat)&(regmat<=blim));
    end
end

% FILE END
