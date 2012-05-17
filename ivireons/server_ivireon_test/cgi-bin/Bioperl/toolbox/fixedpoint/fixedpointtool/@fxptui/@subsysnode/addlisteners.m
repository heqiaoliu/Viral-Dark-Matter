function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/27 20:11:55 $

h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)firepropertychange(h));
h.listeners(2) = handle.listener(h.daobject, findprop(h.daobject, 'MinMaxOverflowLogging'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
h.listeners(3) = handle.listener(h.daobject, findprop(h.daobject, 'DataTypeOverride'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
h.listeners(4) = handle.listener(h.daobject, 'ObjectChildAdded', @(s,e)objectadded(h,s,e));
h.listeners(5) = handle.listener(h.daobject, 'ObjectChildRemoved', @(s,e)objectremoved(h,s,e));

%--------------------------------------------------------------------------
function locpropertychange(ed,h)
% Update the display icons in the tree hierarchy.

h.firehierarchychanged;
% [EOF]
