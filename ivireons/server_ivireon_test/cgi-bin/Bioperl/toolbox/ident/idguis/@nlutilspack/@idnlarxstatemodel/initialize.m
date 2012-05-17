function initialize(this)
%Initialize object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:13 $

model = this.Model;
[ny,nu] = size(model);
this.Algorithm = model.Algorithm;
this.Algorithm.Criterion = 'Trace';

% store some invariants
Delays = getDelayInfo(model);
Nx = sum(Delays); % number of states
cumDel = cumsum(Delays)+1;
CumInd = [1,cumDel(1:end-1)];
ExpUpdateX = false(Nx,1);
ExpUpdateX(CumInd(Delays>0)) = true;

LenCust = zeros(1,ny);
cust = model.CustomRegressors;
if ~iscell(cust)
    cust = {cust};
end

if ~isempty(cust)
    if ny==1
        LenCust = numel(cust);
    else
        for ky = 1:ny
            LenCust(ky) = numel(cust{ky});
        end
    end
end

% standard and custom regressor selector matrices
StdRegGains = state2stdreg(model,Nx,CumInd);
CustRegGains = state2customreg(model,CumInd,Nx,LenCust);

% State update equation matrices (A and B1)
% x(n+1) = Ax(n) + B1*y(n) + B2*u(n)
A = zeros(Nx); 
B = zeros(Nx,ny+nu);
I1 = find(~ExpUpdateX);
A(I1,I1-1) = eye(length(I1));
I2 = find(ExpUpdateX);
B(I2,find(Delays>0)) = eye(length(I2)); 

this.Data.Delays = Delays;
this.Data.Nx = Nx;
this.Data.CumInd = CumInd;
this.Data.LenCust = LenCust;
this.Data.A = A;
this.Data.B = B;
this.Data.StdRegGains = StdRegGains;
this.Data.CustRegGains = CustRegGains;
