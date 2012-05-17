classdef (Hidden = true) ImportDialog < handle
% @IMPORTDIALOG  Class definition for import dialog
%
 
% Author(s): Erman Korkut 01-Jul-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/11/09 16:35:45 $

   properties(SetAccess='public',GetAccess = 'public', SetObservable = true)
        Visible = 'off';
        Handles;
    end
    properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        Parent;
        Name;
        CurrentString = '<current value>';
    end
    methods
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = ImportDialog(Parent)
            if nargin == 0
                return
            end
            obj.Parent = Parent;            
            obj.Name = ctrlMsgUtils.message('Slcontrol:frest:strImportVar');
            % Create the GUI
            build(obj);
            layout(obj);
            % Populate text boxes with current tag
            obj.populateTextBoxWithCurrentString(obj);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.Visible(obj,value)
            LocalSetVisibility(obj,value)
            obj.Visible = value;
        end           
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function build(obj)
            UIColor = get(0,'DefaultUIControlBackground');
            % Set font size and weight
            if isunix
                FontSize = 10;
            else
                FontSize = 8;
            end
            FigPos = [20 20 52 23];
            % Figure
            ImportFig=figure('Units','characters',...
                'Position',FigPos,...
                'Number','off',...
                'IntegerHandle','off',...
                'HandleVisibility','Callback',...
                'Menu','none',...
                'Name',obj.Name,...
                'Color',UIColor,...
                'CloseRequestFcn',{@LocalHide obj},...
                'Visible','off',...
                'DockControls', 'off'); 
            % Static texts
            SimOutText = uicontrol(ImportFig,...
                'Background',UIColor,...
                'Unit','characters',...
                'HorizontalAlignment','left',...                
                'Style','text',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strSimulationOutput'));
            SimInText = uicontrol(ImportFig,...
                'Background',UIColor,...
                'HorizontalAlignment','left',...
                'Unit','characters',...
                'Style','text',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strSimulationInput'));
            SysestText = uicontrol(ImportFig,...
                'Background',UIColor,...
                'HorizontalAlignment','left',...
                'Unit','characters',...
                'Style','text',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strEstimationResult'));
            SysText = uicontrol(ImportFig,...
                'Background',UIColor,...
                'HorizontalAlignment','left',...
                'Unit','characters',...
                'Style','text',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strSysToCompAgainst'));                        
            % Edit texts
            SimOutEdit = uicontrol(ImportFig,...
                'Unit','characters',...
                'Background','w',...
                'HorizontalAlignment','left',...
                'Style','edit',...
                'FontSize',FontSize);
            SimInEdit = uicontrol(ImportFig,...
                'Unit','characters',...
                'Background','w',...
                'HorizontalAlignment','left',...
                'Style','edit',...
                'FontSize',FontSize);
            SysestEdit = uicontrol(ImportFig,...
                'Unit','characters',...
                'Background','w',...
                'HorizontalAlignment','left',...
                'Style','edit',...
                'FontSize',FontSize);
            SysEdit = uicontrol(ImportFig,...
                'Unit','characters',...
                'Background','w',...
                'HorizontalAlignment','left',...
                'Style','edit',...
                'FontSize',FontSize);            
            % Buttons
            OKButton = uicontrol(ImportFig,...
                'Background',UIColor,...
                'Unit','characters',...
                'Style','pushbutton',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strOK'),...
                'Callback',{@LocalOK obj});
            CancelButton = uicontrol(ImportFig,...
                'Background',UIColor,...
                'Unit','characters',...
                'Style','pushbutton',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strCancel'),...
                'Callback',{@LocalHide obj});
            HelpButton = uicontrol(ImportFig,...
                'Background',UIColor,...
                'Unit','characters',...
                'Style','pushbutton',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strRegularHelp'),...
                'Callback','scdguihelp(''simview_import'');');  
            % Store handles
            set(ImportFig,'ResizeFcn',{@(x,y) obj.layout});
            obj.Handles = struct(...
                'Figure',ImportFig,...
                'SimOutText',SimOutText,...
                'SimInText',SimInText,...
                'SysestText',SysestText,...
                'SysText',SysText,...
                'SimOutEdit',SimOutEdit,...
                'SimInEdit',SimInEdit,...
                'SysestEdit',SysestEdit,...
                'SysEdit',SysEdit,...
                'OKButton',OKButton,...
                'CancelButton',CancelButton,...
                'HelpButton',HelpButton);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function layout(obj)
            FigPos = get(obj.Handles.Figure,'Position');
            FigH = FigPos(4); FigW = FigPos(3);
            % Define gaps/heights/widths
            topG = 1;bottomG = 0.5;leftG = 1.5;rightG = 2;
            staticH = 1.35;
            editH = 1.75;
            staticW = FigW-leftG-rightG;
            editW = FigW-leftG-rightG;
            buttonW = (FigW-leftG-rightG)*0.9/3;
            buttonG = (FigW-leftG-rightG)*0.1/2;
            buttonH = 2;
            interG = 1.1; % Gap between each set of static/edit combination
            % Start placing items from the top
            set(obj.Handles.SimOutText,'Position',[leftG FigH-topG-staticH staticW staticH]);
            set(obj.Handles.SimOutEdit,'Position',[leftG FigH-topG-staticH-editH editW editH]);
            set(obj.Handles.SimInText,'Position',[leftG FigH-topG-2*staticH-editH-interG staticW staticH]);
            set(obj.Handles.SimInEdit,'Position',[leftG FigH-topG-2*staticH-2*editH-interG editW editH]);
            set(obj.Handles.SysestText,'Position',[leftG FigH-topG-3*staticH-2*editH-2*interG staticW staticH]);
            set(obj.Handles.SysestEdit,'Position',[leftG FigH-topG-3*staticH-3*editH-2*interG editW editH]);
            set(obj.Handles.SysText,'Position',[leftG FigH-topG-4*staticH-3*editH-3*interG staticW staticH]);
            set(obj.Handles.SysEdit,'Position',[leftG FigH-topG-4*staticH-4*editH-3*interG editW editH]);
            % Place the buttons at the bottom
            set(obj.Handles.OKButton,'Position',[leftG bottomG buttonW buttonH]);
            set(obj.Handles.CancelButton,'Position',[leftG+buttonW+buttonG bottomG buttonW buttonH]);
            set(obj.Handles.HelpButton,'Position',[leftG+2*buttonW+2*buttonG bottomG buttonW buttonH]);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    end
    methods(Static = true)
        function populateTextBoxWithCurrentString(this)
            set(this.Handles.SimOutEdit,'String',this.CurrentString);
            set(this.Handles.SimInEdit,'String',this.CurrentString);
            set(this.Handles.SysestEdit,'String',this.CurrentString);
            if ~isempty(this.Parent.InputVariables.SysToCompareAgainst)
                set(this.Handles.SysEdit,'String',this.CurrentString);
            else
                % Set to empty
                set(this.Handles.SysEdit,'String','');
            end
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalOK
%  Applies the new variables to the figure
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOK(~,~,obj)
% Read the specified variables
try
    simout = LocalReadVariable(obj,get(obj.Handles.SimOutEdit,'String'),'SimulationOutput');
    in = LocalReadVariable(obj,get(obj.Handles.SimInEdit,'String'),'SimulationInput');
    sysest = LocalReadVariable(obj,get(obj.Handles.SysestEdit,'String'),'EstimationResult');
    sys = LocalReadVariable(obj,get(obj.Handles.SysEdit,'String'),'SysToCompareAgainst');
catch %#ok<CTCH>
    return;
end

% Create new simulation data while performing error checks
try
    [src,cursel] = frest.frestutils.packInputForSimView(simout,in,sysest,sys);
catch Me
    errordlg(Me.message,'Simulink Control Design','modal');
    return;
end

% Hide the import dialog                      
obj.Visible = 'off';
% Keep record of the options
opts = getoptions(obj.Parent);
% Create new plot on the same figure
hfig = obj.Parent.Figure;
LocalClearFigure(hfig);
p = frestviews.SimviewPlot(hfig,sysest,src,opts,cursel,sys);

% Re-pack the input arguments
p.InputVariables = struct('SimulationOutput',{simout},...
                          'SimulationInput',in,...
                          'EstimationResult',sysest,...
                          'SysToCompareAgainst',sys);
% Attach the dialog to the new plot
obj.Parent = p;
p.ImportDialog = obj;

% Layout the plot
p.layout;

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalHide
%  Makes the import dialog figure invisible - callback for close button and
%  close window icon
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHide(~,~,obj)
obj.Visible = 'off';
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalSetVisibility
%  Sets the visibility of the import dialog figure
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetVisibility(obj,value)
set(obj.Handles.Figure,'Visible',value);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalReadVariable
%  Reads the variable with name varname from the base workspace
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varout = LocalReadVariable(obj,varname,vartype)
curstr = obj.CurrentString;
if isempty(varname)
    varout = [];
else    
    if ~strcmp(varname,curstr)
        try
            varout = evalin('base',varname);
        catch Me
            errordlg(ctrlMsgUtils.message('Slcontrol:frest:SimViewImportInvalidVariable',varname),...
                'Simulink Control Design','modal');
            rethrow(Me);
        end
    else
        varout = obj.Parent.InputVariables.(vartype);
    end
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalClearFigure
%  Clears the content of the figure (called before importing)
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalClearFigure(hfig)
% Uninstall resize function
set(hfig,'ResizeFcn','');
% Make it invisible
set(hfig,'Visible','off');
clf(hfig);

% clear the menu
filemenu = findall(hfig,'Tag','simView_File');
editmenu = findall(hfig,'Tag','simView_Edit');
helpmenu = findall(hfig,'Tag','simView_Help');
delete(filemenu);delete(editmenu);delete(helpmenu);

end
