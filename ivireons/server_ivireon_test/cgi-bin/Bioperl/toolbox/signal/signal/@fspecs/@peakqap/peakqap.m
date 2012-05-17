function this = peakqap(varargin)
%PEAKQAP   Construct a PEAKQAP object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:34 $

this = fspecs.peakqap;

set(this, 'ResponseType', 'Peaking Filter');

this.setspecs(varargin{:});
% [EOF]
