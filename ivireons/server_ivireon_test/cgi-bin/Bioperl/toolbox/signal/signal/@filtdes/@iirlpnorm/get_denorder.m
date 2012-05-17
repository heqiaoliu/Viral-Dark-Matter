function M = get_denorder(h,dummy)
%GET_DENORDER Get the denominator order property.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:12:50 $

error(nargchk(2,2,nargin,'struct'));

% Get handle to num den filter order object
g = get(h,'numDenFilterOrderObj');

% Get value
M = get(g,'denOrder');

