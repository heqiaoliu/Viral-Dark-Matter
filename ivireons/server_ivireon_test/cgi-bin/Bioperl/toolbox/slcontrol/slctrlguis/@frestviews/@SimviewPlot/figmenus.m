function figmenus(this)
%  FIGMENUS Creates customized menus for the simView figure.

% Author(s): Erman Korkut 26-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/08/08 01:19:23 $
%
%---File Menu
FigMenu.FileMenu.Main = uimenu(this.Figure,'Label',ctrlMsgUtils.message('Slcontrol:frest:strFile'),...
    'HandleVis','off','Tag','simView_File');
FigMenu.FileMenu.Import = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
   'Label',ctrlMsgUtils.message('Slcontrol:frest:strImport'),...
   'Callback',{@localImport this},'Tag','simView_Import',...
   'HandleVis','off');
FigMenu.FileMenu.PageSetup = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
   'Label',ctrlMsgUtils.message('Slcontrol:frest:strPageSetup'),...
   'Callback',{@localPageSetup this},'Tag','simView_PageSetup',...
   'HandleVis','off');
FigMenu.FileMenu.Print = uimenu(FigMenu.FileMenu.Main,...
   'Label',ctrlMsgUtils.message('Slcontrol:frest:strPrintMenu'),...
   'Accelerator','P','Callback',{@localPrintPaper this},'Tag','simView_Print',...
   'HandleVis','off');
FigMenu.FileMenu.Close = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
   'Label',ctrlMsgUtils.message('Slcontrol:frest:strClose'),...
   'Accelerator','W','CallBack',{@localClose this},'Tag','simView_Close',...
   'HandleVis','off');
% -------------------------------------------------------------------------
% Edit menu
FigMenu.Edit.Main = uimenu(this.Figure,'Label',ctrlMsgUtils.message('Slcontrol:frest:strEdit'),...
    'HandleVis','off','Tag','simView_Edit');
%---Plot Visibilities Menu
FigMenu.PlotVisMenu.Main = uimenu(FigMenu.Edit.Main,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strPlotVisibilities'),...
    'HandleVis','off','Tag','simView_PlotVis');
FigMenu.PlotVisMenu.Time = uimenu(FigMenu.PlotVisMenu.Main,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strTimePlot'),...    
    'Checked','on','Callback',{@LocalPlotVisibility this.TimePlot this},...
    'HandleVis','off','Tag','simView_PlotVis_Time'); 
FigMenu.PlotVisMenu.FFT = uimenu(FigMenu.PlotVisMenu.Main,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strSpectrumPlot'),...    
    'Checked','on','Callback',{@LocalPlotVisibility this.SpectrumPlot this},...
    'HandleVis','off','Tag','simView_PlotVis_Spec'); 
if ~isempty(this.SummaryPlot)
    FigMenu.PlotVisMenu.Summary = uimenu(FigMenu.PlotVisMenu.Main,...
        'Label',ctrlMsgUtils.message('Slcontrol:frest:strSummaryPane'),...
        'Checked','on','Callback',{@LocalPlotVisibility this.SummaryPlot.SummaryBode this},...
        'HandleVis','off','Tag','simView_PlotVis_Summary');
end
% -------------------------------------------------------------------------
% ---Help Menu
FigMenu.HelpMenu.Main = uimenu(this.Figure,'Label',ctrlMsgUtils.message('Slcontrol:frest:strHelp'),...
    'HandleVis','off','Tag','simView_Help');
FigMenu.HelpMenu.ViewerHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',ctrlMsgUtils.message('Slcontrol:frest:strHelpsimView'),...
   'Callback','scdguihelp(''simview_reference'')','Tag','simView_ViewerHelp',...
   'HandleVis','off');
FigMenu.HelpMenu.ToolboxHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',ctrlMsgUtils.message('Slcontrol:frest:strHelpSCD'),...
   'Callback','doc(''slcontrol/'');','Tag','simView_SCDHelp',...
   'HandleVis','off');
FigMenu.HelpMenu.DemosHelp = uimenu(FigMenu.HelpMenu.Main,'Separator','on',...
   'Label',sprintf('&Demos'),'Callback','demo(''simulink'',''Simulink Control Design'')',...
   'Tag','simView_Demos','HandleVis','off');

% Set the CloseRequest function to here to use the same callback as close
% menu when user clicks X on upper right corner.
set(this.Figure,'CloseRequestFcn',{@localClose this});
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  localImport
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localImport(eventSrc,eventData,this)
% Build import dialog if does not exist
if isempty(this.ImportDialog) 
   this.ImportDialog = this.importdlg;
else
    % Convert the texts to current if it exists
    this.ImportDialog.populateTextBoxWithCurrentString(this.ImportDialog);
end
this.ImportDialog.Visible = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  localPageSetup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localPageSetup(eventSrc,eventData,this)
pagesetupdlg(double(this.Figure));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  localPrint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localPrintPaper(eventSrc,eventData,this)
print(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  localClose
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localClose(eventSrc,eventData,this)
fig = this.Figure;
% Close channel selector if open
if ~isempty(this.ChannelSelector)
    chsel = this.ChannelSelector.Handles.Figure;
else
    chsel = 0;
end

% Close import dialog if open
if ~isempty(this.ImportDialog)
    impdlg = this.ImportDialog.Handles.Figure;
else
    impdlg = 0;
end

% Clear main database
delete(this);

% Delete HG figure
set(fig,'DeleteFcn','');
delete(fig(ishandle(fig)));
if chsel
    set(chsel,'DeleteFcn','');
    delete(chsel(ishandle(chsel)));
end
if impdlg
    set(impdlg,'DeleteFcn','');
    delete(impdlg(ishandle(impdlg)));
end


function LocalPlotVisibility(eventSrc, eventData, this, simviewplot)
m = eventSrc;
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
else
    set(m,'Checked','on');
end
% Take the action
if strcmp(get(m,'Checked'),'on')
    this.AxesGrid.Visible = 'on';
else
    this.AxesGrid.Visible = 'off';
end
% Layout the figure again
layout(simviewplot)
