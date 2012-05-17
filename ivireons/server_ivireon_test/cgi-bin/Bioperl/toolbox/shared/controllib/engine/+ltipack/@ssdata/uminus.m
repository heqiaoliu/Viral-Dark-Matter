function D = uminus(D)
% Computes -D.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:51 $
nfd = length(D.Delay.Internal);
if nfd==0
   D.c = -D.c;
   D.d = -D.d;
else
   ny = size(D.d,1)-nfd;
   D.c(1:ny,:) = -D.c(1:ny,:); 
   D.d(1:ny,:) = -D.d(1:ny,:); 
end