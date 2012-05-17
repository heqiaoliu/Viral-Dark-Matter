function h = init(h, blk, ds)
%INIT

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:52:59 $

h.daobject = blk;
h.figures = java.util.HashMap;
ed = DAStudio.EventDispatcher;
h.listeners = handle.listener(ed, 'PropertyChangedEvent', @(s,e)locpropertychange(h,s,e));
h.listeners(2) = handle.listener(h.daobject, 'DeleteEvent', @(s,e)destroy(h,ds));
h.listeners(3) = handle.listener(h, findprop(h, 'ProposedDT'), 'PropertyPostSet', @(s,e)setProposedDT(h));

h.addmodelcloselistener(ds);

%--------------------------------------------------------------------------
function locpropertychange(h,s,e)

if(isempty(e) || isempty(e.Source));return;end
% Find the source that corresponds to the block object if the block object
% is valid i.e not an empty handle.
if isprop(h.daobject,'Name')
 src = find(e.Source, '-isa', class(h.daobject), 'Name', h.daobject.Name);
else
 src = [];
end
if(~isempty(src))
    h.propertychange(src, e);
end

% [EOF]
