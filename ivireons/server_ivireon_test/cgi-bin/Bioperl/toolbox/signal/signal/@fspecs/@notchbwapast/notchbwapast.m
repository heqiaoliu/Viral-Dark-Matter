function this = notchbwapast(varargin)
%NOTCHBWAPAST   Construct a NOTCHBWAPAST object.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:08 $

this = fspecs.notchbwapast;

set(this, 'ResponseType', 'Notching Filter');

this.setspecs(varargin{:});


% [EOF]
