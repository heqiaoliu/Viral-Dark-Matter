function this = hbord(varargin)
%HBORD   Construct a HBORD object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:13:35 $

this = fspecs.hbord;

this.ResponseType = 'Halfband with filter order';

this.setspecs(varargin{:});

% [EOF]
