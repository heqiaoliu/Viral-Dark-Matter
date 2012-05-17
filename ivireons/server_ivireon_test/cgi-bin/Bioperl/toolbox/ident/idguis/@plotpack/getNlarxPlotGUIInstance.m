function h = getNlarxPlotGUIInstance(createNewIfRequired)
% store and return GUI instance of the nlarx plot window

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:37 $

%todo: generalize this when multiple plot windows are allowed (in CED),
%using WindowID property.

mlock
persistent NLARXModelPlotWindowForGUI;

if nargin<1
    createNewIfRequired = true;
end

if (~isempty(NLARXModelPlotWindowForGUI) && ishandle(NLARXModelPlotWindowForGUI)) || ~createNewIfRequired
    h = NLARXModelPlotWindowForGUI;
    return;
end

h = [];
oldSITB = getIdentGUIFigure;
if isempty(oldSITB) || ~ishandle(oldSITB)
    return;
end

[nlarxmodels,isActive,Colors] = nlutilspack.getAllModels('idnlarx');
Lr = length(nlarxmodels);
if Lr==0 || ~any(isActive)
    return
end

S = handle([]);
% Note: an inactive model cannot be added 
for k = 1:Lr
    if isActive(k)
        thismodel = nlarxmodels{k};
        modelname = get(thismodel,'Name');
        Si = plotpack.nlarxdata(thismodel,modelname,true);
        Si.Color = Colors{k};
        S(end+1) = Si;
    end
end

delete(findall(0,'type','figure','tag','nlsitbfig_nlarxGUI'));
hh = plotpack.idnlarxplot(S,20,true);
hh.showPlot;
set(hh.Figure,'vis','on','ResizeFcn',@(es,ed)hh.executeResizeFcn);
set(hh.Figure,'userdata',hh);

NLARXModelPlotWindowForGUI = hh.Figure;
h = NLARXModelPlotWindowForGUI;
