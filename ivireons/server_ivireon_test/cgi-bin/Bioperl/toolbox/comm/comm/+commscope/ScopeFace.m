classdef ScopeFace < imported.commgui.abstractGUI
    %ScopeFace Construct a scope face object
    %
    %   Warning: This undocumented function may be removed in a future release.
    
    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.6.7 $  $Date: 2009/11/13 04:14:11 $
    
    %===========================================================================
    % Public properties
    properties
        EyeDiagramObjMgr        % This property stores a list manager.  The list 
                                % elements are eye diagram structures.  The
                                % structure has three fields: Name, which is the
                                % name of the eye diagram objects handle,
                                % Handle, which is the handle of the eye diagram
                                % object, and Source, which is the source of the
                                % object (arg: argument, ws: workspace,
                                % filename: filename)
        SettingsPanel           % Object of type commscope.SettingsPanel to 
                                % store the eye diagram object settings manager
        MeasurementsPanel       % Object of type 
                                % commscope.MeasurementsPanelMgr to 
                                % store the measurements panel's
                                % manager object
    end
    
    %===========================================================================
    % Protected properties
    properties (Access = protected)
        WidgetHandles           % Structure of widget handles
        Rendered = 0;           % Flag to determine if the scope face is
                                % rendered
        Exception = [];         % Stores the exception generated during
                                % rendering a scope face.  This can be an
                                % MException or a warning message (string).
    end
    
    %===========================================================================
    % Abstract methods
    methods (Abstract)
        render(this)
        update(this)
    end
    
    %===========================================================================
    % Public methods
    methods
        function unrender(this)
            % Remove the widgets from the parent figure
            
            if this.Rendered
                handles = this.WidgetHandles;
                fnames = fieldnames(handles);
                
                for p=1:length(fnames)
                    hField = handles.(fnames{p});
                    if ishghandle(hField) || isa(hField, 'commgui.DoubleYAxes')
                        delete(hField);
                    end
                end
                
                this.Rendered = 0;
            end
        end
        %-----------------------------------------------------------------------
        function reset(this) %#ok<MANU>
            %NO OP
        end
        %-----------------------------------------------------------------------
        function setException(this, me)
            % Save the exception generated during rendering of the scope
            % face
            this.Exception = me;
        end
        %-----------------------------------------------------------------------
        function checkException(this)
            % Check if there was an exception during the rendering of the
            % scope face.  If there was one, then render an error/warning
            % message.
            
            % Get the exception
            me = this.Exception;
            if isempty(me)
                % Nothing to do
            else
                if ischar(me)
                    % This is a warning
                    commscope.notifyWarning(this.Parent, me);
                else
                    newMessage = strrep(me.message, ...
                        ['Check measurement setup values in the '...
                        'MeasurementsSetup property'], ...
                        ['Check eye diagram object settings and, if '...
                        'needed, update the eye diagram object '...
                        'MeasurementSetup property']);
                    temp = MException(me.identifier, newMessage);
                    me = addCause(temp, me);
                    
                    % This is an error
                    commscope.notifyError(this.Parent, me);
                end
                this.Exception = [];
            end
        end
        %-------------------------------------------------------------------
        function plotEyeDiagram(this)
            %plotEyeDiagram Plot the eye diagram to the GUI axis
            
            % Get active eye object and determine operation mode
            activeEyeObj = getSelected(this.EyeDiagramObjMgr);
            
            if ~isempty(activeEyeObj)
                try
                    % Plot the eye diagram
                    plot(activeEyeObj.Handle);
                    
                    % Update the axes width to fit 3D and 2D figures properly
                    updateAxesWidth(this);
                    
                    % Update the title
                    title(this.WidgetHandles.InPhaseAxes, ...
                        'Single Eye Diagram View');
                catch me
                    % Reset to the default value
                    set(activeEyeObj.Handle, 'PlotType', '2D Color');
                    % Store the exception
                    setException(this, me)
                end
            end
        end
        %-----------------------------------------------------------------------
        % Testability support functions
        function handles = getWidgetHandles(this)
            handles = this.WidgetHandles;
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function updateMenu(this)
            hGui = getappdata(this.Parent, 'GuiObject');
            updateFileMenu(hGui);
        end
    end
end
