function this = loadobj(s)
%LOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/04/09 18:57:12 $

% Call the static method 'load'.  This is done so that external callers
% (dspfdesign) can load the object without having to create one first.
this = feval([s.class '.load'], s);


% [EOF]
