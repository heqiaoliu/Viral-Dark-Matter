function boo = isreal(D)
% Returns TRUE if model has real data.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:35 $
boo = false;  % always assume complex for FRD's (no way to tell)