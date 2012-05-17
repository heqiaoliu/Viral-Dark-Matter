function [h,InfResp] = fresp(D,w)
% Frequency response of SS model.
% InfResp is a logical scalar flagging singularities in the frequency
% response

%	 Author(s): P.Gahinet 
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:02 $

%   Reference:
%   Alan J. Laub, "Efficient Multivariable Frequency Response Computations,"
%   IEEE TAC, AC-26 (April 1981), 407-8.
a = D.a;
b = D.b;
c = D.c;
d = D.d;
e = D.e;
Ts = D.Ts;
nx = size(a,1);

% Form vector s of complex frequencies
s = ltipack.utGetComplexFrequencies(w,D.Ts);

% Scale data to reduce sensitivity to round-off introduced by HESS(A)
if nx>1
   if D.Scaled
      % Just permute
      [a,b,c,e] = localPermute(a,b,c,e);
   else
      % Scale and permute
      [a,b,c,e] = xscale(a,b,c,d,e,Ts,'Permute',true);
   end
end

% Use SSFRESP to evaluate frequency response
[h,InfResp] = ssfresp(a,b,c,d,e,s);

% Factor in delays
Delay = D.Delay;
if any(Delay.Input) || any(Delay.Output) || ~isempty(Delay.Internal)
   % Watch for all zero internal delays...
   h = getDelayResp(D,h,s);
end

%--------------------------------
function [a,b,c,e] = localPermute(a,b,c,e)
% Permute the states to bring out Hessenberg/triangular structure
ne = size(e,1);
if ne>0
   x = abs(a)+abs(e);
else
   x = a;
end
p = triperm('H',x);
a = a(p,p);  b = b(p,:);  c = c(:,p);
if ne>0
   e = e(p,p);
end
