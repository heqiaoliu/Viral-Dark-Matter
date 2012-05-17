function y = extraBitsSelected(ntx)
% True if DTX enabled and extra bits selected
%  for either BAFL or BAIL

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:09 $

y = extraLSBBitsSelected(ntx.hBitAllocationDialog) || ...
    extraMSBBitsSelected(ntx.hBitAllocationDialog);
