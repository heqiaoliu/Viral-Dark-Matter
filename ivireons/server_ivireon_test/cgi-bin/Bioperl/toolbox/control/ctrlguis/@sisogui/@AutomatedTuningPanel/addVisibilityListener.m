function addVisibilityListener(this)
%ADDLISTENERS  Installs listeners for automated tuning panel

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/02/06 19:50:28 $

L = [handle.listener(handle(this.getPanel),'AncestorAdded', {@localSetVisibility this true});
     handle.listener(handle(this.getPanel),'AncestorRemoved', {@localSetVisibility this false})];
this.VisibilityListeners = L;

function localSetVisibility(es, ed, this, b)
this.IsVisible = b;
if b
    this.refreshPanel;
end