function b = hasUnappliedChanges(this,b,s1,s2,fxpt1,fxpt2)
%HASUNAPPLIEDCHANGES Shut off warning about unapplied changes when the
%dialog is in its default state (i.e. b is false)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/04 16:31:32 $

oldSpecs = get(this, 'LastAppliedState');
actRespType = s1.ResponseType;
s1 = rmfield(s1,'ResponseType');
s2 = rmfield(s2,'ResponseType');

b = true;
if strcmp(actRespType,oldSpecs.ResponseType) && ...
        isequal(s1,s2) && isequal(fxpt1,fxpt2),
    b = false;
end


% [EOF]
