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
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:51 $
[ny,nu] = size(D.k);

if ny==0 || nu==0
   p = zeros(0,1);
elseif ny==1 && nu==1
   % SISO case
   p = D.p{1};
else
   % MIMO case
   if nargin==1
      % Compute "minimal" set of poles
      [ro,co] = getOrder(D); % row-wise and column-wise orders
      % Number of poles per entry
      npoles = cellfun('length',D.p) .* (D.k~=0);
      
      p = zeros(0,1);
      if ro<co
         % Compute poles row-wise
         for i=1:ny,
            jdyn = find(npoles(i,:)>0);  % dynamic entries
            if length(jdyn)<2 || ~isequal(D.p{i,jdyn}),
               p = cat(1,p,D.p{i,jdyn});
            else
               % Common denominator
               p = [p ; D.p{i,jdyn(1)}]; %#ok<AGROW>
            end
         end
      else
         % Compute poles column-wise
         for j=1:nu,
            idyn = find(npoles(:,j)>0);   % dynamic entries
            if length(idyn)<2 || ~isequal(D.p{idyn,j})
               p = cat(1,p,D.p{idyn,j});
            else
               % Common denominator
               p = [p ; D.p{idyn(1),j}]; %#ok<AGROW>
            end
         end
      end
   else
      % Just concatenate poles for each I/O ('fast' option)
      p = cat(1,D.p{:});
   end
end
