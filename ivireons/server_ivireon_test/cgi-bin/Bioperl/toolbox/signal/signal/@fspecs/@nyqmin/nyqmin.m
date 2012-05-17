function this = nyqmin(varargin)
%NYQMIN   Construct a NYQMIN object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:15:41 $

this = fspecs.nyqmin;

this.ResponseType = 'Minimum-order nyquist';

this.setspecs(varargin{:});

% [EOF]
