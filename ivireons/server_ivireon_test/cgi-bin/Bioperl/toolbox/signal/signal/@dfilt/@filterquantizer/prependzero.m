function S = prependzero(q,S)
%PREPENDZERO   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:57:50 $

S = [zeros(1,size(S,2));S];


% [EOF]
