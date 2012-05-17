function this = parameqbwgbwap(varargin)
%PARAMEQBWGBWAP   Construct a PARAMEQBWGBWAP object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:52 $

this = fspecs.parameqbwgbwap;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
