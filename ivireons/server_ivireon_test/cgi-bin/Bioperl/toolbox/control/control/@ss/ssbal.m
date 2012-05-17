function [sys,t] = ssbal(sys,condt)
%SSBAL  Balancing of state-space model using diagonal similarity.
%
%   [SYS,T] = SSBAL(SYS) uses BALANCE to compute a diagonal similarity 
%   transformation T such that [T*A/T , T*B ; C/T 0] has approximately 
%   equal row and column norms.  
%
%   [SYS,T] = SSBAL(SYS,CONDT) specifies an upper bound CONDT on the 
%   condition number of T.  By default, T is unconstrained (CONDT=Inf).
%
%   For arrays of state-space models with uniform number of states, 
%   SSBAL computes a single transformation T that equalizes the 
%   maximum row and column norms across the entire array.
%
%   See also BALREAL, SS.

%   Authors: P. Gahinet and C. Moler, 4-96
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.19.4.9 $  $Date: 2010/02/08 22:28:53 $
if nargin==1, 
   condt = Inf;
else
   condt = max(1,condt);
end

D = sys.Data_;
nsys = numel(D);
if nsys==0
   % Empty ss array
   t = [];
elseif nsys==1
   % Single model: speed-optimized code
   [D.a,D.b,D.c,D.e,s] = abcbalance(D.a,D.b,D.c,D.e,condt,'noperm','noscale');
   t = diag(1./s);
   if any(s~=1)
      D.StateName = [];
   end
else
   % Model array
   [ny,nu] = iosize(D(1));
   nx = size(sys,'order');
   if length(nx)>1,
       ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','ssbal')
   end
   % Take max. entry magnitude across array
   a = zeros(nx);  b = zeros(nx,nu);  c = zeros(ny,nx);  e = eye(nx);
   for ct=1:nsys
      a = max(a,abs(D(ct).a));
      b = max(b,abs(D(ct).b));
      c = max(c,abs(D(ct).c));
      if ~isempty(D(ct).e)
         e = max(e,abs(D(ct).e));
      end
   end
   % Joint balancing across array
   [~,~,~,~,s] = abcbalance(a,b,c,e,condt,'noperm','noscale');
   si = 1./s;
   % Update data
   if any(s~=1)
      for ct=1:nsys
         D(ct).a = lrscale(D(ct).a,si,s);
         if ~isempty(D(ct).e)
            D(ct).e = lrscale(D(ct).e,si,s);
         end
         D(ct).b = lrscale(D(ct).b,si,[]);
         D(ct).c = lrscale(D(ct).c,[],s);
         D(ct).StateName = [];
      end   
   end
   t = diag(si);
end
sys.Data_ = D;
