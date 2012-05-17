function Hflat = thisflatcascade(this,Hflat)
%THISFLATCASCADE Add singletons to the flat list of filters Hflat 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:26:14 $

N = nstages(this);
for i=1:N,
    Hflat = thisflatcascade(this.Stage(i),Hflat);
end
