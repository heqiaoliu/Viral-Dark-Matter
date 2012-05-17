function this = notchbwap(varargin)
%NOTCHBWAP   Construct a NOTCHBWAP object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:04 $

this = fspecs.notchbwap;

set(this, 'ResponseType', 'Notching Filter');

this.setspecs(varargin{:});


% [EOF]
