function y = emlmexfilter(b, x)
%EMLMEXFILTER  Filter used in EMLMEXBASICSDEMO.
% Copyright 1984-2009 The MathWorks, Inc.
%#eml
y = filter(b, 1, x);
