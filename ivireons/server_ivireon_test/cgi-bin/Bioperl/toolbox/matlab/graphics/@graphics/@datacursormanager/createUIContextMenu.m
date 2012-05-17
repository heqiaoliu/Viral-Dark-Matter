function [hContextMenu] = createUIContextMenu(hTool)
% Create context menu for mode

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2010/05/20 02:26:06 $ 

% MAIN MENU
props.Parent = get(hTool,'Figure');
props.Serializable = 'off';
s.main = handle(uicontextmenu(props));
h(1) = s.main;
hContextMenu = h(1);

% InterpMethod
props.Parent = hContextMenu;
props.Label = 'Selection Style';
props.Separator = 'off';
props.Tag = 'DataCursorSelectionStyle';
s.cursor_style = handle(uimenu(props,'Checked','off'));
h(end+1) = s.cursor_style;

props = [];
props.Parent = s.cursor_style;
props.Label = 'Mouse Position';
props.Separator = 'off';
props.Tag = 'DataCursorMousePosition';
s.interp_linear = handle(uimenu(props));
h(end+1) = s.interp_linear;

props = [];
props.Parent = s.cursor_style;
props.Label = 'Snap to Nearest Data Vertex';
props.Separator = 'off';
props.Tag = 'DataCursorSnapDataVertex';
s.interp_nearest = handle(uimenu(props));
h(end+1) = s.interp_nearest;

% ViewStyle
props = [];
props.Parent = s.main;
props.Label = 'Display Style';
props.Separator = 'off';
props.Tag = 'DataCursorDisplayStyle';
s.disp_style = handle(uimenu(props,'Checked','off'));
h(end+1) = s.disp_style;

props = [];
props.Parent = s.disp_style;
props.Label = 'Window Inside Figure';
props.Separator = 'off';
props.Tag = 'DataCursorWindow';
s.disp_style_panel = handle(uimenu(props));
h(end+1) = s.disp_style_panel;

props = [];
props.Parent = s.disp_style;
props.Label = 'Datatip';
props.Separator = 'off';
props.Tag = 'DataCursorDatatip';
s.disp_style_datatip = handle(uimenu(props));
h(end+1) = s.disp_style_datatip;

% Datatip creation/deletion
props = [];
props.Parent = hContextMenu;
props.Label = 'Create New Datatip             Alt-Click'; 
props.Separator = 'on';
props.Tag = 'DataCursorNewDatatip';
s.create_datatip = handle(uimenu(props));
h(end+1) = s.create_datatip;

props.Parent = hContextMenu;
props.Label = 'Delete Current Datatip            Delete'; 
props.Separator = 'off';
props.Tag = 'DataCursorDeleteDatatip';
s.delete_datatip = handle(uimenu(props));
h(end+1) = s.delete_datatip;

props.Parent = hContextMenu;
props.Label = 'Delete All Datatips'; 
props.Separator = 'off';
props.Tag = 'DataCursorDeleteAll';
s.delete_all_datatips = handle(uimenu(props));
h(end+1) = s.delete_all_datatips;

% export
props.Parent = hContextMenu;
props.Label = 'Export Cursor Data to Workspace...';
props.Separator = 'on';
props.Tag = 'DataCursorExport';
s.export = handle(uimenu(props));
h(end+1) = s.export;

% The following two context-menu entries are only applicable in a
% non-deployed application:
if ~isdeployed
    % Edit the update function
    props.Parent = hContextMenu;
    props.Label = 'Edit Text Update Function...';
    props.Separator = 'on';
    props.Tag = 'DataCursorEditText';
    s.edit = handle(uimenu(props));
    h(end+1) = s.edit;
    
    props.Parent = hContextMenu;
    props.Label = 'Select Text Update Function...';
    props.Tag = 'DataCursorSelectText';
    props.Separator = 'off';
    s.select = handle(uimenu(props));
    h(end+1) = s.select;
end

% Assign callback to all handles
for i=1:numel(h)
    set(h(i),'Callback',{@localUpdateUIContextMenu,hTool,s});
end

%-----------------------------------------------%
function localUpdateUIContextMenu(obj,evd,hTool,s) %#ok

hFig = get(hTool,'Figure');
obj = handle(obj);
disp_style = get(hTool,'DisplayStyle');

% Update all child menu "checked" property
if isequal(obj,s.main)
     if strcmpi(disp_style,'window')
           set(s.disp_style_panel,'Checked','On');
           set(s.disp_style_datatip,'Checked','Off');
           set(s.create_datatip,'Enable','off');
           set(s.delete_datatip,'Enable','off');
           set(s.delete_all_datatips,'Enable','off');
     else
           set(s.disp_style_panel,'Checked','Off');
           set(s.disp_style_datatip,'Checked','On');
           set(s.create_datatip,'Enable','on');
           set(s.delete_datatip,'Enable','on');
           set(s.delete_all_datatips,'Enable','on');
     end
       
     snapon = get(hTool,'SnapToDataVertex');
     if strcmpi(snapon,'on')
          set(s.interp_linear,'Checked','off');
          set(s.interp_nearest,'Checked','on');
     else
          set(s.interp_linear,'Checked','on');
          set(s.interp_nearest,'Checked','off');         
     end
     
     h = get(hTool,'DataCursors');
     if isempty(h)
        set(s.export,'Enable','off');
     else
        set(s.export,'Enable','on');
     end
       
elseif isequal(obj,s.interp_nearest)
     set(hTool,'SnapToDataVertex','on');

elseif isequal(obj,s.interp_linear)
     set(hTool,'SnapToDataVertex','off');

elseif isequal(obj,s.disp_style_datatip)
     set(hTool,'DisplayStyle','datatip','Enable','on');
     
elseif isequal(obj,s.disp_style_panel)
     set(hTool,'DisplayStyle','window');
     set(hTool,'Enable','on');
       
elseif isequal(obj,s.delete_datatip)
     hCurrDatatip = get(hTool,'CurrentDataCursor');
     if ~isempty(hCurrDatatip)
        removeDataCursor(hTool,hCurrDatatip);
     end
elseif isequal(obj,s.delete_all_datatips)
     removeAllDataCursors(hTool);

elseif isequal(obj,s.create_datatip)
      set(hTool,'NewDataCursor',true);
       
% Export cursor to workspace     
elseif isequal(obj,s.export)
  
   prompt={'Enter the variable name'};
   name='Export Cursor Data to Workspace';
   numlines=1;
   defaultanswer={get(hTool,'DefaultExportVarName')};
   %Don't overwrite the default variable name if it already exists:
   userAns = false;
   answer=inputdlg(prompt,name,numlines,defaultanswer);
   exists = 0;
   if ~isempty(answer) && ischar(answer{1})
       exists = evalin('base', ['exist(''' answer{1} ''',''var'')']);
   end
   while exists && ~userAns
       warnMessage = sprintf(['A variable named "%s" already exists in the',...
           ' MATLAB Workspace.\nIf you continue, you will overwrite the instance',...
           ' of "%s" in your\nworkspace.'],...
           answer{1},answer{1});
       userAns = localUIPrefDiag(hFig, warnMessage, sprintf('Export Cursor Data to Workspace'),'DataCursorVariable');
       if ~userAns
           answer=inputdlg(prompt,name,numlines,defaultanswer);
           if ~isempty(answer) && ischar(answer{1})
               exists = evalin('base', ['exist(''' answer{1} ''',''var'')']);
           else
               exists = 0;
           end
       end
   end
   if ~isempty(answer) && ischar(answer{1})
       datainfo = getCursorInfo(hTool);
       try
           assignin('base',answer{1},datainfo);
           set(hTool,'DefaultExportVarName',answer{1});
       catch ex
           msg = ex.getReport('basic');
           id = ex.identifier;
           if strcmpi(id,'MATLAB:assigninInvalidVariable')
               errordlg(sprintf('Invalid variable name "%s".',answer{1}),...
                   'Cursor Data Export Error');
           else
               errordlg('An error occurred while saving the data.',...
                   'Cursor Data Export Error');
           end
       end
   end
elseif isfield(s,'properties') && isequal(obj,s.properties)
    if ~isdeployed
        propedit(hTool,'-noselect');
    end
    set(hTool,'Enable','on');
elseif isfield(s,'select') && isequal(obj,s.select)
    [fileName, pathName] = uigetfile('*.m','Select the MATLAB file');
    if fileName ~= 0
        if isempty(strfind(which(fileName),pathName))
            currDir = pwd;
            cd(pathName);
            [pathstr, name] = fileparts(fileName);
            hFun = str2func(name);
            cd(currDir);
        else
            [pathstr, name] = fileparts(fileName);
            hFun = str2func(name);
        end
        hTool.UpdateFcn = hFun;
        % Update the data cursors currently in the figure
        hTool.updateDataCursors;
    end
elseif isfield(s,'edit') && isequal(obj,s.edit)
    % Get layout info:
    hFig = hTool.Figure;
    figSize = get(hFig,'Position');
    figSize = hgconvertunits(hFig,figSize,get(hFig,'Units'),'Pixels',0);
    % The editor should take about %75 of the figure real estate
    callSize = [0 0 0 0];
    callSize(3:4) = figSize(3:4);
    callSize(1) = figSize(1)+figSize(3)*(1/16);
    screenSize = get(0,'ScreenSize');
    callSize(2) = screenSize(4) - (figSize(2)+figSize(4)*(15/16));
    currFunc = hTool.UpdateFcn;
    fileName = [];
    funcText = localGetUpdateText;
    if ~isempty(currFunc)
        if iscell(currFunc)
            currFunc = currFunc{1};
        end
        if isa(currFunc,'function_handle')
            funcInfo = functions(currFunc);
            fileName = funcInfo.file;
        else
            fileName = which(currFunc);
        end
    end
    intEditor = handle(awtcreate('com.mathworks.mlwidgets.interactivecallbacks.InteractiveCallbackEditor', ...
        'Ljava.awt.Rectangle;Ljava.lang.String;Ljava.lang.String;', ... 
        java.awt.Rectangle(callSize(1),callSize(2),callSize(3),callSize(4)),...
        fileName,funcText));

    % use handle command with callbackProperties so we get
    % only the minimum set of properties and we work well with
    % the set command.
    callback = handle(intEditor.getCallback(),'callbackProperties');

    % connect the callback to an anonymous function - note this
    % could be an anonymous or local function and it does
    % not need to be visible outside this function scope
    set(callback,'delayedCallback',{@localSetUpdateFcn,hTool});
    
    % Display the editor
    intEditor.setVisible(true);
end

%-----------------------------------------------%
function localSetUpdateFcn(obj,evd,hTool) %#ok<INUSL>
% Set the custom update function of the mode
fileName = evd.data';
% Clear out the function cache in order to force a refresh of the data
% cursor text
if ~isempty(fileName)
    currFun = hTool.UpdateFcn;
    if iscell(currFun)
        currFun = currFun{1};
    end
    if ischar(currFun)
        funName = strtok(hTool.UpdateFcn,' ');
        clear(funName);
    elseif ~isempty(currFun)
        clear(func2str(currFun));
    end
    [pathstr, name] = fileparts(fileName);
    if isempty(strfind(which(name),pathstr))
        currDir = pwd;
        cd(pathstr);
        hFun = str2func(name);
        cd(currDir);
    else
        hFun = str2func(name);
    end
    % If the file name hasn't changed and the update function is a cell,
    % then don't change the update function.
    % Otherwise, assume that there are no additional input arguments.
    if ~isempty(currFun)
        funInfo = functions(currFun);
        if ~iscell(hTool.UpdateFcn) || ~isequal(funInfo.file,fileName)
            hTool.UpdateFcn = hFun;
        end
    else
        hTool.UpdateFcn = hFun;
    end
    % Update the data cursors currently in the figure
    hTool.updateDataCursors;
end

%-----------------------------------------------%
function str = localGetUpdateText
% Return a template update method for datacursor mode
str = ['function output_txt = myfunction(obj,event_obj)',char(10),...
    '% Display the position of the data cursor',char(10),...
    '% obj          Currently not used (empty)',char(10),...
    '% event_obj    Handle to event object', char(10),...
    '% output_txt   Data cursor text string (string or cell array of strings).',char(10),...
    char(10),...
    'pos = get(event_obj,''Position'');',char(10),...
    'output_txt = {[''X: '',num2str(pos(1),4)],...',char(10),...
    '    [''Y: '',num2str(pos(2),4)]};',char(10),...
    char(10),...
    '% If there is a Z-coordinate in the position, display it as well',char(10),...
    'if length(pos) > 2',char(10),...
    '    output_txt{end+1} = [''Z: '',num2str(pos(3),4)];',char(10),...
    'end',char(10)];

%-----------------------------------------------%
function userAns = localUIPrefDiag(hFig, message, title, key)
%Post a dialog box with a "Do not show this message again" preference
%Use the java dialog box to be consistent with other dialog boxes.
isJavaFigure = usejava('awt');
%If java figures aren't used, return "true".
if ~isJavaFigure
    userAns = true;
    return;
end
% Disable the JavaFrame warning:
[lastWarnMsg lastWarnId ] = lastwarn; 
oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 

jFrame = get(hFig,'JavaFrame');

% Restore the warning state:
warning(oldstate);
lastwarn(lastWarnMsg, lastWarnId);

canvases = jFrame.getAxisComponent;
yesAnswer = com.mathworks.mwswing.MJOptionPane.YES_OPTION;
res = edtMethod('showOptionalConfirmDialog','com.mathworks.widgets.Dialogs',canvases,...
    message,title,com.mathworks.mwswing.MJOptionPane.CANCEL_OPTION,...
    com.mathworks.mwswing.MJOptionPane.WARNING_MESSAGE,...
    key,yesAnswer,true);


if res == yesAnswer
    userAns = true;
else
    userAns = false;
end
