function [V, truelam, e, jac] = getErrorAndJacobian(this, data, ...
    parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN Compute error and jacobiam matrices for the operating
%point search problem of idnlarx models.

% Written by: Rajiv Singh
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/03/09 19:14:19 $

jac = []; 

% ytarget: initial guess of output values
sys = this.Model;
[ny,nu] = size(sys);
Nx = this.Data.Nx;
% lb = this.OperPoint.Output.Min(:); 
% ub = this.OperPoint.Output.Max(:); 
LenCust = this.Data.LenCust;
Delays = this.Data.Delays;

newuy = this.var2obj(parinfo.Value);
yold = newuy(1:ny); yold = yold(:);
if ~doJac
    ysim = LocalGetOutput;
else
    [ysim, ysimjac] =  LocalGetOutput;
end
ysim = ysim(:);

%{
e(fixed) = ysim(fixed)-ytarget(fixed);
e(free)  = ysim(free)-yold(free);
e(free)  = max([ysim(free)-ubfree,lbfree-ysim(free),zeros(sum(free),1)],[],2);
%}

e  = ysim - yold; % error = ||y-f(y)||

V = norm(e,2)^2/ny;
truelam = V;

if ~doJac
    return
end

% compute Jacobian
jac = ysimjac-[eye(ny),zeros(ny,nu)];

% Remove columns corresponding to fixed inputs
jac(:,ny+find(this.OperPoint.Input.Known)) = [];

%-------------------------------------------------------------------------
    function [y0,jac0] = LocalGetOutput
        % Compute equilibrium output
        
        if doJac
            jac0 = zeros(ny, ny+nu);
        end
        
        yin = newuy(1:ny); yin = yin(:);
        uin = newuy(ny+1:end); uin = uin(:);

        % Compute model states
        X = constdata2states(sys,nu,ny,Nx,uin,yin,Delays);

        % compute model output and jacobian (w.r.t. all states)
        if ~doJac
            y0 = getJacobian(sys,uin,X,Delays,LenCust);
        else
            [y0,bigJac] = getJacobian(sys,uin,X,Delays,LenCust);
            
            % Add Jacobian entries that correspond to the same channel
            for i = 1:ny
                jaci = zeros(1,ny+nu);
                offset = 0;
                for k = 1:nu+ny
                    if Delays(k)>0
                        jaci(k) = sum(bigJac(i,1+offset:Delays(k)+offset));
                        offset  = offset+Delays(k);
                    end
                end
                jac0(i,:) = jaci;
            end % for each output
        end

    end %function LocalGetOutput
end %function getErrorAndJacobian
