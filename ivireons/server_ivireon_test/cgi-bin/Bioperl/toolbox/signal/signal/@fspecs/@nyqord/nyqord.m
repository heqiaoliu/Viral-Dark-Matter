function this = nyqord(varargin)
%NYQORD   Construct a NYQORD object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:15:48 $

this = fspecs.nyqord;

this.ResponseType = 'Nyquist with filter order';

this.setspecs(varargin{:});

% [EOF]
