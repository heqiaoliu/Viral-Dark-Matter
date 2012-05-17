function this = parameqbwgbwast(varargin)
%PARAMEQBWGBWAST   Construct a PARAMEQBWGBWAST object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:58 $

this = fspecs.parameqbwgbwast;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
