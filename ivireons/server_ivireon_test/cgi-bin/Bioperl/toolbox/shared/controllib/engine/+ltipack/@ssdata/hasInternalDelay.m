function boo = hasInternalDelay(D)
% Returns T if model has internal delays.

%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:11 $
boo = any(D.Delay.Internal);
