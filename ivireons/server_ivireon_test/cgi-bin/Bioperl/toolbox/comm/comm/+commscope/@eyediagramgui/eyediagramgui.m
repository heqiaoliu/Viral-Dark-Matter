classdef eyediagramgui < imported.commgui.abstractGUI & hgsetget
%EYEDIAGRAMGUI Construct an EYEDIAGRAMGUI object

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 01:58:07 $
    
    %===========================================================================
    % Public read-only properties
    properties (SetAccess = private)
        Version = '1.1';
    end
    
    %===========================================================================
    % Private properties not to be saved
    properties %(SetAccess = private, GetAccess = private, Transient)
        FigureHandle = -1       % Main figure handle for the scope. Do not copy 
                                % this property
        Listeners;              % stores listeners in a structure. There are two 
                                % listeners: eyediagramgui object destroyed and
                                % figure destroyed. Do not copy this property
    end
    
    %===========================================================================
    % Private properties
    properties %(SetAccess = private, GetAccess = public)
        EyeDiagramObjMgr        % This property stores a list manager.  The list 
                                % elements are eye diagram structures.  The
                                % structure has three fields: Name, which is the
                                % name of the eye diagram objects handle,
                                % Handle, which is the handle of the eye diagram
                                % object, and Source, which is the source of the
                                % object (arg: argument, ws: workspace,
                                % filename: filename)
        WindowRendered = 0;     % flag to determine if the scope window is 
                                % rendered, including menu bar, toolbar, and
                                % status bar, but not the scope face. 

        FirstSave = 1;          % flag to determine if the session has ever been 
                                % saved
        Dirty = 0;              % flag to determine if the session is dirty, 
                                % i.e. any of the properties of the GUI has been
                                % changed since the last save. 
        SessionName = 'untitled.eds';
        LastImportFileLocation = '';
                                % path of the file that the user selected in the
                                % import eye diagram object window
        LastSessionFileLocation = '';
                                % path the user saved or loaded a session file 
                                % from
        SingleEyeScopeFace      % Handle of the single eye diagram scope face
        CompareResultsScopeFace % Handle of the compare results scope face
        CurrentScopeFace        % Handle of the current scope face.  This is a 
                                % copy of the handle of SingleEyeScopeFace or
                                % CompareResultsScopeFace
        SettingsPanel           % Handle of the settings panel manager
        MeasurementsPanel       % Handle of the measurements panel manager.  
                                % This object also handles the compare results
                                % table
        PlotCtrlWin             % Handle of the plot control window.
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.Dirty(this, dirty)
            % Set the property
            this.Dirty = dirty;

            % Update the figure title to indicate dirty scope face
            updateFigureTitle(this);
            
            % Update File Menu
            updateFileMenu(this);
        end
        %-----------------------------------------------------------------------
        function set.EyeDiagramObjMgr(this, eyeObjMgr)
            this.EyeDiagramObjMgr = eyeObjMgr;
            this.CompareResultsScopeFace.EyeDiagramObjMgr = eyeObjMgr;
            this.SingleEyeScopeFace.EyeDiagramObjMgr = eyeObjMgr;
        end
        %-----------------------------------------------------------------------
        function set.SettingsPanel(this, panelMgr)
            this.SettingsPanel = panelMgr;
            this.CompareResultsScopeFace.SettingsPanel = panelMgr;
            this.SingleEyeScopeFace.SettingsPanel = panelMgr;
        end
        %-----------------------------------------------------------------------
        function set.MeasurementsPanel(this, panelMgr)
            this.MeasurementsPanel = panelMgr;
            this.CompareResultsScopeFace.MeasurementsPanel = panelMgr;
            this.SingleEyeScopeFace.MeasurementsPanel = panelMgr;
        end
        %-----------------------------------------------------------------------
        function set.CurrentScopeFace(this, value)
            % Make sure that there is a scope face
            if ~isempty(this.CurrentScopeFace)
                % Remove the current scope face
                unrender(this.CurrentScopeFace);
                
                % Set the new scope face
                this.CurrentScopeFace = value;
                
                % Render the new scope face
                render(this.CurrentScopeFace);
                
                % Update the menu
                updateMenu(this)
            else
                % Set the new scope face
                this.CurrentScopeFace = value;
            end
        end
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = eyediagramgui(varargin)
            %EYEDIAGRAMGUI Construct an EYEDIAGRAMGUI object
            
            % Set defaults
            setPrivProp(this, 'Type', 'Eye Diagram GUI');
            this.EyeDiagramObjMgr = commscope.EyeObjMgr;
            this.SettingsPanel = commscope.SettingsPanelMgr;
            this.MeasurementsPanel = commscope.MeasurementsPanelMgr;

            % Create the figure window.  (NextPlot=new, when this is the current
            % figure and a new plot command is entered, plot to a new figure).
            hFig = figure(...
                'Units','pixels', ...
                'Position',[0 0 780 600], ...
                'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
                'IntegerHandle','off', ...
                'MenuBar','none', ...
                'NumberTitle','off', ...
                'Resize','off', ...
                'NextPlot', 'new', ...
                'HandleVisibility','off', ...
                'Tag','EyeScope', ...
                'Visible','off', ...
                'CreateFcn', {@movegui,'center'}, ...
                'CloseRequestFcn', @(hSrc, eventdata) cbCloseWindow(this),  ...
                'ColorMap', hot(64), ...
                'NextPlot', 'new', ...
                'DockControls', 'off');

            % Store the figure handle
            this.FigureHandle = hFig;

            % Store this object in the application data of the figure
            setappdata(this.FigureHandle, 'GuiObject', this);

            % Set up object being destroyed listeners for the figure and the
            % objects for a graceful exit.  First get current listeners.
            listeners = get(this, 'Listeners');
            % Set up new listeners
            m = addlistener(hFig, 'ObjectBeingDestroyed', ...
                    @(hSrc, eventdata) lclfbd_listener(this));
            k = addlistener(this, 'ObjectBeingDestroyed', ...
                    @(hSrc, eventdata) lclobd_listener(hFig));
            l = {m, k};
            % Store listeners in the object
            listeners.ObjectBeingDestroyed = l;
            set(this, 'Listeners', listeners);

            % Create the list of properties that will be saved as the session
            % data
            setappdata(hFig, 'SavedSessionData', ...
                {'SettingsPanel', ...
                'MeasurementsPanel', ...
                'EyeDiagramObjMgr'});
            
            % Create the single eye and compare results view object. Set the
            % parent to the main GUI figure and set the eye diagram object
            % manager to the handle of the main GUI object manager.
            this.SingleEyeScopeFace = ...
                commscope.EyeScopeSingleEyeView(hFig, ...
                    this.EyeDiagramObjMgr, ...
                    this.SettingsPanel, ...
                    this.MeasurementsPanel);
            this.CompareResultsScopeFace = ...
                commscope.EyeScopeCompareResultsView(hFig, ...
                    this.EyeDiagramObjMgr, ...
                    this.SettingsPanel, ...
                    this.MeasurementsPanel);
            this.CurrentScopeFace = this.SingleEyeScopeFace;

            % Render the scope
            render(this);
            
            if nargin == 1
                hEyeDiagram = varargin{1};
                if ~isa(hEyeDiagram, 'commscope.eyediagram')
                    error([getErrorId(this) ':InputNotAnEyeDiagramObj'], ...
                        ['Input argument must be a commscope.eyediagram ' ...
                        'object.']);
                end

                % Create eye diagram object structure and import
                workSpaceName = inputname(1);
                newEyeObj.Name = workSpaceName;
                newEyeObj.Handle = hEyeDiagram;
                newEyeObj.Source = 'arg';

                % Import the eye diagram object.  This will also update the GUI
                % to reflect the changes.
                importEyeDiagramObject(this, newEyeObj);

                % importEyeDiagramObject sets the dirty flag.  But since we
                % created an eyescope just now and the user has not changed
                % anything in the GUI, the GUI should be in the clean state.  So
                % reset the dirty flag.
                this.Dirty = 0;
            elseif nargin > 1
                delete(hFig);
                error([getErrorId(this) ':InvalidArgumentNumber'], ['Too ' ...
                    'many input arguments. Type ''help commscope.' ...
                    'eyediagramgui'' for correct usage.']);
            end

            % Make the scope visible
            set(hFig, 'Visible', 'on')
        end
        %-----------------------------------------------------------------------
        function error(this, exception)
            renderErrorDialog(this, exception, 'EyeScope Error');
        end
        %-----------------------------------------------------------------------
        function warning(this, exception)
            renderWarningDialog(this, exception, 'EyeScope Warning');
        end
        %-----------------------------------------------------------------------
        % Testability support functions
        function handles = getWidgetHandles(this)
            handles = getWidgetHandles(this.CurrentScopeFace);
        end
    end
end

%===============================================================================
% Helper functions

function lclfbd_listener(this)
%Local Figure Being Deleted Listener

this.WindowRendered = 0;

if saveIfDirty(this,'closing')
    cleanup(this);
    delete(this);
else
    render(this);
end

end
%-------------------------------------------------------------------------------
function lclobd_listener(hFig)
%Local Object Being Deleted Listener
delete(hFig);

end
%-------------------------------------------------------------------------------
function cbCloseWindow(hGui)
% Callback for the "X" at top-right corner, Alt-F4.
close(hGui);

end
%-------------------------------------------------------------------------------
% [EOF]
