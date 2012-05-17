function this = pssqrtrcosord(varargin)
%PSRCOSORD Construct a PSSQRTRCOSORD object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:03:30 $

this = fspecs.pssqrtrcosord;

this.ResponseType = 'Square root raised cosine pulse shaping with filter order';

this.FilterOrder = 48;  % (SamplesPerSymbol * NumberOfSymbols = 8*6)

this.setspecs(varargin{:});

% [EOF]
