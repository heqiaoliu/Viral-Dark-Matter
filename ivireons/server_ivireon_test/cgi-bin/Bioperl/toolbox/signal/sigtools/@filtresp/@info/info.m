function h = info(varargin)
%INFO Constructor
%   INFO(FILTOBJ) Construct an info object using FILTOBJ

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2004/12/26 22:18:48 $

h = filtresp.info;

h.super_construct(varargin{:});
h.FilterUtils = filtresp.filterutils(varargin{:});
findclass(findpackage('dspopts'), 'sosview'); % g 227896
addprops(h, h.FilterUtils);

set(h, 'Name', 'Filter Information')

% [EOF]
