function h = getNLBBGUIInstance(createNewIfRequired,show,loc)
% store and return instance of the nonlinear estimation GUI.
% loc: location to place the GUI at (java.awt.Point object);

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/31 06:13:29 $

%todo: generalize this when multiple plot windows are allowed (in CED),
%using WindowID property.

mlock
persistent NNBBEstimationObjectForGUI;

if nargin<3
    loc = [];
end

if nargin<2
    show = false;
end

if nargin<1
    createNewIfRequired = true;
end

h = NNBBEstimationObjectForGUI;
if (~isempty(h) && ishandle(h))
    if show
        javaMethodEDT('toFront',h.jGuiFrame);
    end
    return;
end

% a valid handle does not exist
h = [];
oldSITB = getIdentGUIFigure;
if isempty(oldSITB) || ~ishandle(oldSITB)
    % do not create a new one if GUI is not open
    return;
end

if createNewIfRequired
    NNBBEstimationObjectForGUI = nlbbpack.nlbbgui;
    h = NNBBEstimationObjectForGUI;
    
    % show the GUI
    if ~isempty(loc)
        h.jGuiFrame.setLocation(loc);
    end
    h.jGuiFrame.setVisible(true); %setVisible is an event-thread method
end

%h1 = handle(h.jGuiFrame,'callbackproperties');
%handle.listener(h1,'WindowClosed', @(es,ed)LocalNlbbguiClosingCallback(this));
