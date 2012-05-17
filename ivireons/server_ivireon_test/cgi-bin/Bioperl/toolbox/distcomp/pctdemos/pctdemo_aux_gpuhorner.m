function y = pctdemo_aux_gpuhorner(x)
%PCTDEMO_AUX_GPUHORNER - series expansion for exp(x) using Horner's rule

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $   $Date: 2010/05/03 16:06:24 $

y = 1 + x.*(1 + x.*((1 + x.*((1 + ...
        x.*((1 + x.*((1 + x.*((1 + x.*((1 + ...
        x.*((1 + x./9)./8))./7))./6))./5))./4))./3))./2));
end
