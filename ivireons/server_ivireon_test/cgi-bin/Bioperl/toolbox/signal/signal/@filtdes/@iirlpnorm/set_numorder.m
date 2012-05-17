function dummy = set_numorder(h,N)
%SET_NUMORDER Set the filter order property

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:12:53 $

error(nargchk(2,2,nargin,'struct'));

% Get handle to numDenFilterOrder object
g = get(h,'numDenFilterOrderObj');

% Set value
set(g,'numOrder',N);

% Return a dummy value for now
dummy = 20;
