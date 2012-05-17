function S = thissetstates(Hd,S)
%THISSETSTATES Overloaded set for the States property.

% This should be a private method

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:54:22 $

S = validatestatesobj(Hd.filterquantizer, S);
Hd.HiddenStates = S;
