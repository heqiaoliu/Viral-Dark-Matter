function xkeep = iosmreal(a,b,c,e)
%SMREAL  Compute structurally minimal realization for
%        each entry of a MIMO transfer function.
%
%   XKEEP = IOSMREAL(A,B,C,E) eliminates states that 
%   are not connected to the input or output for each 
%   I/O pair of the MIMO transfer function
%      H(s) = C * inv(sE-A) * B
%   XKEEP is a 3D logical array such that XKEEP(:,i,j)
%   flags the structurally minimal states for the (i,j) 
%   I/O pair.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2006/06/20 20:03:33 $
nu = size(b,2);
ny = size(c,1);
nx = size(a,1);
xkeep = false(nx,ny,nu);
if nx>0
   % Adapted version of SMREAL to derive s-minimal realizations
   % of all hij(s) in ny+nu steps
   if islogical(a)
      AdjMat = sparse(a);
   else
      AdjMat = sparse(a~=0);
   end
   if nargin==4 && ~isempty(e)
      AdjMat = AdjMat | sparse(e~=0);
   end

   % Identify structurally controllable states
   for j=1:nu
      xc = sparse(b(:,j)~=0);  % x(1)
      dx = xc;      % dx(k) = x(k)-x(k-1)
      while any(dx),
         Adx = any(AdjMat(:,dx),2);  % A dx(k) + E dx(k)
         dx = Adx & ~xc;        % dx(k+1)
         xc = xc | Adx;         % xc(k+1)
      end
      xcf = full(xc);
      xkeep(:,:,j) = xcf(:,ones(1,ny));
   end
   
   % Identify structurally observable states
   for i=1:ny
      xo = sparse(c(i,:)~=0);   
      dx = xo;
      while any(dx),
         Adx = any(AdjMat(dx,:),1);
         dx = Adx & ~xo;
         xo = xo | Adx;
      end
      xof = full(xo).';
      xkeep(:,i,:) = xkeep(:,i,:) & xof(:,1,ones(1,nu));
   end
end