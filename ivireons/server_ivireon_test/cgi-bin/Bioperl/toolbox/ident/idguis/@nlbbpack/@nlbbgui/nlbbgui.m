function this = nlbbgui
% Create a brand new nonlinear black box estimation GUI.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:29 $

% check if ident gui is open, error out otherwise
c = getIdentGUIFigure;
if isempty(c) || ~ishandle(c)
    ctrlMsgUtils.error('Ident:idguis:identGUInotOpen')
end

this = nlbbpack.nlbbgui;

% todo: make this a singleton?
this.initialize;

