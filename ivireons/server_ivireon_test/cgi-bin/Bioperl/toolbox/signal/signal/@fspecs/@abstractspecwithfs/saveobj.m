function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:09 $

s       = rmfield(get(this), 'ResponseType');
s.Fs    = get(this, 'privfs');
s.class = class(this);

% [EOF]
