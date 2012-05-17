function refreshPanel(this)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:41:04 $

ComboBoxes = this.Handles.TablePanel.getPlotCombos;

set(this.Handles.Listeners,'Enabled','off');
set(this.Handles.TableListener,'Enabled','off');

PlotTypes = this.PlotTypes;

for ct = 1:length(PlotTypes)
    idx = find(strcmpi(PlotTypes{ct},this.PlotTag));
    awtinvoke(ComboBoxes(ct),'setSelectedIndex(I)',idx-1);
end
    
this.Handles.TablePanel.UpdatePlotContentTable(this.RespData)

drawnow;
set(this.Handles.Listeners,'Enabled','on');
set(this.Handles.TableListener,'Enabled','on');