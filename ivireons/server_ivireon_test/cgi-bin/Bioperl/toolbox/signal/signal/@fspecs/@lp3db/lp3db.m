function this = lp3db(varargin)
%LP3DB   Construct a LP3DB object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/06/16 08:33:14 $

this = fspecs.lp3db;

set(this, 'ResponseType', 'Lowpass with 3-dB Frequency Point');

this.setspecs(varargin{:});

% [EOF]
