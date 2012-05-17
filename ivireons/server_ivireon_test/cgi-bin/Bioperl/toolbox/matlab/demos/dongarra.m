function t = dongarra(n)
%DONGARRA   A benchmark.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/06 16:34:12 $

A = rand(n);
b = rand(n,1);
tic;
[x,r] = linsolve(A,b);
t = toc;
