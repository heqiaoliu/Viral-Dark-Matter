function [z,p,k] = utSS2ZPK(a,b,c,d,e,Ts,p)
% Computes ZPK data of SISO model for which poles are 
% already known.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:48:22 $

% Scale A,B,C (see taccuracy:lvlTwo_Plus:1 for motivation)
[a,b,c,e] = xscale(a,b,c,d,e,Ts,'Warn',false);

% Eliminate pole/zero cancellations at infinity
% Note: No structurally nonminimal states here
[a,b,c,e,rkE] = minreal_inf(a,b,c,e);

% Compute zeros
if rkE<size(a,1)
   % May be improper
   if length(p)>rkE
      % Cannot account for all poles P. Compute ZPK data from scratch
      [z,p,k] = zpk_minreal_inf(a,b,c,d,e,Ts);
   else
      % Compute matching zero data
      [z,~,k] = zpk_minreal_inf(a,b,c,d,e,Ts,p);
   end   
else
   % Just compute zeros
   [z,k] = sszero(a,b,c,d,e,Ts);
end   

