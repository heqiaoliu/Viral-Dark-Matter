function S = prependzero(q,S)
%PREPENDZERO   

%   Author(s): V. Pellissier
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:20 $

S = [single(zeros(1,size(S,2)));S];


% [EOF]
