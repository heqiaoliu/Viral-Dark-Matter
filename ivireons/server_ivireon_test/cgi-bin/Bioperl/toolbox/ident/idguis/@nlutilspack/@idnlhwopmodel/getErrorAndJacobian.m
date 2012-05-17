function [V, truelam, e, jac] = getErrorAndJacobian(this, ytarget, ...
    parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN Compute error and jacobian matrices for the operating
%point search problem

% Written by: Rajiv Singh
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/03/09 19:14:22 $

jac = []; 

% ytarget: target y values; meaningful only for fixed outputs
ytarget = ytarget{1}(:); 
sys = this.Model;
[ny,nu] = size(sys);
Nx = this.Data.Nx;
UNL = sys.InputNonlinearity;

fixed = this.OperPoint.Output.Known(:);
free = ~fixed;
lbfree = this.OperPoint.Output.Min(free); lbfree = lbfree(:);
ubfree = this.OperPoint.Output.Max(free); ubfree = ubfree(:);

e = zeros(ny,1);
newu = this.var2obj(parinfo.Value);
if ~doJac
    ysim = LocalGetOutput;
else
    [ysim, ysimjac] =  LocalGetOutput;
end
ysim = ysim(:);

e(fixed) = ysim(fixed)-ytarget(fixed);
%e(free)  = yold(free)-ysim(free);
if any(free)
    e(free)  = max([ysim(free)-ubfree,lbfree-ysim(free),...
        zeros(sum(free),1)],[],2);
end

V = norm(e,2)^2/ny;
truelam = V;

if ~doJac
    return
end

% compute Jacobian
jac = ysimjac;

% Change sign of Jacobian for free outputs that are smaller than lower
% bound
if any(free)
    Lbnd = ysim(free)<lbfree;
    jac(Lbnd) = -jac(Lbnd);

    % Set derivative to zero for outputs that are free and in bounds
    InBnd = false(ny,1);
    InBnd(free) = (ysim(free)>lbfree) & (ysim(free)<ubfree);
    jac(InBnd,:) = 0;
end

% Remove columns corresponding to fixed inputs
jac(:,this.OperPoint.Input.Known) = [];

%-------------------------------------------------------------------------
    function [y0,jac0] = LocalGetOutput
        % Compute equilibrium output
        
        A = this.Data.A;
        B = this.Data.B;
        C = this.Data.C;
        D = this.Data.D;
        AIB = this.Data.AIB;
        
        if doJac
            jac0 = zeros(ny, ny+nu);
        end

        uin = newu(:);
        ulin = zeros(nu,1);
        for ku = 1:nu
            %ulin(ku) = getJacobian(UNL(ku),uin(ku),false);
            ulin(ku) = soevaluate(UNL(ku),uin(ku));
        end
        X0 = AIB*ulin;

        % compute model output and jacobian (w.r.t. input)
        if ~doJac
            y0 = getJacobian(sys,uin,X0,A,B,C,D);
        else
            % compute jacobian of model outputs w.r.t its inputs
            [y0, jac0] = getJacobian(sys,uin,X0,A,B,C,D);
        end

    end %function LocalGetOutput
end %function getErrorAndJacobian
