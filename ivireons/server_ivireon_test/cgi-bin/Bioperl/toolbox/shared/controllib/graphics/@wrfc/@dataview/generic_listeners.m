function generic_listeners(this)
%GENERIC_LISTENERS  Generic listeners for @dataview class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:01 $
this.Listeners = handle.listener(this, 'ObjectBeingDestroyed', @LocalCleanUp);

% ----------------------------------------------------------------------------%
% Purpose: Clean up associated HG objects.
% ----------------------------------------------------------------------------%
function LocalCleanUp(this, eventdata)
deleteview(this.View(ishandle(this.View)))


