function boo = isfinite(D)
% Returns TRUE if model has finite data.

%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:33 $
boo = any(isfinite(D.Response(:)));