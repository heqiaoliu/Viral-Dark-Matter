function h = init(h, blk, ds)
%INIT

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/09/13 06:53:09 $

h.daobject = blk;
h.figures = java.util.HashMap;
h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)propertychange(h,s,e));
h.listeners(2) = handle.listener(h.daobject, 'DeleteEvent', @(s,e)destroy(h,ds));
h.listeners(3) = handle.listener(h, findprop(h, 'ProposedDT'), 'PropertyPostSet', @(s,e)setProposedDT(h));


% [EOF]
