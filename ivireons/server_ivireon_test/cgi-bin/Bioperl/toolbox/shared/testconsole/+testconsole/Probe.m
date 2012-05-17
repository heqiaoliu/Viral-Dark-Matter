classdef (Hidden, Sealed) Probe < handle
    %Probe Collect data for test console

    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:16 $
    
    %===========================================================================
    % Protected Properties
    properties (SetAccess = protected)
        %Name Name of the test probe
        Name
        %Data
        Data
        %Flag to determine if probe is set
        IsSet = false;
        % Description 
        Description
    end
    
    %===========================================================================
    % Public Hidden Methods
    methods (Hidden = true)
        function this = Probe(varargin)
            %PROBE  Construct a probe 
            if nargin > 0
                this.Name = varargin{1};
                if nargin == 2
                    this.Description = varargin{2};
                end
                if nargin > 2
                error(generatemsgid('TooManyArgumentsInProbeConstructor'), ...
                    'Too many input arguments to %s class constructor.',...
                    class(this))                    
                end
            end                
        end       
        %-----------------------------------------------------------------------
        function h = copy(this)
            %COPY   Copy a probe
            
            h = testconsole.Probe(this.Name, this.Description);
            h.IsSet = this.IsSet;
        end
        %-----------------------------------------------------------------------
        function reset(this)
            %RESET  Reset a probe
            
            this.IsSet = false;
        end
        %-----------------------------------------------------------------------
        function setData(this, val)
            %setData Set the data of the probe

            if this.IsSet
                error(generatemsgid('AlreadySet'), ...
                    'Data for probe %s is already set', this.Name)
            else
                this.Data = val;
                this.IsSet = true;
            end
        end
        %-----------------------------------------------------------------------
        function val = getData(this)
            %getData Get the data of the probe

            if ~this.IsSet
                error(generatemsgid('NotSet'), ...
                    'Data for probe %s is not set', this.Name)
            else
                val = this.Data;
            end
        end
        %-----------------------------------------------------------------------
        function description = getDescription(this)
            %getDescription Get the description of the probe
            description = this.Description;
        end        
    end
    %===========================================================================
    % Public  Methods
    methods 
        function set.Name(this,value)
            propName = 'Name';
            validateattributes(value,...
                {'char'},...
                {'vector','row'},...
                [class(this) '.' propName],...
                propName);
            this.Name = value;
        end
        %-----------------------------------------------------------------------        
        function set.Description(this,value)
            propName = 'Description';
            if ~isempty(value)
                validateattributes(value,...
                    {'char'},...
                    {'vector','row'},...
                    [class(this) '.' propName],...
                    propName);
            end
            this.Description = value;
        end                    
    end
    
end
