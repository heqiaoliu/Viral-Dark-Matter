function hm = measure(this, Hd, varargin)
%MEASURE   Measure the filter.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:29:42 $

hm = fdesign.bandstopmeas(Hd, this, varargin{:});

% [EOF]
