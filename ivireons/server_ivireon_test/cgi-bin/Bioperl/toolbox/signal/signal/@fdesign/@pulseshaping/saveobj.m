function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:34 $

s.class         = class(this);
s.Response      = get(this, 'Response');
s.PulseShape    = get(this, 'PulseShape');
s.PulseShapeObj = saveobj(this.PulseShapeObj);
s.version       = '9a';

% [EOF]
