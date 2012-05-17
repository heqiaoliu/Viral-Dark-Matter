function hm = measure(this, hfilter, varargin)
%MEASURE   Measure the filter.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:34:30 $

hm = fdesign.lowpassmeas(hfilter, this, varargin{:});

% [EOF]
