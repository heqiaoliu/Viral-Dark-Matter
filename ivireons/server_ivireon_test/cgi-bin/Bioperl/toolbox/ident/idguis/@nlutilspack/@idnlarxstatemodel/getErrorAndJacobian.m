function [V, truelam, e, jac] = getErrorAndJacobian(this, data, parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN Compute error and jacobiam matrices for the initial
%state vector estimation problem for idnlarx models.

% Written by: Rajiv Singh
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/03/09 19:14:21 $

%e = []; jac = []; V = Inf; truelam = V;

sys = this.Model;
[N,ny,nu,Ne] = size(data);
Ncaps = sum(N);
Nx = this.Data.Nx;
LenCust = this.Data.LenCust;
Delays = this.Data.Delays;
StdRegGains = this.Data.StdRegGains;
CustRegGains = this.Data.CustRegGains;
foc = lower(this.Data.Focus(1));
A = this.Data.A;
B = this.Data.B;
B1 = B(:,1:ny);
u = pvget(data,'InputData');
y = pvget(data,'OutputData');

Wt = option.Weighting;
sqrWt = 1;

yorig = y;
if ~isequal(Wt,eye(ny))
    was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
    sqrWt = sqrtm(Wt);
    warning(was)

    for i = 1:Ne
        y{i} = y{i}*sqrWt;
    end
end

ymeas = cell2mat(cellfun(@(x)x(:),y,'uniform',0)');
%ymeas_ = cell2mat(y');

% map multi-exp vector to a Ne-column matrix
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
    
    ysim = [ysim; ysimi(:)]; % fold multi-output data into one column
    %ysim_= [ysim_; ysimi]; 
    if doJac
       jac = blkdiag(jac, reshape(shiftdim(jaci,2),N(i)*ny,Nx));
    end
end

% Error vector
e = ysim - ymeas;

% cost
V = norm(e)^2/Ncaps;
truelam = V;

%-------------------------------------------------------------------------
    function [y0,jacX] = LocalGetOutput(X0i,Ni,ui)
        % Compute equilibrium output
        
        y0 = zeros(Ni,ny);
        if doJac
            jacX = zeros(ny,Nx,Ni);
        end
        
        Xnew = X0i;
        dxnew_dx = eye(Nx);
        for k = 1:Ni
            % compute response and may be Jacobian
            if ~doJac
                yk = getJacobian(sys,ui(k,:),Xnew,Delays,LenCust,...
                    StdRegGains,CustRegGains);
            else
                [yk,dy_dx] = getJacobian(sys,ui(k,:),Xnew,Delays,LenCust,...
                    StdRegGains,CustRegGains);
                
                % Remove input contribution from Jacobian
                dy_dx = dy_dx(:,1:Nx);
                
                % Post-multiply by dX(k)/dX(1) to obtain Jacobian for k'th
                % samples
                jacX(:,:,k) = sqrWt'*dy_dx*dxnew_dx;
                
                % Calculate dX(k+1)/dX(1)
                dxnew_dx = (A+B1*dy_dx)*dxnew_dx;
            end
            
            % update Xnew = X(k+1)
            if strcmp(foc,'p')
                y_ = yorig{i}(k,:); %measured data
            else
                y_ = yk;
            end
            
            Xnew = A*Xnew+B*[y_(:); ui(k,:)'];
            
            % add weighting for needs of error matrix 
            yk = yk(:)'*sqrWt;
            y0(k,:) = yk;
           
            
        end        
    
    end %function LocalGetOutput
end %function getErrorAndJacobian
