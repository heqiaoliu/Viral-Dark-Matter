function h = getNlhwPlotGUIInstance(createNewIfRequired)
% store and return GUI instance of the nlhw plot window

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:38 $

%todo: generalize this when multiple plot windows are allowed (in CED),
%using WindowID property (later).

mlock
persistent NLHWModelPlotWindowForGUI;

if nargin<1
    createNewIfRequired = true;
end

if (~isempty(NLHWModelPlotWindowForGUI) && ishandle(NLHWModelPlotWindowForGUI)) || ~createNewIfRequired
    h = NLHWModelPlotWindowForGUI;
    return;
end

h = [];
oldSITB = getIdentGUIFigure;
if isempty(oldSITB) || ~ishandle(oldSITB)
    return;
end

[nlhwmodels,isActive,Colors] = nlutilspack.getAllModels('idnlhw');
Lr = length(nlhwmodels);
if Lr==0 || ~any(isActive)
    return
end

S = handle([]);
% Note: an inactive model cannot be added 
for k = 1:Lr
    if isActive(k)
        thismodel = nlhwmodels{k};
        modelname = get(thismodel,'Name');
        Si = plotpack.nlhwdata(thismodel,modelname,true);
        Si.Color = Colors{k};
        S(end+1) = Si;
    end
end

delete(findall(0,'type','figure','tag','nlsitbfig_nlhwGUI'));
hh = plotpack.idnlhwplot(S,100,true);
hh.showPlot;
set(hh.Figure,'vis','on','ResizeFcn',@(es,ed)hh.executeResizeFcn);
set(hh.Figure,'userdata',hh);
%assignin('base','this',hh); %for testing

NLHWModelPlotWindowForGUI = hh.Figure;
h = NLHWModelPlotWindowForGUI;
