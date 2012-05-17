function [NMult,NAdd,NStates,MPIS,APIS] = thiscost(this,M)
%THISCOST   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:25:08 $

NMult = nmult(this,true,true);
NAdd = nadd(this);
MPIS = NMult/M;
APIS = NAdd/M; 
NStates = nstates(this);

% [EOF]
