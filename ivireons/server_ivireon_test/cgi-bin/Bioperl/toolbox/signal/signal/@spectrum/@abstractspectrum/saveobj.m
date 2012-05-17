function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/06/13 15:29:46 $

s = rmfield(get(this), 'EstimationMethod');

s.class = class(this);

s = setstructfields(s,thissaveobj(this,s));

% [EOF]
