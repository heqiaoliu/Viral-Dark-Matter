function nsf = getnoiseshapefilter(this,nnsf,cb)
%GETNOISESHAPEFILTER Get the noiseshapefilter.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:35:50 $

bw = 8; %future enhancement: adjust this
f = [0 cb(2) 1-(1-cb(2))/bw 1];
a = [0 0 1 1];
if mod(nnsf,2) 
    nnsf = nnsf+1;
end
nsf = firpm(nnsf,f,a);

% [EOF]
