function replaceparameter(hObj, oldtag, varargin)
%REPLACEPARAMETER Allows subclasses to change a parameter object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:20:51 $

error(nargchk(5, 7, nargin,'struct'));

oldPrm = getparameter(hObj, oldtag);
allPrm = get(hObj, 'Parameters');

set(hObj, 'Parameters', setdiff(allPrm, oldPrm));

createparameter(hObj, varargin{:});

% [EOF]
