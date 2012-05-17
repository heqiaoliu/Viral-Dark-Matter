function var = obj2var(this, option)
%OBJ2VAR  Serializes estimated parameter/state object data into estimation
%   variable data for optimizers.

%   Written by: Rajiv Singh
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:27 $


N = option.DataSize;
Ne = length(N);
Nx = this.Data.Nx;
x0 = this.Data.X0guess;
if isvector(x0) && Ne>1
    x0 = repmat(x0(:),1,Ne);
end

par = x0(:);

% Return free parameter information structure.
var = struct('Value', par,  ...
             'Minimum', -inf(size(par)), ...
             'Maximum', inf(size(par))  ...
            );
   