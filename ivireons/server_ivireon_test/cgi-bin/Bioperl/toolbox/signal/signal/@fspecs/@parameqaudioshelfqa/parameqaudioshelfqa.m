function this = parameqaudioshelfqa(varargin)
%PARAMEQ   Construct a PARAMEQAUDIOSHELFQA object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:55 $

this = fspecs.parameqaudioshelfqa;

set(this, 'ResponseType', 'Parametric Equalizer');

this.setspecs(varargin{:});

% [EOF]
