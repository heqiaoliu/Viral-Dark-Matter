function hm = measure(this, Hd, varargin)
%MEASURE   Measure the filter.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:32:43 $

hm = fdesign.highpassmeas(Hd, this, varargin{:});

% [EOF]
