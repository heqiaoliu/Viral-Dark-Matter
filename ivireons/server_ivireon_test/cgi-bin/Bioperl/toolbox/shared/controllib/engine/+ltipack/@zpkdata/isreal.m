function boo = isreal(D)
% Returns TRUE if model has real data.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:41 $
boo = isreal(D.k);
if boo
   % Further check that all Zs and Ps are complex conjugate
   for ct=1:numel(D.k)
      if ~isconjugate(D.z{ct}) || ~isconjugate(D.p{ct})
         boo = false;
         break
      end
   end
end
