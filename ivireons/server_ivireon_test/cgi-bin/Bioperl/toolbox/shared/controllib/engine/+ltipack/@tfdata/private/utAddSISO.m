function [n,d] = utAddSISO(n1,d1,n2,d2)
% Adds two SISO transfer functions 
%   N1     N2     N1*D2 + N2*D1
%   --  +  --  =  -------------
%   D1     D2         D1*D2

%      Copyright 1986-2003 The MathWorks, Inc.
%      $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:33:18 $

% RE: Assumes (N1,D1) and (N2,D2) have equal length, in which case
%     the resulting N,D always have equal length.
if all(n1==0),
   % N1 = 0
   n = n2; 
   d = d2;
elseif all(n2==0),
   % N2 = 0
   n = n1; 
   d = d1;
else
   % General case
   n = conv(n1,d2) + conv(n2,d1);
   d = conv(d1,d2);
end
% Discard dynamics when N(s) = 0
if all(n==0)
   n = 0;
   d = 1;
end
