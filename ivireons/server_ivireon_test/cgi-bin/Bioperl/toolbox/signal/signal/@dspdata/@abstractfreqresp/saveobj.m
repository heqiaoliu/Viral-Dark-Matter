function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:03 $

s          = get(this);
s.Fs       = get(this, 'privFs');
s.class    = class(this);
s.Metadata = get(this, 'Metadata');
s.CenterDC = get(this, 'CenterDC');

s = setstructfields(s, thissaveobj(this));

% [EOF]
