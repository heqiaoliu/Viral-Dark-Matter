function this = parameqaudioqa(varargin)
%PARAMEQ   Construct a PARAMEQAUDIOQA object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:49 $

this = fspecs.parameqaudioqa;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
