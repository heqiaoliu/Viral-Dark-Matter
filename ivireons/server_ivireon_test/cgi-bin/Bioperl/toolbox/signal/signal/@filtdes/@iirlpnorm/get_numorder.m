function N = get_numorder(h,dummy)
%GET_NUMORDER Get the numerator order property.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:12:51 $

error(nargchk(2,2,nargin,'struct'));

% Get handle to num den filter order object
g = get(h,'numDenFilterOrderObj');

% Get value
N = get(g,'numOrder');

