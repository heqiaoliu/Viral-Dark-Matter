function c = evalcost(this)
%EVALCOST   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/10/14 16:24:41 $

r = getratechangefactors(this);
[NMult,NAdd,NStates,MPIS,APIS] = thiscost(this,r(2));
c = fdesign.cost(NMult,NAdd,NStates,MPIS,APIS);


% [EOF]
