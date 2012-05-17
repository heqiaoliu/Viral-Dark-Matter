function this = parameqflfh(varargin)
%PARAMEQ   Construct a PARAMEQ object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:02 $

this = fspecs.parameqflfh;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
