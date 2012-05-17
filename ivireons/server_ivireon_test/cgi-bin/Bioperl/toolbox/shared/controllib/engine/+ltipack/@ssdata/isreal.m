function boo = isreal(D)
% Returns TRUE if model has real data.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:20 $
boo = isreal(D.a) && isreal(D.b) && isreal(D.c) && ...
   isreal(D.d) && isreal(D.e);