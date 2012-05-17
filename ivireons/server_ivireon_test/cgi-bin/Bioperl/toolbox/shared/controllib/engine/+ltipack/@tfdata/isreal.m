function boo = isreal(D)
% Returns TRUE if model has real data.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:46 $

% Note: Need to normalize leading coefficient of NUM or DEN
% so that multiplying NUM and DEN by a complex number does not modify the
% outcome. This ensures consistency with the ISREAL(ZPK(SYS)) and
% ISREAL(SS(SYS))
num = D.num;
den = D.den;
boo = all(cellfun('isreal',num(:))) && all(cellfun('isreal',den(:)));
if ~boo
   % Double check that num/den is not reducible to something real
   for ct=1:numel(den)
      nct = num{ct};
      dct = den{ct};
      if dct(1)==0
         alpha = nct(1);
      else
         alpha = dct(1);
      end
      % Normalize leading coefficient
      nct = nct/alpha;
      dct = dct/alpha;
      if ~(isreal(nct) && isreal(dct))
         return
      end
   end
   % Return true if normalized num,den pairs were all real
   boo = true;
end
         
