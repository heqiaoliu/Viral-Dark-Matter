function this = hbmin(varargin)
%HBMIN   Construct a HBMIN object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:13:22 $

this = fspecs.hbmin;

this.ResponseType = 'Minimum-order halfband';

this.setspecs(varargin{:});

% [EOF]
