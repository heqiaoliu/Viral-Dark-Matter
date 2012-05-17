function Hflat = flattencascade(this)
%FLATTENCASCADE Remove cascades of cascades

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:26:13 $

N = nstages(this);
Hflat = [];
for i=1:N,
    Hflat = thisflatcascade(this.Stage(i),Hflat);
end
Hflat = cascade(Hflat(:));
