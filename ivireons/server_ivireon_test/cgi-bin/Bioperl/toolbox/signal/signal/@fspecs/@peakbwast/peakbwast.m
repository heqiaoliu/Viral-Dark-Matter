function this = peakbwast(varargin)
%PEAKBWAST   Construct a PEAKBWAST object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:27 $

this = fspecs.peakbwast;

set(this, 'ResponseType', 'Peaking Filter');

this.setspecs(varargin{:});

% [EOF]
