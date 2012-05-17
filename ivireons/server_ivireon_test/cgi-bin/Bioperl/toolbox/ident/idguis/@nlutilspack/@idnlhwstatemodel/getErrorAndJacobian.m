function [V, truelam, e, jac] = getErrorAndJacobian(this, data, parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN Compute error and jacobiam matrices for the initial
%state vector estimation problem for idnlhw models.

% Written by: Rajiv Singh
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/03/09 19:14:24 $

sys = this.Model;
[N,ny,nu,Ne] = size(data);
Ncaps = sum(N);
Nx = this.Data.Nx;

A = this.Data.A;
B = this.Data.B;
C = this.Data.C;
D = this.Data.D;
ObsvN = option.ObsvN;
YNL = sys.OutputNonlinearity;

u = pvget(data,'InputData');
y = pvget(data,'OutputData');

Wt = option.Weighting;
was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
sqrWt = sqrtm(Wt);
warning(was)

if ~isequal(Wt,eye(ny))
    for i = 1:Ne
        y{i} = y{i}*sqrWt;
    end
end

ymeas = cell2mat(cellfun(@(x)x(:),y,'uniform',0)');

% Map multi-exp vector to a Ne-column matrix
X0mat = this.var2obj(parinfo.Value,option); 

jac = [];
ysim = zeros(0,1);
for i = 1:Ne
    X0i = X0mat(:,i);
    if ~doJac
        ysimi = LocalGetOutput(X0i,N(i),u{i});
    else
        [ysimi, jaci] =  LocalGetOutput(X0i,N(i),u{i});
    end
    
    ysim = [ysim; ysimi(:)]; %#ok<AGROW> % fold multi-output data into one column
    
    if doJac
       jac = blkdiag(jac, jaci);
    end
end

% Error vector
e = ysim - ymeas;

% cost
V = norm(e)^2/Ncaps;
truelam = V;

%-------------------------------------------------------------------------
   function [y0,jac0] = LocalGetOutput(X0i,Ni,ui)
        % Compute response and jacobian for given input (ui) and initial
        % state (X0i) values; Ni is number of data samples in ui
     
        y0 = zeros(Ni,ny);
        if doJac
            dy_ylin = zeros(Ni,ny);
            jac0 = zeros(Ni*ny,Nx);
            tempjac = jac0;
        end
        
        % Note: ui has been pre-compensated for input nonlinearity
        Xnew = ltitr(A,B,ui,X0i');
        ylin = C*Xnew'+D*ui';
        ylin = ylin';
        
        for k = 1:ny
            % Compute model output and jacobian (w.r.t. input)
            if ~doJac
                y0(:,k) = soevaluate(YNL(k),ylin(:,k));
            else
                % Compute jacobian of model outputs w.r.t its inputs
                [y0(:,k), dum, dy_ylin(:,k)] = getJacobian(YNL(k),ylin(:,k),false);
            end
        end
        
        y0 = y0*sqrWt;
        
        if doJac
            for j = 1:Ni
                tempjac(ny*(j-1)+1:ny*j,:) = diag(dy_ylin(j,:))*sqrWt*ObsvN(ny*(j-1)+1:ny*j,:);
            end
            
            for k = 1:ny
                jac0(Ni*(k-1)+1:Ni*k,:) =  tempjac(k:ny:end,:);
            end
        end

    end %function LocalGetOutput
end %function getErrorAndJacobian
