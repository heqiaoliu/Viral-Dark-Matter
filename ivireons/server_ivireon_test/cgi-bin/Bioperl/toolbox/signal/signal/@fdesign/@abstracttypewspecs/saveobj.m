function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:17 $

s.class         = class(this);
s.CaptureState  = get(this, 'CapturedState');
s.Specification = get(this, 'Specification');

for indx = 1:length(this.AllSpecs)
    s.AllSpecs{indx} = saveobj(this.AllSpecs(indx));
end

s = setstructfields(s, thissaveobj(this));

% [EOF]
