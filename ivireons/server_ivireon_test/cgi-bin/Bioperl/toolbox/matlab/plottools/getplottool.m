function comp = getplottool (h, name)
% This undocumented function may be removed in a future release.
  
% GETPLOTTOOL  Utility function for creating and obtaining the
% figure tools used for plot editing.
%
% c = GETPLOTTOOL (h, 'figurepalette') returns the Java figure palette.
% c = GETPLOTTOOL (h, 'plotbrowser') returns the Java plot browser.
% c = GETPLOTTOOL (h, 'propertyeditor') returns the Java property editor.
%
% In each case, the component is created if it does not already exist, 
% but it isn't shown by default.
% If you want to both create it and show it, use SHOWPLOTTOOL.

% Copyright 2003-2010 The MathWorks, Inc.


% Called by showplottool, which in turn is called by the component-specific
% functions (propertyeditor, plotbrowser, figurepalette).

comp = [];

if ispref('plottools', 'isdesktop')
    rmpref('plottools', 'isdesktop');
end

if isempty(h) || ~ishandle(h) 
    return
end

% Find the correct group name:
jf = javaGetFigureFrame(h);
if ~isempty(jf)
    groupName = jf.getGroupName;
    dt = jf.getDesktop;
else
    groupName = 'Figures';
    dt=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
end

cmd = lower (name);
switch cmd
    case {'propertyeditor', 'property editor'}
       com.mathworks.page.plottool.PropertyEditor.setHGUsingMATLABClasses(...
           feature('HGUsingMATLABClasses'));
       comp =  com.mathworks.page.plottool.PropertyEditor.addAsDesktopClient(...
           dt,groupName);
    case {'plotbrowser', 'plot browser'}
       comp =  com.mathworks.page.plottool.PlotBrowser.addAsDesktopClient(...
           dt,groupName);
    case {'figurepalette', 'figure palette'}
       comp =  com.mathworks.page.plottool.FigurePalette.addAsDesktopClient(...
           dt,groupName);
    case 'selectionmanager'
        if isempty(h) || ~ishandle(h)
            comp = null;
        else
            comp = createOrGetSelectionManager (h);
        end
end

%-------------------------
function selMgr = createOrGetSelectionManager (h)
if isempty (javaGetFigureFrame(h))
    error('MATLAB:getplottool:FileNotFound', 'Null figure passed to getplottool.');
end
if (~isprop (h, 'SelectionManager'))
    % Temporary workaround:  protect figure from renderer lossage...
    if ~feature('HGUsingMATLABClasses')
        try
            s = opengl ('data');
            if isprop (h, 'WVisual')
                str = 'WVisual';
            else
                str = 'XVisual';
            end
            set (h, str, s.Visual);
        catch %#ok<CTCH>
        end
    end
    localEnablePlotEdit(h);
    selMgr = com.mathworks.page.plottool.SelectionManager (java(handle(h)));
    if (isprop (h, 'SelectionManager'))
        % check again; might have run twice in quick succession
        selMgr = get (handle(h), 'SelectionManager');
        return;
    end
    % TO DO: Remove the following conditions once hg objects use MCOS
    if feature('HGUsingMATLABClasses')
        p = addprop(h,'SelectionManager');
        p.Transient = true;
        p.Hidden = true;
    else
        p = schema.prop (handle(h), 'SelectionManager', 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.Visible = 'off';
    end
    set (handle(h), 'SelectionManager', selMgr);
    drawnow;
else
    selMgr = get (handle(h), 'SelectionManager');
end

%------------------------------------------------------------------------%
function localEnablePlotEdit(hFig)
% Enable plot edit mode only if the plot edit toolbar button is present
% See g327324 

com.mathworks.page.plottool.PropertyEditor.setHGUsingMATLABClasses(...
        feature('HGUsingMATLABClasses'));
behavePlotEdit = hggetbehavior(hFig,'PlotTools','-peek');
if isempty(behavePlotEdit) || behavePlotEdit.ActivatePlotEditOnOpen
    plotedit(hFig,'on');
end

