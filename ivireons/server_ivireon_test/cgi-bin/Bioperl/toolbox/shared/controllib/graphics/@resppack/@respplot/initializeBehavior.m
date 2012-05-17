function initializeBehavior(this)
%initializeBehavior  Initializes the behavior for plot edit and propertyeditor
%   for the @respplot instance.

%  Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:37:39 $

hgaxes = getaxes(this.AxesGrid);

% Plot Edit Behavior
bh = hgbehaviorfactory('PlotEdit');
bh.EnableCopy = false;
bh.EnablePaste = false;
bh.EnableMove = false;
bh.EnableDelete = false;
hgaddbehavior(hgaxes(:),bh);

% Behavior for Property Browser
bh = hgbehaviorfactory('PlotTools');
bh.PropEditPanelObject = wrfc.PlotWrapper(this);
bh.PropEditPanelJavaClass= 'com.mathworks.toolbox.shared.controllib.propertyeditors.RespplotPropertyPanel';
hgaddbehavior(hgaxes(:),bh);
end

