function this = pssqrtrcosnsym(varargin)
%PSRCOSNSYM Construct a PSRCOSNSYM object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:03:26 $

this = fspecs.pssqrtrcosnsym;

this.ResponseType = 'Square root raised cosine pulse shaping with filter length in symbols';

this.NumberOfSymbols = 6;

this.setspecs(varargin{:});

% [EOF]
