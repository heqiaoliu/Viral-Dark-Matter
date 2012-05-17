function [D,NeedsPadding] = utZeroPad(D,RightPad)
% Pads the numerators or denominators of Transfer Functions
% with zeros to make NUM{i,j} and DEN{i,j} of equal length.  
% The zeros are added to the right if RIGHTPAD is true and 
% to the left otherwise.
%
% Also removes the extra leading zeros in NUM{i,j} and 
% DEN{i,j} (while keeping them of equal length)

%      Author: P. Gahinet, 5-1-96
%   Copyright 1986-2008 The MathWorks, Inc.
%      $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:15 $
NeedsPadding = false;
num = D.num;
den = D.den;
if RightPad
   for k = 1:numel(num)
      nk = num{k};
      dk = den{k};
      % Pad zeros to the right to make num/den of equal length
      lgap = length(dk) - length(nk);
      if lgap~=0
         nk = [nk , zeros(1,lgap)];
         dk = [dk , zeros(1,-lgap)];
      end
      % Remove leading and trailing zeros appearing in both num and den
      % (delete leading zeros to ensure that num(1) or den(1) is always nonzero)
      ind = find(nk~=0 | dk~=0);
      num{k} = nk(ind(1):ind(end));
      den{k} = dk(ind(1):ind(end));
   end
else
   for k = 1:numel(num)
      nk = num{k};
      dk = den{k};
      % Pad zeros to the left to make num/den of equal length
      lgap = length(dk) - length(nk);
      if lgap~=0
         NeedsPadding = true;
         nk = [zeros(1,lgap) , nk];
         dk = [zeros(1,-lgap) , dk];
      end
      % Remove leading zeros appearing in both num and den
      if nk(1)==0 && dk(1)==0
         ld = length(dk);
         ind = find(nk~=0 | dk~=0);
         nk = nk(ind(1):ld);
         dk = dk(ind(1):ld);
      end
      num{k} = nk;
      den{k} = dk;
   end
end
D.num = num;
D.den = den;

