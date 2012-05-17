classdef (Hidden, Sealed) Parameter  < handle
%Parameter Control parameter sweep of test console

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:15 $
    
    %===========================================================================
    % Define Read-Only Properties
    %===========================================================================
    %
    properties (SetAccess = private)
        %Name    Name of parameter
        Name = ''        
        %DefaultValue Default value of the parameter
        DefaultValue   
        %ValueRange Valid range of parameter values for testing.
        %   Value range can be a two element numeric value or a cell vector of
        %   string values.
        %
        %   If ValueRange is a two-element vector then the elements are
        %   interpreted as an inclusive range of initial and final values of
        %   the parameter. Set this property to empty, if range checking is not
        %   desired. ValueRange can take any numeric data type that can appear
        %   in a 2-element homogeneous vector, e.g., [value1 value2]. The
        %   parameter data type must support the following operations: 
        %       - subscript indexing using parentheses
        %       - greater-than (">")
        %       - less-than ("<")
        %       - isempty()
        %
        %   Data type of ValueRange must match that of DefaultValue.
        ValueRange = []
        %CurrentValue Current value of the parameter
        CurrentValue
        %SweepVector Values to be used in the simulation
        %	SweepVector contains the parameter values to be used in the
        %	simulation.
        SweepVector                
        %SweepIndex Index of the CurrentValue in SweepVector
        %   Current sweep index pointing to a specific value in the SweepVector.
        %   
        SweepIndex = 1;
    end
    %===========================================================================
    % Define Public Methods
    %===========================================================================        
    methods (Hidden = true)
        function obj = Parameter(name,default,range)
            %Parameter Construct a test parameter object
            
            if nargin > 0
                obj.Name = name;  
                % First set the range so that if available we may check that the
                % default value is indeed within this range
                if nargin>2
                    obj.ValueRange = range;
                end
                obj.DefaultValue = default;
                if nargin>3
                    error(generatemsgid('invaludNumInputs'), ...
                        ['There can be three parameter inputs at most in ',...
                        'the Parameter object constructor.']);
                end
                % Initialize current value to the default
                obj.CurrentValue = obj.DefaultValue;
                
                % Initialize sweep vector to the default value. Sweep vector is
                % set by the user using a set method in the test harness.
                if ischar(obj.CurrentValue)
                    obj.SweepVector = {obj.CurrentValue};
                else
                    obj.SweepVector = obj.CurrentValue;
                end
            end
        end
        %=======================================================================
        function  resetFlag = increment(obj)
            %INCREMENT Increment the sweep index
            %   Increment the sweep index by one and set CurrentValue property
            %   to the SweepVector(SweepIndex) value. Reset to one and set
            %   resetFlag to true if index has exceeded the SweepVector length
            %   value. Sweep index will be pointing to a specific data value in
            %   the SweepVector property. 
            resetFlag = false;
            obj.SweepIndex = obj.SweepIndex + 1;
            if  obj.SweepIndex > length(obj.SweepVector);
                reset(obj);
                resetFlag = true;                
            else
                sweepVector = obj.SweepVector;
                if iscell(sweepVector)
                    obj.CurrentValue = sweepVector{obj.SweepIndex};
                else
                    obj.CurrentValue = sweepVector(obj.SweepIndex);
                end
            end
        end       
        %=======================================================================
        function  reset(obj)
            %RESET  Reset the Parameter object
            obj.SweepIndex = 1;     
            sweepVector = obj.SweepVector;
            if iscell(sweepVector)
                obj.CurrentValue = sweepVector{obj.SweepIndex};
            else
                obj.CurrentValue = sweepVector(obj.SweepIndex);
            end
        end   
        %=======================================================================
        function  currentValue = getCurrentValue(obj)
            %getCurrentValue Get current value of the test parameter              
            currentValue = obj.CurrentValue;
        end                
        %=======================================================================
        function  setSweepVector(obj,value)
            %setSweepVector Set sweep vector
            %   SweepVector property is private and can only be set through this
            %   method which will be called by a test console.
            %   The method sets the SweepVector property to the vector specified
            %   in the 'value' input. Calling this method causes a reset in the
            %   Parameter object.

            %Data check
            s = ['Sweep vector for parameter ' obj.Name];
            if isempty(obj.ValueRange) %#ok<*MCSUP>                
                validateattributes(value,...
                    {'numeric', 'cell'},...
                    {'row','vector'}, ...
                    [class(obj) '.SweepVector'],s);
            else
                if iscell(obj.ValueRange)
                    validateattributes(value,...
                        {'cell'},...
                        {}, ...
                        [class(obj) '.SweepVector'],s);
                    
                    for p=1:length(value)
                        validatestring(value{p},...
                            obj.ValueRange, ...
                            [class(obj) '.SweepVector'],s);
                    end
                else
                    validateattributes(value,...
                        {'numeric'},...
                        {'row','vector','>=',obj.ValueRange(1),...
                        '<=',obj.ValueRange(2)}, ...
                        [class(obj) '.SweepVector'],s);
                end
            end
            
            % Set sweep vector to input, and current value to first element of
            % the sweep vector.
            obj.SweepVector = value;  
            reset(obj);
        end
        %=======================================================================
        function h = clone(this)
            %CLONE Clone parameter
            h = eval(class(this));
            h.Name = this.Name;
            h.DefaultValue = this.DefaultValue;
            h.ValueRange = this.ValueRange;
            h.CurrentValue = this.CurrentValue;
            h.SweepVector = this.SweepVector;
            h.SweepIndex = this.SweepIndex;
        end
    end
    %===========================================================================
    % Set/Get methods
    %===========================================================================
    methods
        function set.Name(obj,name)
            validateattributes(name,...
                {'char'},...   
                {'nonempty'},...
                [class(obj) '.Name'],...
                'Name');
            obj.Name = name;
        end
        %=======================================================================
        function set.DefaultValue(obj,default)
            if isempty(obj.ValueRange)
                % ValueRange is empty, no range checking
                validateattributes(default,...
                    {'numeric','char'},...
                    {'nonempty',},...
                    [class(obj) '.DefaultValue'],...
                    'DefaultValue');
            else
                if iscell(obj.ValueRange)
                    % Value range is a cell of strings
                    validatestring(default, obj.ValueRange, ...
                        [class(obj) '.DefaultValue'],...
                        'DefaultValue');
                else
                    % Value range is an array of numeric values
                    validateattributes(default,...
                        {'numeric'},...
                        {'scalar','nonempty',...
                        '>=',obj.ValueRange(1),'<=',obj.ValueRange(2)},...
                        [class(obj) '.DefaultValue'],...
                        'DefaultValue');
                end
            end
            obj.DefaultValue = default;
        end
        %=======================================================================
        function set.ValueRange(obj,range)
            if ~isempty(range)
                if iscell(range)
                    % Range is a cell array.  It may be an enum.
                    for p=1:length(range)
                        if ~ischar(range{p}) || ~isvector(range{p})
                            error(generatemsgid('NotStringArray'), ...
                                ['RANGE must be a two element vector of '...
                                'numeric values or a cell array string '...
                                'values']);
                        end
                    end
                else
                    validateattributes(range,...
                        {'numeric'},...
                        {'row','vector','size',[1,2]},...
                        [class(obj) '.ValueRange'],...
                        'ValueRange');
                end
            end
            obj.ValueRange = range;
        end
    end% public methods
end% classdef
