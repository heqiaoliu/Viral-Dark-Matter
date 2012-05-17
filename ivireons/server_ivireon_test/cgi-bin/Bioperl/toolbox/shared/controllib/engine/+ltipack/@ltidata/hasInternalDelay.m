function boo = hasInternalDelay(D)
% Returns T if model has internal delays.

%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:16 $

% Treal I/O delays as internal for consistency with state space
boo = any(D.Delay.IO(:));
