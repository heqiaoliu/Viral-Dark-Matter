function [a,b,c,e,s,p] = aebalance(a,b,c,e,varargin)
%AEBALANCE  Balances (A,E) pair.
%
%   [A,B,C,E,S,P] = AEBALANCE(A,B,C,E) balances the (A,E) pair
%   and returns the balanced system (T\A*T,T\E*T,T\B,C*T) together 
%   with the scaling S and permutation P such that T(:,P) = diag(S).  
%  
%   [A,B,C,E,S,P] = AEBALANCE(A,B,C,E,Option1,Option2,...) specifies 
%   additional options as strings:
%     'perm'      Enables state permutation (default)
%     'noperm'    Prevents state permutation during balancing
%     'safebal'   Performs regularized row/column balancing
%                 (default)
%     'fullbal'   Performs full row/column balancing (equivalent 
%                 to BALANCE)
%
%   LOW-LEVEL UTILITY.

%   Authors: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2006/12/27 20:34:36 $

% RE: Expects A,B,C,E to be matrices 2D arrays

% Get dimensions
nx = size(a,1);
ne = size(e,1);

% Quick exit when no state
if nx==0,
   s = ones(0,1); 
   p = zeros(0,1);
   return
end

% Form matrix M = |A|+|E| to be scaled
if ne==0,
   mae = abs(a);
else
   anorm = norm(a-diag(diag(a)),1);
   enorm = norm(e-diag(diag(e)),1);
   if anorm>0 && enorm>0
      mae = enorm*abs(a)+anorm*abs(e);
   else
      mae = abs(a)+abs(e);
   end
end

% Perform scaling
[s,p] = mscale(mae,varargin{:}); 

% Apply scaling and permutation to (A,E)
is = 1./s;
a(p,p) = lrscale(a,is,s);
if ne,
   e(p,p) = lrscale(e,is,s);
end

% Scale B,C if nonempty
if ~(isempty(b) && isempty(c))
   % B or C is nonempty
   mb = max(abs(b),[],2);
   mc = max(abs(c),[],1);
   if norm(mb,1)>0 && norm(mc,1)>0
      % Equalize ||B|| and ||C||
      bnorm = max(lrscale(mb,is,[]));
      cnorm = max(lrscale(mc,[],s));
      sbc = pow2(round(log2(cnorm/bnorm)/2));
      s = s / sbc;
      is = is * sbc;
   end
   b(p,:) = lrscale(b,is,[]);
   c(:,p) = lrscale(c,[],s);
end
