function pickcolor(dlg, colormap, type)

% Copyright 2005 The MathWorks, Inc.

    oldcolor = colormap.getColor(type);
    newcolor = uisetcolor(oldcolor, [type ' Color']);
    colormap.setColor(type, newcolor);
    dlg.enableApplyButton(true);
    dlg.refresh;
    