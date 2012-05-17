function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:06:48 $

s       = get(this);
s.class = class(this);

