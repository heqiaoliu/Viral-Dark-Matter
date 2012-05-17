function this = notchqapast(varargin)
%NOTCHQAPAST   Construct a NOTCHQAPAST object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:23 $

this = fspecs.notchqapast;

set(this, 'ResponseType', 'Notching Filter');

this.setspecs(varargin{:});

% [EOF]
