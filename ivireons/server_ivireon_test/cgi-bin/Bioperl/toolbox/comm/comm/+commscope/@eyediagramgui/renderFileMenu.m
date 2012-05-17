function handles = renderFileMenu(this)
%RENDERFILEMENU Render the file menu of the GUI
%   Renders the file menu of the eye diagram scope GUI and returns handles of
%   menu items that require dynamic enable/disable.

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/08/22 20:23:47 $

% Get the figure handle
hFig = this.FigureHandle;

% Create the file menu
hFileMenu = uimenu(...
    'Parent',hFig,...
    'Label','&File',...
    'Tag','FileMenu');

% Attach submenu items
uimenu(...
    'Accelerator', 'N', ...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileNewSession(this)},...
    'Label','&New Session',...
    'Separator', 'off',...
    'Position', 1,...
    'Tag','FileMenuNewSession');

uimenu(...
    'Accelerator', 'O', ...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileOpenSession(this)},...
    'Label','&Open Session',...
    'Separator', 'off',...
    'Position', 2,...
    'Tag','FileMenuOpenSession');

handles.FileSaveSession = uimenu(...
    'Accelerator', 'S', ...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileSaveSession(hsrc, this)},...
    'Label','&Save Session',...
    'Separator', 'off',...
    'Position', 3,...
    'Enable', 'off', ...
    'Tag','FileMenuSaveSession');

uimenu(...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileSaveSession(hsrc, this)},...
    'Label','Save Session &As',...
    'Separator', 'off',...
    'Position', 4,...
    'Tag','FileMenuSaveSessionAs');

uimenu(...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileImportEyeDiagram(this)},...
    'Label','&Import Eye Diagram Object...',...
    'Separator', 'on',...
    'Position', 5,...
    'Tag','FileMenuImportEyeDiagram');

handles.FileRemoveEyeDiagram = uimenu(...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileRemoveEyeDiagram(this)},...
    'Label','&Remove Eye Diagram Object',...
    'Separator', 'off',...
    'Position', 6,...
    'Enable', 'off', ...
    'Tag','FileMenuRemoveEyeDiagram');

uimenu(...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFilePlotToFigure(this)},...
    'Label','Print to &Figure...',...
    'Separator', 'off',...
    'Position', 7,...
    'Tag','FilePrintToFigure');

uimenu(...
    'Accelerator', 'W', ...
    'Parent',hFileMenu,...
    'Callback',{@(hsrc,edatat)menucbFileClose(this)},...
    'Label','&Close',...
    'Separator', 'on',...
    'Position', 8,...
    'Tag','FileMenuClose');

%-------------------------------------------------------------------------------
function menucbFileImportEyeDiagram(hGui)
% Render the import window.  
renderImportEyeDiagram(hGui);

%-------------------------------------------------------------------------------
function menucbFileRemoveEyeDiagram(hGui)
% Delete the active eye diagram object.  
removeEyeDiagramObject(hGui.CurrentScopeFace);

%-------------------------------------------------------------------------------
function menucbFileClose(hGui)
% Callback function for close
close(hGui);

%-------------------------------------------------------------------------------
function menucbFileNewSession(hGui)
% Callback function for New Session menu item

if saveIfDirty(hGui, 'starting a new session')
    
    % Reset view panel contents
    reset(hGui.SettingsPanel);
    reset(hGui.MeasurementsPanel);
    reset(hGui.CompareResultsScopeFace);
    hGui.SessionName = 'untitled.eds';
    hGui.Dirty = 0;

    % Reset FirstSave
    set(hGui, 'FirstSave', 1);

    % Remove all the eye diagrams from the memory
    deleteAll(hGui.EyeDiagramObjMgr);

    % Update the data
    eyeObjs = getEyeObjects(hGui.EyeDiagramObjMgr);
    me = prepareCompareTableData(hGui.MeasurementsPanel, eyeObjs);
    if ~isempty(me)
        setException(hGui.CurrentScopeFace, me);
    end

    % Update scope
    update(hGui);
    
end

%-------------------------------------------------------------------------------
function menucbFileSaveSession(hsrc, hGui)
% Callback function for Save Session menu item

sourceId = get(hsrc, 'Tag');
if strcmp(sourceId, 'FileMenuSaveSessionAs')
    saveas(hGui);
else
    save(hGui);
end

%-------------------------------------------------------------------------------
function menucbFileOpenSession(hGui)
% Callback function for Open Session menu item

if saveIfDirty(hGui, 'loading')

    [filename pathname] = uigetfile({'*.eds', 'EyeDiagramScope (*.eds)'}, ...
        [], hGui.LastSessionFileLocation);
    if filename
        % Store the last valid file location
        hGui.LastSessionFileLocation = pathname;

        loadSessionStructure(hGui, fullfile(pathname, filename))

        % Indicate that the session is not dirty.
        set(hGui, 'Dirty', 0);

        % Reset first save
        set(hGui, 'FirstSave', 0);
        
        % Update the scope face
        update(hGui.CurrentScopeFace);
    end

end

%-------------------------------------------------------------------------------
function loadSessionStructure(this, fullFileName)
% Update properties of this using the saved structure's fields

try
    % Load the file contents
    s = load(fullFileName, '-mat');

    if isfield(s, 'sessionData')
        % sessionData is stored in the data file.  This may be a valid eye diagram
        % session file.  Get the session data.
        sessionData = s.sessionData;

        % Check the type
        if isfield(sessionData, 'Type') ...
                && strcmp(sessionData.Type, 'Eye Diagram Scope')
            % Do the processing based on version
            switch sessionData.Version
                case '1.0'
                    this.SessionName = fullFileName;

                    % Point all the eye diagram object PrivScopeHandle's to
                    % FigureHandle property.  Add to the eye diagram object
                    % manager.
                    eyeObj = sessionData.EyeDiagramObjects;
                    hFig = get(this, 'FigureHandle');
                    set(eyeObj.Handle, 'PrivScopeHandle', hFig);
                    importEyeDiagramObject(this, eyeObj);

                    % Set panel content indices
                    this.SettingsPanel.PanelContentIndices = ...
                        sessionData.SettingsPanelContentIndices;
                    this.MeasurementsPanel.PanelContentIndices = ...
                        sessionData.MeasurementsPanelContentIndices;

                case '1.1'
                    this.SessionName = fullFileName;

                    % Point all the eye diagram object PrivScopeHandle's to
                    % FigureHandle property.
                    eyeObjMgr = sessionData.EyeDiagramObjMgr;
                    setFigureHandle(eyeObjMgr, this.FigureHandle);

                    % Get field names
                    fNames = fieldnames(sessionData);
                    % Remove unrelated fields
                    fNames = fNames(3:end);

                    % Set properties
                    for p=1:length(fNames)
                        set(this, fNames{p}, sessionData.(fNames{p}))
                    end

                otherwise
                    error(this, sprintf(['Eye Diagram Scope session data '...
                        'file for version %s is not supported.'], ...
                        sessionData.Version)); %#ok<SPERR>
            end
        else
            error(this, ['Session file does not contain data for Eye '...
                'Diagram Scope.']);
        end
    else
        error(this, ...
            'Loaded file is not an Eye Diagram Scope session data file.');
    end
catch exception
    error(this, 'Eye Diagram Scope session data file is corrupted.');
end

%-------------------------------------------------------------------------------
function menucbFilePlotToFigure(hGui)
% Callback function for File Plot to Figure menu item

% Plot to independent figure window
plotToFigure(hGui.CurrentScopeFace);

%-------------------------------------------------------------------------------
% [EOF]
