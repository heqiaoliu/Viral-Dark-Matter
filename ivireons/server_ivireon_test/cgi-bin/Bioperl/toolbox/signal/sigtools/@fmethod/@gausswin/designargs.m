function args = designargs(this, hspecs)
%DESIGNARGS Return the arguments for the design method
%   OUT = DESIGNARGS(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:42 $

N = getFilterOrder(hspecs);

args = {N, hspecs.BT, hspecs.SamplesPerSymbol};

% [EOF]
