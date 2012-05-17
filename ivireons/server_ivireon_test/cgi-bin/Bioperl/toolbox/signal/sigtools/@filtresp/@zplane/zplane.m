function h = zplane(varargin)
%ZPLANE Construct a zplane object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/13 00:21:03 $

h = filtresp.zplane;

h.super_construct(varargin{:});
h.FilterUtils = filtresp.filterutils(varargin{:});
addprops(h, h.FilterUtils);

set(h, 'Name', 'Pole/Zero Plot');

% [EOF]
