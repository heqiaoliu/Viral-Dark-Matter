function this = lpiir3db(varargin)
%LP3DB   Construct a LPIIR3DB object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:30:48 $

this = fspecs.lpiir3db;

constructor(this,varargin{:});

this.ResponseType = 'Lowpass with 3-dB Frequency Point';

% [EOF]