classdef EyeScopeSingleEyeView < commscope.ScopeFace
    %EyeScopeSingleEyeView Construct a single eye scope face for EyeScope
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $  $Date: 2008/08/22 20:23:46 $

    %===========================================================================
    % Public properties
    properties
        PlotCtrlWin     % This is the handle of the plot control window object.  
                        % It is tha same handle the main GUI object
                        % (eyediagramgui) has.  Since this scope face can change
                        % the selected eye diagram, it has to have access to the
                        % plot control window object to update it.
    end

    %===========================================================================
    % Private properties
    properties (Access = private)
        Mode = 'Real Signal'; % Mode of the single eye diagram scope face.  
                              % Can be 'Real Signal' or 'Complex Signal'.  Note
                              % that this definition matches the OperationMode
                              % definition of the eye diagram object.
    end

    %===========================================================================
    % Public methods
    methods
        render(this)
        update(this)
        %-----------------------------------------------------------------------
        function this = EyeScopeSingleEyeView(parent, eyeObjMgr, ...
                sPanelMgr, mPanelMgr)
            % Constructor
            this.Parent = parent;
            this.EyeDiagramObjMgr = eyeObjMgr;
            this.SettingsPanel = sPanelMgr;
            this.MeasurementsPanel = mPanelMgr;
        end
        %-----------------------------------------------------------------------
        function idx = getSelectedEyeObj(this)
            % Return the index of the selected eye object.  Return empty if no
            % eye diagram object is loaded
            handles = this.WidgetHandles;
            idx = get(handles.EyeObjName, 'Value');
            
            if (idx == 1) 
                eyeObjNames = get(handles.EyeObjName, 'String');
                if (size(eyeObjNames,1) == 1) ...
                        && strncmp(get(handles.EyeObjName, 'String'), '<', 1)
                    idx = [];
                end
            end
        end
        %-----------------------------------------------------------------------
        function removeEyeDiagramObject(this)
            % Remove the selected eye diagram object
            idx = getSelectedEyeObj(this);
            hGui = getappdata(this.Parent, 'GuiObject');
            deleteEyeDiagramObject(hGui, idx);
            
            % Update the menu
            updateMenu(this);
        end
        %-----------------------------------------------------------------------
        function plotToFigure(this)
            % Get the active eye diagram object structure
            hGui = getappdata(this.Parent, 'GuiObject');
            eyeObj = getSelected(hGui.EyeDiagramObjMgr);
            
            % Check if this is a valid eye diagram object
            if ~isempty(eyeObj)
                
                % Make a copy of the eye diagram object handle.  We need a
                % copy since closing the figure window will destroy the eye
                % diagram object associated with the figure.
                hEye = copy(eyeObj.Handle);
                
                % Set the PrivScopeHandle to an invalid handle to signal
                % that the call to the plot method should create a new
                % figure window and call plot
                set(hEye, 'PrivScopeHandle', -1)
                plot(hEye)
                
            else
                error(hGui, 'No eye diagram object is loaded.');
            end
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        sz = guiSizes(this)
        %-----------------------------------------------------------------------
        function hTable = renderInfoTable(this, hPanel, hInfo)
            % Render the contents of the info panel

            eyeObj = getSelected(this.EyeDiagramObjMgr);

            [tableData columnLabels] = ...
                prepareTableData(hInfo, eyeObj);

            hTable = commgui.table(...
                'Parent', hPanel, ...
                'ColumnLabels', columnLabels, ...
                'TableData', tableData);
        end
        %-----------------------------------------------------------------------
        function updateInfoTable(this, hTable, hInfo)
            % Update the contents of the info panel

            eyeObj = getSelected(this.EyeDiagramObjMgr);

            [tableData columnLabels me] = ...
                prepareTableData(hInfo, eyeObj);

            set(hTable, 'TableData', tableData, 'ColumnLabels', columnLabels);
            
            if ~isempty(me)
                setException(this, me);
            end
        end
        %-----------------------------------------------------------------------
        function updateListButtons(this)
            % Update the 'X' and '+' buttons of the measurements results table
            handles = this.WidgetHandles;

            numEyeObjs = getNumberOfEyeObjects(this.EyeDiagramObjMgr);
            if numEyeObjs
                set(handles.DelButton, 'Enable', 'on');
            else
                set(handles.DelButton, 'Enable', 'off');
            end
        end
    end
end