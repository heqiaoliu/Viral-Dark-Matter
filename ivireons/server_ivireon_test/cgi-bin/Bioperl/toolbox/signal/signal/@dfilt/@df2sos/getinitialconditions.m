function ic = getinitialconditions(Hd)
%GETINITIALCONDITIONS Get the initial conditions

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/14 04:01:32 $

s    = double(Hd.States);
nsts  = size(Hd.sosMatrix,1)*2;
nchan = prod(size(s))/nsts;
ic    = reshape(s,nsts,nchan);

% [EOF]
