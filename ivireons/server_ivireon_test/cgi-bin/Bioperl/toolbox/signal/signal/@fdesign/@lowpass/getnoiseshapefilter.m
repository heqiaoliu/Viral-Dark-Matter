function nsf = getnoiseshapefilter(this,nnsf,cb)
%GETNOISESHAPEFILTER Get the noiseshapefilter.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:35:57 $

bw = 8; %future enhancement: adjust this
f = [0 cb(1)/bw cb(1) 1];
a = [1 1 0 0];
nsf = firpm(nnsf,f,a);

% [EOF]
