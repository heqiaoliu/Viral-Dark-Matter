function createBrushToolBtn(toolbtn,eventData)

% Add building splash screen menu. This function will be called once 
% by uitoolfactory in figuretools.
uimenu('Label','Building...','parent',toolbtn, 'HandleVisibility','off');
set(toolbtn,'CreateFcn','')