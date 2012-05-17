classdef SetGetRenderer < hgsetget
    %SetGetRenderer Provides improved version of hgsetget
    %    Provides an enhanced version of the get(obj) and set(obj)
    %    displays. Also, subclasses are required to provide appropriate
    %    renderers for use in get and set displays., and a richer display
    %    on get and set display operations.
    %
    %    Property names are checked to see if there is a duplicate property
    %    of the same name with an "-Info" suffix, which is typically
    %    hidden.  If so, that property is used to define the get(obj) and
    %    set(obj) displays on the primary property.
    %
    %    This undocumented class may be removed in a future release.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:38:22 $

    %% Constructor
    methods
        function obj = SetGetRenderer()
        end
    end

    %% Public Hidden Methods
    methods (Hidden = true)
        function getdisp(obj)
            %GETDISP Specialized MATLAB object property display with
            %hyperlinks.
            %GETDISP() is called by GET when GET is called with
            %no output argument and a single input parameter H an array
            %of handles to MATLAB objects.
            
            obj.dispRender(@internal.SetGetRenderer.renderValueForGet);
        end
        
        function setdisp(obj)
            %SETDISP Specialized MATLAB object property display with
            %hyperlinks.
            %SETDISP() is called by SET when SET is called with
            %no output argument and a single input parameter H an array
            %of handles to MATLAB objects.
            
            obj.dispRender(@internal.SetGetRenderer.renderValueForSet);
        end
        
        function result = set(obj,varargin)
            if nargin ~= 2
                obj.set@hgsetget(varargin{:})
                return
            end
            result = obj.renderSingleSet(varargin{1});
        end
        
        function result = renderSingleSet(obj,propName)
            if ~isempty(obj.findprop([propName 'Info']))
                name = [propName 'Info'];
            else
                name = propName;
            end
            result = internal.SetGetRenderer.renderValueForSet(get(obj,name));
        end
    end
    
    %% Protected Methods
    methods (Access=protected)
        %Implementers of this class MAY implement the protected
        %setDispHook and setDispHook, which return a short string to be
        %used in the getdisp and setdisp operations.
        %
        % If you do nothing, you get the default implementation below
        %
        % Example:
        % methods (Access=protected)
        function result = getDispHook(obj)
            result = sprintf('[%dx%d %s]',size(obj,1),size(obj,2),class(obj));
        end
        function result = setDispHook(obj) %#ok<MANU>
            result = '{}';
        end
    end
    
    %% Protected internal methods
    methods (Access=protected)
        function dispRender(obj,fcnValueRenderer)
            %dispRender Generate the get or set disp.
            %dispRender() getdisp and setdisp only vary in the way they
            %render values.  The fcnValueRenderer function handle
            %indicates to the correct renderer for a given situation.
            
            table = internal.DispTable();
            table.ShowHeader = false;
            table.ColumnSeparator = ': ';
            table.addColumn('Property Name','right')
            table.addColumn('Value','left')
            propertyNames = obj.fieldnames();
            for iProperty=1:numel(propertyNames)
                propname = propertyNames{iProperty};
                % Check to see if there's a property of the same name with
                % a "Info" suffix.  If there is, use that property to get
                % the value for the display.
                if ~isempty(obj.findprop([propname 'Info']))
                    name = [propname 'Info'];
                else
                    name = propname;
                end
                table.addRow(propname,fcnValueRenderer(get(obj,name)))
            end
            table.disp
        end
    end
    
    %% Protected static internal methods
    methods (Static,Access=protected)
    function result = renderValueForGet(value)
            
            % It could be empty
            if isempty(value)
                result = 'empty';
                return
            end
            
            % It could be a single SetGetRenderer object
            if isa(value,'internal.SetGetRenderer')
                try
                    result = value.getDispHook();
                    return
                catch e %#ok<NASGU>
                    % Ignore the failure, let the default catch it at the
                    % end
                end
            end
            
            % It could be a string
            if ischar(value)
                result = ['''' value ''''];
                return
            end
            
            % It could be a scalar numeric
            if isscalar(value) && isnumeric(value)
                result = num2str(value);
                return
            end
            
            % it could be a boolean
            if islogical(value)
                if value
                    result = 'true';
                else
                    result = 'false';
                end
                return
            end
            
            % Otherwise, its a '[mxn <classname>]'
            sizeValue = size(value);
            result = sprintf('[%dx%d %s]',sizeValue(end-1),sizeValue(end),class(value));
        end
        
        function result = renderValueForSet(value)
            
            % It could be a single SetGetRenderer object
            if isa(value,'internal.SetGetRenderer')
                try
                    result = value(1).setDispHook();
                    return
                catch e %#ok<NASGU>
                    % Ignore the failure, let the default catch it at the
                    % end
                end
            end
            
            % Otherwise, it's just '{}'
            result='{}';
        end
    end
end

% LocalWords:  dx mxn
