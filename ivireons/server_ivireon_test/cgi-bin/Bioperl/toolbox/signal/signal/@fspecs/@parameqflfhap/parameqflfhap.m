function this = parameqflfhap(varargin)
%PARAMEQFLFHAP   Construct a PARAMEQFLFHAP object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:06 $

this = fspecs.parameqflfhap;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
