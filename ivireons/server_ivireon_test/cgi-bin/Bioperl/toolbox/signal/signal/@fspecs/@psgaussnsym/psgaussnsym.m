function this = psgaussnsym(varargin)
%PSRCOSNSYM Construct a PSRCOSNSYM object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:03:04 $

this = fspecs.psgaussnsym;

this.ResponseType = 'Gaussian pulse shaping with filter length in symbols';

this.NumberOfSymbols = 6;

this.setspecs(varargin{:});

% [EOF]
