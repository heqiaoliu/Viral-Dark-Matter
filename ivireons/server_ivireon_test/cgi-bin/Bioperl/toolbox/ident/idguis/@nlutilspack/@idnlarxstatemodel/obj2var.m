function var = obj2var(this, option)
%OBJ2VAR  Serializes estimated parameter/state object data into estimation
%   variable data for optimizers.

%   Written by: Rajiv Singh
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:45:52 $

N = option.DataSize;
Ne = length(N);
yMin = option.yMin;
yMax = option.yMax;
yMean = (yMax+yMin)/2;
yRange = yMax-yMin;
Nx = this.Data.Nx;

lb = [];
ub = [];
for i = 1:Ne
    lb = [lb; repmat(yMean(i)-10*yRange(i),Nx,1)];
    ub = [ub; repmat(yMean(i)+10*yRange(i),Nx,1)];
end

x0 = this.Data.X0guess;
if isempty(x0)
    x0 = repmat(yMean,Nx,1);
end

if isvector(x0) && Ne>1
    x0 = repmat(x0(:),1,Ne);
end

par = x0(:);

% Return free parameter information structure.
var = struct('Value', par,  ...
             'Minimum', lb, ...
             'Maximum', ub  ...
            );
   