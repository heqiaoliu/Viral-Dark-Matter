function yf = getFinalValue(D,RespType,varargin)
% Computes steady-state value for a given response type, assuming the 
% model is stable

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:34 $
if D.Ts==0
   r = 0;
else
   r = 1;
end

if strncmpi(RespType,'impulse',1)
   % YF is DC gain of s * H(s) or (z-1) * H(z)
   for ct=1:numel(D.k)
      % Form s * hij(s)
      z = D.z{ct};
      p = D.p{ct};
      idx = find(p==r,1);
      if isempty(idx)
         z = [z;r];
      else
         p(idx,:) = [];
      end
      D.z{ct} = z;
      D.p{ct} = p;
   end
end
         
% Compute final value
yf = dcgain(D);
