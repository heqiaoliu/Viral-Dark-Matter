function [f, g, a] = gaussunit(x)
%GAUSSUNIT customnet unit function example
%
%[f, g, a] = GAUSSUNIT(x)
%
% x: unit function variable
% f: unit function value
% g: df/dx
% a: unit active range (g(x) is significantly non zero in the interval [-a a])
%
% The unit function must be "vectorized": for a vector or matrix x, the output
% arguments f and g must have the same size as x, computed element-by-element.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:51:50 $

% Author(s): Qinghua Zhang

f =  exp(-x.*x);  

if nargout>1
  g = - 2*x .* f;
  a = 0.2;
end

% FILE END
