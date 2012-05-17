function [D,xkeep] = sminreal(D)
% Eliminates structurally non-minimal states and delays

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:41 $
nfd = length(D.Delay.Internal);
if nfd==0
   % No internal delays
   [D.a,D.b,D.c,D.e,xkeep] = smreal(D.a,D.b,D.c,D.e);
   if ~isempty(D.StateName)
      D.StateName = D.StateName(xkeep,:);
   end
   if ~isempty(D.StateUnit)
      D.StateUnit = D.StateUnit(xkeep,:);
   end
else
   [nr,nc] = size(D.d);
   ny = nr-nfd;
   nu = nc-nfd;
   nx = size(D.a,1);
   e = D.e;
   if ~isempty(e)
      e = blkdiag(e,eye(nfd));
   end
   [~,~,~,~,xdkeep] = smreal(...
      [D.a D.b(:,nu+1:nc);D.c(ny+1:nr,:) D.d(ny+1:nr,nu+1:nc)],...
      [D.b ; D.d(ny+1:nr,:)],...
      [D.c , D.d(:,nu+1:nc)] , e);
   if ~all(xdkeep)
      % Form reduced model
      xkeep = find(xdkeep(1:nx));
      dkeep = find(xdkeep(nx+1:nx+nfd))';
      ikeep = [1:nu,nu+dkeep];
      okeep = [1:ny,ny+dkeep];
      D.a = D.a(xkeep,xkeep);
      if ~isempty(e)
         D.e = e(xkeep,xkeep);
      end
      D.b = D.b(xkeep,ikeep);
      D.c = D.c(okeep,xkeep);
      D.d = D.d(okeep,ikeep);
      D.Delay.Internal = D.Delay.Internal(dkeep,:);
      if ~isempty(D.StateName)
         D.StateName = D.StateName(xkeep,:);
      end
      if ~isempty(D.StateUnit)
         D.StateUnit = D.StateUnit(xkeep,:);
      end
   end
   xkeep = xdkeep(1:nx);
end

