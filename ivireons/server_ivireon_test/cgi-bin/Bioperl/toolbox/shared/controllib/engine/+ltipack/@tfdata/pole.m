function p = pole(D,varargin)
% Computes transfer function poles.
%
% By default, POLE computes the "minimal" set of poles
% (poles of ss(D)).  For TF and ZPK models, 
%    P = POLE(D,'fast')
% will simply concatenate the sets of poles for each 
% I/O pair. This option is faster and enough to assess
% stability.

%   Author(s): P. Gahinet, 4-9-96
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:56 $
[ny,nu] = size(D.num);

if ny==0 || nu==0
   p = zeros(0,1);
elseif ny==1 && nu==1
   % SISO case
   p = roots(D.den{1});
else
   % MIMO case
   num = D.num;
   den = D.den;
   p = zeros(0,1);
   if nargin==1
      % Compute "minimal" set of poles
      [ro,co] = getOrder(D); % row-wise and column-wise orders
      % Number of poles per entry
      npoles = cellfun('length',den)-1;
      for ct=1:ny*nu
         % Zero entries contribute no dynamics
         npoles(ct) = npoles(ct) && any(num{ct});
      end

      if ro<co
         % Compute poles row-wise
         for i=1:ny,
            jdyn = find(npoles(i,:));  % dynamic entries
            if length(jdyn)<2 || ~isequal(den{i,jdyn}),
               for j=jdyn,
                  p = [p ; roots(den{i,j})];
               end
            else
               % Common denominator
               p = [p ; roots(den{i,jdyn(1)})];
            end
         end
      else
         % Compute poles column-wise
         for j=1:nu,
            idyn = find(npoles(:,j))';   % dynamic entries
            if length(idyn)<2 || ~isequal(den{idyn,j})
               for i=idyn,
                  p = [p ; roots(den{i,j})];
               end
            else
               % Common denominator
               p = [p ; roots(den{idyn(1),j})];
            end
         end
      end
   else
      % Just concatenate poles for each I/O ('fast' option)
      for ct=1:ny*nu
         p = [p ; roots(den{ct})];
      end
   end
end
