function idCloseNLGUIandPlots
% Delete all nonlinear plots and estimation GUI

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:03:35 $

%delete(findall(0,'type','figure','tag','nlsitbfig_nlarxGUI'));
fnlarx = plotpack.getNlarxPlotGUIInstance(false);
if ~isempty(fnlarx) && ishandle(fnlarx)
    close(fnlarx);
end

fnlhw = plotpack.getNlhwPlotGUIInstance(false);
if idIsValidHandle(fnlhw)
    close(fnlhw);
end

% the listener to main gui closing is stored in nlbbpack\nlbbgui 
nlgui = nlutilspack.getNLBBGUIInstance(false);
if idIsValidHandle(nlgui) && isfield(struct(nlgui),'jGuiFrame')
    nlgui.jGuiFrame.doClose;
end

% disable check boxes
Xsum = getIdentGUIFigure;
c1 = findall(Xsum,'style','checkbox','tag','idnlarx');
c2 = findall(Xsum,'style','checkbox','tag','idnlhw');
set([c1,c2],'enable','off');
