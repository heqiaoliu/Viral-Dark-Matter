function d = getobjects(h)
%GETOBJECTS   returns block object.

%   Author(s): G. Taillefer
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:48:49 $

d.Block = h.daobject;
d.PathItem = h.pathitem;

% [EOF]