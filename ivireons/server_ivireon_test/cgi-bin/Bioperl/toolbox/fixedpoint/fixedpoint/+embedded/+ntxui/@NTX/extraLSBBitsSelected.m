function y = extraLSBBitsSelected(ntx)
% True if DTX enabled and extra bits selected for Frac Length
% Property is active in all modes except Specify Precision (4)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:10 $

y = extraLSBBitsSelected(ntx.hBitAllocationDialog);
