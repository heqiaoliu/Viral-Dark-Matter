function [nn, hh] = histplot(this)

% Copyright 2004 The MathWorks, Inc.

y = double(this);
y = log2(abs(y(:)));
n = hist(y);
h = gca;
set(h,'xdir','reverse');
if nargout>0
  nn = n;
  hh = h;
end
