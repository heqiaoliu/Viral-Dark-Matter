function renderImportEyeDiagram(this)
%RENDERIMPORTEYEDIAGRAM Render the import eye diagram object window

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 01:58:08 $

% Get size and spacing information
sz = eyeDiagramGuiImportEyeSizes(this);

% Create the window
hFig = figure('Position', [0 0 sz.ImportEyeWidth sz.ImportEyeHeight],...
    'CreateFcn', {@movegui,'center'},...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'),...
    'IntegerHandle', 'off',...
    'MenuBar', 'none',...
    'Name', 'Import eye diagram object',...
    'NumberTitle', 'off',...
    'Resize', 'off',...
    'NextPlot', 'new',...
    'HandleVisibility', 'on',...
    'Tag', 'ImportWindow',...
    'Visible', 'off',...
    'WindowStyle', 'modal');
set(hFig, 'KeyPressFcn', {@kpcbImportEyeFinish, hFig, this});

%-------------------------------------------------------
% Render the push buttons Import and Cancel
handles.ImportButton = uicontrol(hFig, ...
    'Style', 'pushbutton', ...
    'String', 'Import', ...
    'Tag', 'ImportImportButton', ...
    'Callback', {@pbcbImportEyeFinish, hFig, this}, ...
    'KeyPressFcn', {@kpcbImportEyeFinish, hFig, this}, ...
    'Position', [sz.ImportButtonX sz.vcf sz.bw sz.bh]);

handles.CancelButton = uicontrol(hFig, ...
    'Style', 'pushbutton', ...
    'String', 'Cancel', ...
    'Tag', 'ImportCancelButton', ...
    'Callback', {@pbcbImportEyeFinish, hFig, this}, ...
    'KeyPressFcn', {@kpcbImportEyeFinish, hFig, this}, ...
    'Position', [sz.CancelButtonX sz.vcf sz.bw sz.bh]);

%-------------------------------------------------------
% Render the source panel (button group)
handles.SourcePanel = uibuttongroup(hFig, ...
    'Title', 'Source', ...
    'Tag', 'SourcePanel', ...
    'Units', 'pixels', ...
    'FontSize', get(0,'defaultuicontrolFontSize'), ...
    'SelectionChangeFcn', {@selcbSourcePanel, hFig}, ...
    'Position', [sz.SourcePanelX sz.SourcePanelY ...
    sz.SourcePanelWidth sz.SourcePanelHeight]);

% Render radio buttons
handles.SourceRbWs = uicontrol(handles.SourcePanel, ...
    'Style', 'radiobutton', ...
    'String', 'From workspace', ...
    'Tag', 'SourceRadioButtonWS', ...
    'Value', 1, ...
    'KeyPressFcn', {@kpcbImportEyeFinish, hFig, this}, ...
    'Position', [sz.hcf sz.SourceRbWsY sz.SourceRbWidth sz.lh]);

handles.SourceRbFile = uicontrol(handles.SourcePanel, ...
    'Style', 'radiobutton', ...
    'String', 'From file', ...
    'Tag', 'SourceRadioButtonFile', ...
    'KeyPressFcn', {@kpcbImportEyeFinish, hFig, this}, ...
    'Position', [sz.hcf sz.SourceRbFileY sz.SourceRbWidth sz.lh]);

% Render file name edit box label
handles.SourceFileNameLabel = uicontrol(handles.SourcePanel, ...
    'Style', 'text', ...
    'String', 'MAT-file name:', ...
    'Tag', 'SourceFileNameLabel', ...
    'Enable', 'off', ...
    'Position', [sz.SourceFileNameLabelX sz.SourceFileNameLabelY ...
    sz.SourceFileNameLabelWidth sz.lh]);

% Render file name edit box
handles.SourceFileName = uicontrol(handles.SourcePanel, ...
    'Style', 'edit', ...
    'String', '', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'SourceFileName', ...
    'KeyPressFcn', {@kpcbImportEyeFinish, hFig, this}, ...
    'Callback', @editcbFileName, ...
    'Enable', 'off', ...
    'Position', [sz.SourceFileNameX sz.SourceFileNameY ...
    sz.SourceFileNameWidth sz.lh]);

% Render browse button
handles.SourceBrowse = uicontrol(handles.SourcePanel, ...
    'Style', 'pushbutton', ...
    'String', 'Browse...', ...
    'HorizontalAlignment', 'left', ...
    'Tag', 'SourceBrowse', ...
    'KeyPressFcn', {@kpcbBrowse, hFig, this}, ...
    'Callback', {@pbcbBrowse, hFig, this}, ...
    'Enable', 'off', ...
    'Position', [sz.SourceBrowseX sz.SourceBrowseY sz.bw sz.bh]);

%-------------------------------------------------------
% Render the contents panel
handles.ContentsPanel = uipanel(hFig, ...
    'Title', 'Workspace contents', ...
    'Tag', 'ContentsPanel', ...
    'Units', 'pixels', ...
    'FontSize', get(0,'defaultuicontrolFontSize'), ...
    'Position', [sz.ContentsPanelX sz.ContentsPanelY ...
    sz.ContentsPanelWidth sz.ContentsPanelHeight]);

% Render contents list box
handles.ContentsListBox = uicontrol(handles.ContentsPanel, ...
    'Style', 'listbox', ...
    'String', '', ...
    'Tag', 'ContentsListBox', ...
    'BackgroundColor', [1 1 1], ...
    'KeyPressFcn', {@lbcbContentsListBox, hFig, this}, ...
    'Callback', {@lbcbContentsListBox, hFig, this}, ...
    'Position', [sz.ContentsListX sz.ContentsListX ...
    sz.ContentsListWidth sz.ContentsListHeight], ...
    'Max', 1, ...
    'Min', 0);

% Save handles
setappdata(hFig, 'Handles', handles);

% Populate the contents panel
populateContents(handles.ContentsListBox, []);

% Make it visible
set(hFig, 'Visible', 'on');

% Restore the font parameters to the system defaults
restoreFontParams(this, sz);

%-------------------------------------------------------------------------------
function populateContents(hsrc, fileName)
% Populate the contents list box based on the selected MAT-file or workspace.  Filter the contents such that only eye diagram objects are shown.

% Get the selected button
hFig = ancestor(hsrc, 'figure');
handles = getappdata(hFig, 'Handles');
hButton = get(handles.SourcePanel, 'SelectedObject');
selectedButton = get(hButton, 'Tag');

%Populate with the selected button
noFile = 0;
switch selectedButton
    case 'SourceRadioButtonWS'
        % Get all the variables in the base workspace
        vars = evalin('base', 'whos');

    case 'SourceRadioButtonFile'
        % Get all the variables in the selected file
        if ~isempty(fileName)
            try
                vars = whos('-file', fileName);
            catch %#ok<CTCH>
                % This is not a valid MAT-file
                noFile = 1;
            end
        else
            noFile = 1;
        end
end

if noFile
    list = {'<no valid file selected>'};
else
    % Filter so that we have only eye diagram objects
    eyeDiagrams = filterVariables(vars, 'commscope.eyediagram');

    % Populate listbox
    numEyeDiagrams = length(eyeDiagrams);
    list = cell(1, numEyeDiagrams);
    if numEyeDiagrams
        for p=1:numEyeDiagrams
            list{p} = eyeDiagrams(p).name;
        end
    else
        list = {'<no eye diagram objects>'};
    end
end

% Set the contents of the listbox
set(handles.ContentsListBox, 'String', list);

%-------------------------------------------------------------------------------
function sf = filterVariables(s, classname)
% Filter the variables in S and return only the ones of type CLASSNAME

sf = [];
for p=1:length(s)
    if strcmp(s(p).class, classname)
        sf = [sf s(p)]; %#ok
    end
end

%-------------------------------------------------------------------------------
function lbcbContentsListBox(hsrc, eventdata, hFig, hGui)
% Callback function of the contents listbox.

% Determine the selection type
selectionType = get(hFig, 'SelectionType');
if strcmp(selectionType, 'normal') && isempty(eventdata)
    % Single click.  Don't do anything.
else
    eyeDiagramNames = get(hsrc, 'String');
    if (length(eyeDiagramNames) ~= 1) ...
            || ~strcmp(eyeDiagramNames{1}, '<no eye diagram objects>')

        pbcbImportEyeFinish(hsrc, eventdata, hFig, hGui);
    end
end

%-------------------------------------------------------------------------------
function eyeDiagram = createEyeDiagramObjectStruct(hFig)
% Get the handles of the selected eye diagram objects and create an eye diagram
% object structure with Name, Handle, and source fields

handles = getappdata(hFig, 'Handles');
eyeDiagramNames = get(handles.ContentsListBox, 'String');

if (length(eyeDiagramNames) ~= 1) ...
        || (~strcmp(eyeDiagramNames{1}, '<no eye diagram objects>') ...
            && ~strcmp(eyeDiagramNames{1}, '<no valid file selected>'))

    selection = get(handles.ContentsListBox, 'Value');
    eyeDiagram.Name = eyeDiagramNames{selection};

    hSelectedButton = get(handles.SourcePanel, 'SelectedObj');
    selectedButton = get(hSelectedButton, 'Tag');
    switch selectedButton
        case 'SourceRadioButtonWS'
            eyeDiagram.Handle = evalin('base', eyeDiagramNames{selection});
            eyeDiagram.Source = 'ws';
        case 'SourceRadioButtonFile'
            fileName = get(handles.SourceFileName, 'String');
            dummy = load(fileName, eyeDiagram.Name);
            eyeDiagram.Handle = dummy.(eyeDiagram.Name);
            [~, name] = fileparts(fileName);
            eyeDiagram.Source = name;
    end
else
    eyeDiagram = [];
end

%-------------------------------------------------------------------------------
function pbcbImportEyeFinish(hsrc, ~, hFig, hGui)
% Finish the import eye diagram window action

% Get the caller's name
sourceId = get(hsrc, 'Tag');

% If source is the Import button, the Contents listbox, or import window
if strmatch(sourceId, {'ImportImportButton', 'ContentsListBox', 'ImportWindow'})
    success = importEyeFinish(hFig, hGui);
    if success
        delete(hFig);
    end
elseif strcmp(sourceId, 'ImportCancelButton')
    delete(hFig);
end

% Update the menu
updateMenu(hGui);

%-------------------------------------------------------------------------------
function selcbSourcePanel(hsrc, ~, hFig)
% Callback function for radio buttons

% Get the new selected button
hNewButton = get(hsrc, 'SelectedObject');
newButtonName = get(hNewButton, 'Tag');

% Get the handles
handles = getappdata(hFig, 'Handles');

if strcmp(newButtonName, 'SourceRadioButtonFile')
    % If file is selected as the source
    set(handles.SourceFileNameLabel, 'Enable', 'on');
    set(handles.SourceFileName, 'Enable', 'on');
    set(handles.SourceFileName, 'String', '');
    set(handles.SourceBrowse, 'Enable', 'on');
    set(handles.ContentsPanel, 'Title', 'File contents');
    populateContents(hsrc, '');
else
    % If workspace is selected as the source
    set(handles.SourceFileNameLabel, 'Enable', 'off');
    set(handles.SourceFileName, 'Enable', 'off');
    set(handles.SourceBrowse, 'Enable', 'off');
    set(handles.ContentsPanel, 'Title', 'Workspace contents');
    populateContents(hsrc, '');
end

%-------------------------------------------------------------------------------
function editcbFileName(hsrc, ~)
% Callback function for file name edit box

% Get the entered file name
enteredFileName = get(hsrc, 'String');
fileName = checkFileValidity(enteredFileName);

% Update contents
populateContents(hsrc, fileName);

%-------------------------------------------------------------------------------
function pbcbBrowse(hsrc, ~, hFig, hGui)
% Callback function for file name browse button

% Get the entered file name
[name pathstr] = uigetfile({'*.mat'}, [], hGui.LastImportFileLocation);

if name
    % Dialog returned a file, build full file name
    enteredFileName = fullfile(pathstr, name);
    fileName = checkFileValidity(enteredFileName);
    
    % Store the last valid file location
    hGui.LastImportFileLocation = pathstr;

    % Display the file name in the edit box
    handles = getappdata(hFig, 'Handles');
    set(handles.SourceFileName, 'String', fileName);

    % Populate the contents panel
    populateContents(hsrc, fileName);
end

%-------------------------------------------------------------------------------
function fileName = checkFileValidity(enteredFileName)
% Check the validity of the selected file

fileName = '';
% Check if file is valid
if exist(enteredFileName, 'file')
    % File exists
    [~ , ~, ext] = fileparts(enteredFileName);
    if strcmp(ext, '.mat')
        % File has correct extension.
        fileName = enteredFileName;
    end
end

%-------------------------------------------------------------------------------
function kpcbImportEyeFinish(hsrc, eventdata, hFig, hGui)
% Callback function for key pressed events

sourceId = get(hsrc, 'Tag');

if strcmp(eventdata.Key, 'escape')
    % Close the window
    delete(hFig);
else
    if strcmp(sourceId, 'ImportCancelButton') ...
            && strcmp(eventdata.Key, 'return')
        % Close the window
        delete(hFig);
    elseif any(strmatch(sourceId, {'ImportImportButton', 'ImportWindow'})) ...
            && strcmp(eventdata.Key, 'return')
            importEyeFinish(hFig, hGui);
    end
end

%-------------------------------------------------------------------------------
function kpcbBrowse(hsrc, eventdata, hFig, hGui)
% Key press function for Browse button

if strcmp(eventdata.Key, 'escape')
    % Close the window
    delete(hFig);
elseif strcmp(eventdata.Key, 'return')
    % Call the callback function
    pbcbBrowse(hsrc, eventdata, hFig, hGui);
end

%-------------------------------------------------------------------------------
function success = importEyeFinish(hFig, hGui)
% Import the eye diagram object from the GUI

success = false;

% Create eye diagram object structure based on the selection
eyeDiagram = createEyeDiagramObjectStruct(hFig);

if ~isempty(eyeDiagram)
    % Make the figure invisible
    set(hFig, 'Visible', 'off');

    % Import the eye diagram
    importEyeDiagramObject(hGui, eyeDiagram);
    
	success = true;
end
% [EOF]
