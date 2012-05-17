function showPlot(this)
% show plot of type 'input', 'output' or 'linear'.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/08/01 12:23:03 $

type = this.Current.Block;

if ~isempty(this.MainPanels)
    set(this.MainPanels,'vis','off');
    str = this.getTag; %get tag of "current" panel
    cp = findobj(this.MainPanels,'type','uipanel','Tag',str);
    if ~isempty(cp)
        set(cp,'vis','on')
        switch lower(type)
            case {'input','output'}
                ax = this.Current.AxesHandles.(lower(type));
            otherwise
                LinType = this.Current.LinearPlotTypeComboValue;
                LinTypeStr = {'step','bode','impulse','pzmap'};
                ax = this.Current.AxesHandles.(LinTypeStr{LinType});
        end
        set(this.Figure,'CurrentAxes',ax);
        return;
    end
end

wb = [];
if this.isGUI
    wb = waitbar(0.5,'Opening Hammerstein-Wiener models plot window...');
end

% generate afresh
if strcmpi(type,'input')
    this.generateNLPlot('input');
elseif strcmpi(type,'output')
    this.generateNLPlot('output');
elseif strcmpi(type,'linear')
    this.generateLinearModelPlot;
end

if this.isGUI
    waitbar(1,wb,'Done.')
end

%this.refreshIOCombos;
this.executeResizeFcn;
localSetGridZoomPanModes(this);

close(wb)

%--------------------------------------------------------------------------
function localSetGridZoomPanModes(this)
% set zoom, pan and zoom modes based upon the file menu selections in
% the GUI

if ~this.isGUI
   return;
end

allaxes = this.getAllAxes;
%allaxes = findall(this.MainPanels,'type','axes');
ui = findall(this.Figure,'type','uimenu','label','&Style','visible','on');

onoff = get(findobj(get(ui,'Children'),'label','&Grid'),'checked');
set(allaxes,'xgrid',onoff,'ygrid',onoff,'zgrid',onoff);

onoff = get(findobj(get(ui,'Children'),'label','&Zoom'),'checked');
zoom(this.Figure,onoff);

onoff = get(findobj(get(ui,'Children'),'label','&Pan'),'checked');
pan(this.Figure,onoff);
