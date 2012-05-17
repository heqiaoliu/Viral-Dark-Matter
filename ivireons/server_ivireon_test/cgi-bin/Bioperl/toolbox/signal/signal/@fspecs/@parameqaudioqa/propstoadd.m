function p = propstoadd(this)
%PROPSTOADD   Return the properties to add to the parent object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:50 $

p = fieldnames(this);
p = {p{1:4},p{6},p{8},p{7},p{5}};

p(1) = []; % All but the responsetype.

% [EOF]
