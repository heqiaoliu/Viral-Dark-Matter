function boo = isfinite(D)
% Returns TRUE if the model data does not contain NaN's or Inf's.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:18 $
boo = all(isfinite(D.d(:)));