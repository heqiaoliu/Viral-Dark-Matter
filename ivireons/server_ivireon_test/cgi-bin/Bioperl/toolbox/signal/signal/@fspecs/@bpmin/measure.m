function hm = measure(this, Hd, varargin)
%MEASURE   Measure the filter.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:29:41 $

hm = fdesign.bandpassmeas(Hd, this, varargin{:});

% [EOF]
