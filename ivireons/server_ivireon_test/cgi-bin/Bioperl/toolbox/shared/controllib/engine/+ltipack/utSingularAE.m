function boo = utSingularAE(a,e)
% Returns true if (A,E) is a singular pencil.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:06 $
n = size(a,1);

% Reduce E to diagonal
s = diag(e);
if ~isequal(e,diag(s))
   [u,e,v] = svd(e);
   s = diag(e);
   a = u'*a*v;
end

% Reduce E to [I 0;0 0]
isZero = (s==0);
if ~all(s(~isZero)==1)
   s(isZero) = 1;
   s(~isZero) = 1./sqrt(s(~isZero));
   a = lrscale(a,s,s);
end

% Extract (A,B,C,D) for associated transfer function
r = sum(isZero);
nx = n-r;
dh = a(nx+1:n,nx+1:n);
bh = a(1:nx,nx+1:n);
ch = a(nx+1:n,1:nx);
ah = a(1:nx,1:nx);

% Check for singularity
tol = ltipack.getTolerance('rank');
if r==0
   boo = false;
elseif r==1
   % SISO case: check if all moments are zero
   boo = (dh==0);
   if boo
      beta = bh;
      for ct=1:nx
         % Check if moments are all zero
         if abs(ch*beta)>tol*abs(ch)*abs(beta)
            boo = false;  break;
         end
         % Beware of case beta=0 within rounding errors
         refmag = abs(ah) * abs(beta);
         beta = ah * beta;
         beta(abs(beta)<=tol*refmag) = 0;
      end
   end     
else
   % MIMO case: compute normal rank of C*(sI-A)\B+D
   boo = (normrank(ah,bh,ch,dh,[],tol)<r);
end
   


