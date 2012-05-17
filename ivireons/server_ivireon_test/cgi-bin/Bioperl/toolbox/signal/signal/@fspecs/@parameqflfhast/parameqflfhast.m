function this = parameqastflfh(varargin)
%PARAMEQFLFHAST   Construct a PARAMEQFLFHAST object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:12 $

this = fspecs.parameqflfhast;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
