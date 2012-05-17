function D = frd(D,freq,unit)
% No-op except for possible unit change.
% Note: Assumes compatibility of frequency vectors has already been checked.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:08 $
if nargin>1
   D.Frequency = freq;
   D.FreqUnits = unit;
end

   
