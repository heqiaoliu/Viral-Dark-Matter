function h = filterutils(varargin)
%FILTERUTILS Construct a FILTERUTILS object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:25:06 $

h = filtresp.filterutils;

h.Filter = findfilters(varargin{:});

% [EOF]
