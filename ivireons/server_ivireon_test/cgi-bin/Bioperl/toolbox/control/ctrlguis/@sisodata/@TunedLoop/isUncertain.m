function boo = isUncertain(this)
% Checks if the TunedLoop is uncertain (e.g. an array)

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/04/11 20:29:51 $
boo = numel(this.TunedLFT.IC)>1;
   