function this = hbordastop(varargin)
%HBORDASTOP   Construct a HBORDASTOP object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:13:43 $

this = fspecs.hbordastop;

this.ResponseType = 'Halfband with filter order and stopband attenuation';

this.setspecs(varargin{:});

% [EOF]
