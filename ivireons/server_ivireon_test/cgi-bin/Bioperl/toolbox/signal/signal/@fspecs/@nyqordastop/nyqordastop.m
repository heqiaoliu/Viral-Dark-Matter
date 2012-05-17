function this = nyqordastop(varargin)
%NYQORDASTOP   Construct a NYQORDASTOP object.
%   NYQORDASTOP 

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:15:57 $

this = fspecs.nyqordastop;

this.ResponseType = 'Nyquist with filter order and stopband attenuation';

this.setspecs(varargin{:});

% [EOF]
