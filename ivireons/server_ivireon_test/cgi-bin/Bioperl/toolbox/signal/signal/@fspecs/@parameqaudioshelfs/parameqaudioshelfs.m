function this = parameqaudioshelfs(varargin)
%PARAMEQ   Construct a PARAMEQAUDIOSHELFS object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:58 $

this = fspecs.parameqaudioshelfs;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
