function this = hbordntw(varargin)
%HBORDNTW   Construct a HBORDNTW object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:13:52 $

this = fspecs.hbordntw;

this.ResponseType = 'Halfband with filter order and transition width';

this.setspecs(varargin{:});

% [EOF]
