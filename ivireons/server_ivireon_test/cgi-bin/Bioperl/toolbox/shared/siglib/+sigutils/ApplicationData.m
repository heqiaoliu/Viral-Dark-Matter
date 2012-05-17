classdef ApplicationData < handle
%ApplicationData Define the ApplicationData class.
%   H = sigutils.ApplicationData creates an ApplicationData class for
%   storing application specific data.  The ApplicationData class can be
%   used as a stand alone object to store data or as a superclass to add
%   methods to store data directly on the subclass.
%
%   ApplicationData methods:
%       getAppData - Get the application data for the specified field.
%       isAppData  - Returns true if the application data exists.
%       rmAppData  - Remove the application data for the specified field.
%       setAppData - Set the application data for the specified field.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/03/30 23:57:42 $
    
    properties (Access = private)
        
        % Property to store the actual data.  This will be in the normal HG
        % application style of storing the data in a structure with the
        % keys passed to the functions being the fieldnames of the
        % structure.  We use the _ at the end to avoid name collision
        % because even private properties can collide in MATLAB.
        ApplicationData_ = struct;
    end
    
    methods
        
        function b = isAppData(this, varargin)
%isAppData Returns true if the data exists for the specified field.
%   isAppData(H, KEY1, KEY2, etc.) Returns true if the data exists for the
%   fields specified by KEY1, KEY2, etc.  KEY1, KEY2, etc. must be valid
%   structure field names and there can be any number of key values.
            
            data = this.ApplicationData_;
            b    = true;
            
            % Loop over the fields until we run out of them or we find one
            % missing.  When we find one missing, return early with false.
            while ~isempty(varargin)
                if isfield(data, varargin{1})
                    data = data.(varargin{1});
                    varargin(1) = [];
                else
                    b = false;
                    return;
                end
            end
        end
        
        function rmAppData(this, varargin)
%rmAppData Remove the application data for the specified field.
%   rmAppData(H, KEY1, KEY2, etc.) Removes the application data for the
%   fields specified by KEY1, KEY2, etc.  KEY1, KEY2, etc. must be valid
%   structure field names and there can be any number of key values.
            
            % Remove the field from the terminal node and save it back into
            % the application data.
            if length(varargin) == 1
                this.ApplicationData_ = rmfield(this.ApplicationData_, varargin{1});
            else
                setAppData(this, varargin{1:end-1}, ...
                    rmfield(getAppData(this, varargin{1:end-1}), varargin{end}));
            end
        end
        
        function value = getAppData(this, varargin)
%getAppData Get the application data for the specified field.
%   getAppData(H, KEY1, KEY2, etc.) Returns the application data for the
%   fields specified by KEY1, KEY2, etc.  KEY1, KEY2, etc. must be valid
%   structure field names and there can be any number of key values.
            
            value = this.ApplicationData_;
            for indx = 1:length(varargin)
                value = value.(varargin{indx});
            end
        end
        
        function setAppData(this, varargin)
%setAppData Set the application data for the specified field.
%   setAppData(H, KEY1, KEY2, etc., VALUE) Save VALUE with the keys
%   specified by KEY1, KEY2, etc.  KEY1, KEY2, etc. must be valid structure
%   field names and there can be any number of key values.
            
            % Get the data to use and the field in the normal app data
            start = varargin{1};
            value = varargin{end};
            
            if length(varargin) > 2,
                
                % Find the path and build up the structure using setfield.
                if isfield(this.ApplicationData_, start),
                    olddata = this.ApplicationData_.(start);
                else
                    olddata = [];
                end
                value = setfield(olddata, varargin{2:end-1}, value); %#ok<SFLD>
            end
            
            this.ApplicationData_.(start) = value;
        end
    end
    
    % Add original function names as hidden methods to match HG api without
    % necessarily promoting its use.
    methods (Hidden)
        function b = isappdata(this, varargin)
            b = isAppData(this, varargin{:});
        end
        function app = getappdata(this, varargin)
            app = getAppData(this, varargin{:});
        end
        function setappdata(this, varargin)
            setAppData(this, varargin{:});
        end
        function rmappdata(this, varargin)
            rmAppData(this, varargin{:});
        end
    end
end

% [EOF]
