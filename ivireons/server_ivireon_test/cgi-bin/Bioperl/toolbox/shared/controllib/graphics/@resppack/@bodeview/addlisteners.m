function addlisteners(this)
%  ADDLISTENERS  Installs additional listeners for @bodeview class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:23 $

% Initialization. First install generic listeners
this.generic_listeners;

% Add @timeplot specific listeners
L = [handle.listener(this, 'ObjectBeingDestroyed', @LocalCleanUp)];
set(L, 'CallbackTarget', this);
this.Listeners = [this.Listeners ; L];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose:  Clean up when @bodeview (@respview) object is destroyed.
% ----------------------------------------------------------------------------%
function LocalCleanUp(this, eventdata)
% Delete hg lines
delete(this.MagCurves(ishandle(this.MagCurves)))
delete(this.PhaseCurves(ishandle(this.PhaseCurves)))
