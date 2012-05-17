function h = tssource(varargin)

% Copyright 2004 The MathWorks, Inc.

h = tsguis.tssource;
for k=1:floor(nargin/2)
   set(h,varargin{2*k-1},varargin{2*k})
end