function [a,b,c,d,e] = compreal(num,den)
%COMPREAL  Companion realization of SIMO transfer functions
%
%   [A,B,C,D,E] = COMPREAL(NUM,DEN) computes a state-space realization
%   (A,B,C,D,E) of the SIMO transfer function NUM/DEN with common 
%   denominator DEN (a row vector).  If L is the maximum length of
%   the numerator and denominator polynomials, NUM should be a
%   PxL matrix if there are P outputs, and DEN should be a vector of
%   length L.  The E matrix is empty (identity) if there are at least 
%   as many poles than zeros and is singular otherwise.
%
%   See also TF/SS.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.12.4.3 $  $Date: 2006/11/17 13:26:03 $
e = [];
[p,r] = size(num);
if r==1 || norm(num,1)==0
   % Pure gain or zero numerator
   a = [];
   b = zeros(0,1);
   c = zeros(p,0);
   d = num(:,1)/den(:,1);
   
else
   % Locate and normalize leading denominator coefficient
   idx = find(den~=0,1);
   den1 = den(idx);
   den = den(idx+1:r)/den1;
   num = num/den1;
   % Build companion realization (in controller form)
   ld = length(den);
   if idx==1
      % Proper case
      a = [-den ; eye(ld-1,ld)];
      b = eye(ld,1);
      d = num(:,1);
      c = num(:,2:r) - d * den;
      kE = 0;
   else
      % Improper case
      ld1 = min(1,ld);
      a = blkdiag(eye(idx),diag(ones(ld1,ld-1),-1));
      a(idx+ld1,idx+1:idx+ld) = -den;
      b = zeros(idx+ld,1);
      if ld>0
         b(idx+1) = 1;
      else
         b(idx) = -1;
      end
      c = num;
      d = zeros(p,1);
      e = diag([zeros(idx,1);ones(ld,1)]);
      stride = idx+ld+1;
      e(stride:stride:(idx-1+ld1)*stride) = 1;
      kE = idx;
   end
   
   % Balancing
   [a,b,c,e] = LocalBalance(a,b,c,e,kE);
end

%----------------------- Local Functions --------------------

function [a,b,c,e] = LocalBalance(a,b,c,e,kE)
% Specialized balancing for companion form
% kE = number of zeros on the diagonal of E
nx = size(a,1);

% Balance portion of A matrix associated with denominator
if nx<kE+2
   rs = zeros(0,1);
else
   [junk,junk,x] = balance(a(kE+1:nx,kE+1:nx),'noperm');
   % Incremental scaling factors (decreasing)
   rs = diag(x,-1);
end

% Protect against scaling anomalies when last 
% denominator entries are small or zero
% [num,den] = pade(1,20);  x = num-den;  x(1) = 1;
% [a,b,c,d] = compreal(den,x);
igap = find(rs(2:end)<min(1,1e-3*rs(1:end-1)));
if ~isempty(igap)
   rsmin = min(1,rs(igap(1)));
   rs = max(rs,rsmin);
end
   
% In improper case, balance portion of C associated 
% with first kE+1 states
if kE>0
   if kE<nx
      kE = kE+1;
   end
   vc = max(abs(c(:,1:kE)),[],1);
   vc = vc/vc(1);
   [junk,junk,x] = balance([vc; eye(kE-1,kE)],'noperm');
   rs = [diag(x,-1) ; rs];
end
      
% Form the scaling vector and balance
s = cumprod([1;rs]);
a = lrscale(a,s,1./s);
b = lrscale(b,s,[]);
c = lrscale(c,[],1./s);
if ~isempty(e)
   e = lrscale(e,s,1./s);
end

% Equalize the norms of b and c
cnorm = norm(c,1);
bnorm = norm(b,1);
if cnorm>0
   sbc = pow2(round(log2(cnorm/bnorm)/2));  % sqrt(cnorm/bnorm)
   c = c / sbc;
   b = b * sbc;
end