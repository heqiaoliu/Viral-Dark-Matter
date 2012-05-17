function this = parameqflfhapast(varargin)
%PARAMEQFLFHAPAST   Construct a PARAMEQFLFHAPAST object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:09 $

this = fspecs.parameqflfhapast;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
