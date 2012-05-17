function y = extraMSBBitsSelected(ntx)
% True if DTX enabled and extra bits selected for Int Length
% Property is active in all modes except Maximum Magnitude (3)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:11 $

y = extraMSBBitsSelected(ntx.hBitAllocationDialog);
