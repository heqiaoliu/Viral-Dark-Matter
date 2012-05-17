function a = gsqrt(a)
%GSQRT Generalized square root.
%
% <a href="matlab:doc gsqrt">gsqrt</a>(x) returns sqrt(x), supporting built in data type behavior, as
% well as generalized behavior such as element-by-element and recursive
% square root of cell array elements.
%
% Here the square root of a scalar value and a cell array of matrices
% are calculated:
%
%   <a href="matlab:doc gsqrt">gsqrt</a>(9)
%   <a href="matlab:doc gsqrt">gsqrt</a>({[1 2; 3 4],[1 3; 5 2]})
%
%  See also GADD, GSUBTRACT, GMULTIPLY, GDIVIDE.

% Copyright 2010 The MathWorks, Inc.

if iscell(a)
  for i=1:numel(a)
    a{i} = gsqrt(a{i});
  end
else
  a = sqrt(a);
end
