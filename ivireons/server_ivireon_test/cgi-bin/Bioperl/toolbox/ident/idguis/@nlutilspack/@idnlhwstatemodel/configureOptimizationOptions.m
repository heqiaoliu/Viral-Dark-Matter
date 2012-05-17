function option = configureOptimizationOptions(this, algo, option, Estimator)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.
%   OPTION: struct used by estimator containing algorithm properties.
%   ALGO: Algorithm property of this.Model

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2009/03/09 19:14:23 $

option = this.commonConfigureOptions(algo, option, Estimator);

% Compute and store extended observability matrix
% This is Jacobian of linear output w.r.t X0.
Data = Estimator.Data;
if isa(Data,'iddata')
    Nmax = max(option.DataSize);
    Nx = this.Data.Nx;
    ny = size(this.Model,1);
    A = this.Data.A;
    C = this.Data.C;

    ObsvN = zeros(Nmax*ny,Nx);
    ObsvN(1:ny,:) = C;
    for k = 1:Nmax-1
        ObsvN(k*ny+1:(k+1)*ny,:) = ObsvN((k-1)*ny+1:k*ny,:)*A;
    end
    option.ObsvN = ObsvN;
end
