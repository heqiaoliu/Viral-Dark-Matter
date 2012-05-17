function this = psrcosord(varargin)
%PSRCOSORD Construct a PSRCOSORD object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:05 $

this = fspecs.psrcosord;

this.ResponseType = 'Raised cosine pulse shaping with filter order';

this.FilterOrder = 48;  % (SamplesPerSymbol * NumberOfSymbols = 8*6)

this.setspecs(varargin{:});

% [EOF]
