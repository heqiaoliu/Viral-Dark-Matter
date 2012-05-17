function D = uminus(D)
% Computes -D.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:08 $
for ct=1:prod(size(D.num))
   D.num{ct} = -D.num{ct};
end