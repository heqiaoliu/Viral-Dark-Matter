function disable(this)
%DISABLE  Disable the extension.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/02 13:12:46 $

hGUI = this.Application.getGUI;
if isRendered(hGUI)
    cleanup(this, hGUI.hVisParent);
end

% If the application is holding this as the current visual, remove it.  We
% need to perform this check in case we are switching between visuals.  The
% extension manager does not guarantee order here.  In that case the Visual
% property might already be pointing to the new visual and we don't need to
% do anything, but because we support no visual, we need to be able to set
% the visual property on the application to [].
if this.Application.Visual == this
    this.Application.Visual = [];
end

% [EOF]
