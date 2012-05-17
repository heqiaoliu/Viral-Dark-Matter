function args = designargs(this, hspecs) %#ok<INUSL>
%DESIGNARGS Return the arguments for the design method

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:33 $

args = {hspecs.Astop, hspecs.RolloffFactor, hspecs.SamplesPerSymbol};

% [EOF]
