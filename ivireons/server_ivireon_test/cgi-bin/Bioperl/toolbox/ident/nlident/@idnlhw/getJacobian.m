function [y,jac] = getJacobian(sys,u0,X0,A,B,C,D)
%GETJACOBIAN Compute model output and Jacobian (dy/du) for given input and
%state values. 
% Note: Jacobian is not calculated w.r.t states, only inputs. The model is
% assumed to be at equlibirum, so the states are a known function of
% inputs. 

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:48:15 $

error(nargchk(2, 7, nargin,'struct'))
doJac = nargout>1;

[ny,nu] = size(sys);
UNL = sys.InputNonlinearity;
YNL = sys.OutputNonlinearity;

if nargin<4
    [A,B,C,D] = ssdata(getlinmod(sys));
end

TFun = C*pinv(eye(size(A))-A)*B + D;

if doJac
    dYNL = zeros(ny);
    dUNL = zeros(nu);
end

% initialize input
ulin   = zeros(nu,1);
for ku = 1:nu
    if ~doJac
        %ulin(ku) = getJacobian(UNL(ku),u0(ku),false);
        ulin(ku) = soevaluate(UNL(ku),u0(ku));
    else
        [ulin(ku), dum, dUNL(ku,ku)] = getJacobian(UNL(ku),u0(ku),false);
    end
end

ylin = C*X0(:)+D*ulin;

% initialize output
y   = zeros(ny,1);
for ky = 1:ny
    if ~doJac
        %y(ky) = getJacobian(YNL(ky),ylin(ky),false);
        y(ky) = soevaluate(YNL(ky),ylin(ky));
    else
        [y(ky), dum, dYNL(ky,ky)] = getJacobian(YNL(ky),ylin(ky),false);
    end
end

if doJac    
    jac = dYNL*TFun*dUNL;
end
