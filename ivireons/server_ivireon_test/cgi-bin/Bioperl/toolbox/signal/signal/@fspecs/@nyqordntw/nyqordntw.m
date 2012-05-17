function this = nyqordntw(varargin)
%NYQORDNTW   Construct a NYQORDNTW object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:16:05 $

this = fspecs.nyqordntw;

this.ResponseType = 'Nyquist with filter order and transition width';

this.setspecs(varargin{:});

% [EOF]
