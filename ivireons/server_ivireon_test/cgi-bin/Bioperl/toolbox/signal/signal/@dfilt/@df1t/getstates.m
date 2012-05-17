function S = getstates(Hd,dummy)
%GETSTATES Overloaded get for the States property.

% This should be a private method

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.6 $  $Date: 2004/06/06 16:54:38 $

S = get(Hd, 'HiddenStates');

% [EOF]
