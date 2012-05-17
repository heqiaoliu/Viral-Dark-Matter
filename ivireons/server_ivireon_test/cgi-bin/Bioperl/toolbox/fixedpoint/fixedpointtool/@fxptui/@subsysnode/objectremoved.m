function objectremoved(h,s,e)
%OBJECTREMOVED

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/17 06:14:21 $

me = fxptui.getexplorer;
if(~strcmp('done', me.status)); return; end

if(~h.isremoveable);return;end
child = e.Child;
child = fxptui.filter(child);
if(isempty(child)); return; end

jfxpblk = h.hchildren.remove(child);
if(isempty(jfxpblk));return;end
fxpblk = handle(jfxpblk);
fxpblk.unpopulate;

%update tree
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('ChildRemovedEvent', h, fxpblk);
%update listview
ed.broadcastEvent('ListChangedEvent', h);

% [EOF]
