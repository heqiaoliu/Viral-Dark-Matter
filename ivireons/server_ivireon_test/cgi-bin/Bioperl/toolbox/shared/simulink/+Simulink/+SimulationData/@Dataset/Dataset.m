%Dataset  Create a Dataset object.
%   The Simulink.SimulationData.Dataset object is used to store logged data
%   elements.  The Dataset class provides a way to group
%   Simulink.SimulationData.Element objects in a single object and provides
%   searching capabilities.
%
%   See also Simulink.SimulationData.Element, Dataset/find, Dataset/concat,
%   Dataset/getElement, Dataset/getLength, Dataset/addElement

% Copyright 2009-2010 The MathWorks, Inc.

classdef Dataset < Simulink.SimulationData.Element                   
    
    %% Public Methods
    methods
        
        function elementVal = getElement(this,idx)
        % Get an individual element in the Dataset based on element index.
        
            % Only support scalars
            if length(idx) > 1 || length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidDatasetGetElement');                
            else
                try
                    elementVal = this.Elements{idx};
                    if isa(elementVal, 'Simulink.SimulationData.TransparentElement')
                        elementVal = elementVal.Values;
                    end
                catch me
                    DAStudio.error('Simulink:util:InvalidDatasetElementIndex');
                end
            end
        end
       %% -----------------------------------------------------------------      
                        
        function res = getLength(this)
        % Get the number of elements in the Dataset.
                    
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidDatasetArray');
            end
            
            res = length(this.Elements);
        end
       %% -----------------------------------------------------------------
        
        function ret = find(this, searchArg, varargin)
        % find(searchArg, vargin)
        % Find an element based on Name or BlockPath. 
        %
        % NAME-BASED FIND: If searchArg is a character array and the option
        % '-blockpath' is not used, find will search based on Element Name.
        %
        % BLOCK-BASED FIND: If searchArg is a
        % Simulink.SimulationData.BlockPath object, find will search based
        % on Element BlockPath. Alternatively, the option '-blockpath' may
        % be used to interpret a character array as a blockpath.
        %
        % When searchArg is a single character array or BlockPath, the  
        % returned value will be a single Element if only 1 element is  
        % found or a Dataset if more than 1 Element of this name exists.
        %
        % If searchArg is a cell array (containing 1 string or BlockPath), 
        % the returned value will always be a Dataset and may contain 1
        % Element.
        %
        % EXAMPLES:
        %
        %   >> dsmout.find('my_name')
        %   ans = 
        %   Simulink.SimulationData.DataStoreMemory ...
        %   
        %   >> dsmout.find('my_dup_name')
        %   ans = 
        %   Simulink.SimulationData.Dataset ...
        %
        %   >> dsmout.find({'my_name'})
        %   ans = 
        %   Simulink.SimulationData.Dataset ...
        %
        %   >> dsmout.find(Simulink.SimulationData.BlockPath(gcb))
        %   OR
        %   >> dsmout.find(gcb, '-blockpath')
        %   ans = 
        %   Simulink.SimulationData.DataStoreMemory ...

            %% Only valid for scalar objects
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidDatasetArray');
            end
            
            %% Initialize a Dataset to return
            ret = Simulink.SimulationData.Dataset;

            %% Argument may be a cell array, a string or a BlockPath
            if(iscellstr(searchArg) && length(searchArg) == 1)
                paths = searchArg;
            elseif(ischar(searchArg))
                paths = {searchArg};
            elseif(iscell(searchArg) && length(searchArg) == 1 && ...
                   isa(searchArg{1}, 'Simulink.SimulationData.BlockPath'))
                paths = searchArg;
            elseif(isa(searchArg, 'Simulink.SimulationData.BlockPath'))
                paths = {searchArg};
            else
                DAStudio.error('Simulink:util:InvalidDatasetFind');
            end
            
            %% Check the number of optional arguments           
            optArg = size(varargin,2);
            if optArg > 1
                DAStudio.error('Simulink:util:InvalidDatasetFindArgs');
            end

            %% Read the optional arguments
            for idx = 1 : optArg
                if strcmpi(varargin{idx}, '-blockpath')
                % Option to treat character arrays as blockpaths
                    if ischar(paths{1})
                        paths{1} = Simulink.SimulationData.BlockPath(paths{1});
                    end
                else
                % Unknown option
                    DAStudio.error('Simulink:util:InvalidDatasetFindArgs');
                end
            end
                
            %% Tokenize string
            bpSearch = isa(paths{1}, 'Simulink.SimulationData.BlockPath');
            if ~bpSearch
                [elementName, remainingPath] = strtok(paths{1}, '.');
            else
                elementName = '';
                remainingPath = '';
            end
            
            %% Find elementName
            for elIndx = 1 : this.getLength()
                curElement = this.Elements{elIndx};
                
                % Name-based search
                if ~bpSearch && strcmp(curElement.Name,elementName)

                    % If there is no more path, add this item
                    if(isempty(remainingPath))
                        ret = ret.addElement(curElement);

                    % Otherwise, recurse into sub-elements
                    elseif(isa(curElement, 'Simulink.SimulationData.Element'))
                        nestedFind = curElement.find({remainingPath}, varargin{:});
                        if ~isempty(nestedFind)
                            ret = ret.concat(nestedFind);
                        end
                    end %elseif

                % Block-based search
                elseif bpSearch
                    if isa(curElement, 'Simulink.SimulationData.BlockData')
                        if curElement.isFromBlock(paths{1})
                            ret = ret.addElement(curElement);
                        end
                    end
                end %if
                
            end %for each element

            %% See if we can return just one element or the whole Dataset
            if(~iscell(searchArg))
                if(ret.getLength() == 1)
                    ret = ret.getElement(1);
                elseif(ret.getLength() == 0)
                    ret = [];
                end
            end

        end
       %% -----------------------------------------------------------------
        
        function this = addElement(this, val, elementName)
        % Add an element to the Dataset. The following types may be added
        % to a Dataset:
        %   (1) Any sub-class of Simulink.SimulationData.Element
        %   (2) A timeseries object
        %   (3) A structure with timeseries objects at the leaves
        %   (4) An 2-d array of real double values with time in first
        %   column
            
            %% Only valid for scalar objects
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidDatasetArray');
            end
            
            % For double array or structure of timeseries, create a 
            % transparent element
            if (isstruct(val) && Simulink.SimulationData.utValidSignalOrCompositeData(val)) || ...
               (isa(val, 'double') && isrealmat(val) && ~iscolumn(val))
                if nargin < 3
                    DAStudio.error('Simulink:util:DatasetAddMissingName');
                end
                el = Simulink.SimulationData.TransparentElement;
                el.Values = val;
                val = el;
            end
                
            % Allow Element or Timeseries
            if(isa(val, 'Simulink.SimulationData.Element') || isa(val, 'timeseries'))
                
                % Add the element
                if(isempty(this.Elements))
                    this.Elements = {val};
                else
                    this.Elements = [ this.Elements {val} ];
                end
                
                % Set the element name
                if nargin > 2
                    this.Elements{end}.Name = elementName;
                end
                
            % Unknown element type
            else
                DAStudio.error('Simulink:util:InvalidDatasetElement');
            end
        end
       %% -----------------------------------------------------------------
                
        function this = concat(this,val)
        % Concatenate the elements from one Dataset to the end of another
        % Dataset
        
            if(isa(val, 'Simulink.SimulationData.Dataset') && ...
               length(val) == 1 && length(this) == 1)

                % Add each element from RHS in order
                for idx = 1 : val.getLength()
                    this = this.addElement(val.Elements{idx});
                end

            else
                DAStudio.error('Simulink:util:InvalidDatasetConcat');
            end

        end
       %% -----------------------------------------------------------------
                
        function disp(this)
        % Display function for Dataset objects.
        
            % See if this a collection
            if length(this) > 1
                Simulink.SimulationData.utNonScalarDisp(this);
                return;
            end
            
            % Print the class name
            mc = metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: help %s">%s</a>\n', mc.Name, mc.Name);
            else
                fprintf('  %s\n', mc.Name);
            end

            % Print the package name
            fprintf('  Package: %s\n\n', mc.ContainingPackage.Name);

            % Print Name and Elements Length
            fprintf('  Characteristics:\n');
            fprintf('              Name: ''%s''\n', this.Name);
            fprintf('    Total Elements: %d\n\n', this.getLength);

            % Display name of each element if there aren't too many
            if this.getLength() <= 12
                fprintf('  Elements:\n');
                for idx = 1 : this.getLength()
                    fprintf('    %d: ''%s''\n', idx, this.Elements{idx}.Name);
                end            
            end
            
            % Help text for access of elements
            if feature('hotlinks')
                fprintf(['\n  Use <a href="matlab: help Simulink.SimulationData' ...
                        '.Dataset/getElement">getElement</a> to access elements' ...
                        ' by index or \n' ...
                        '  <a href="matlab: help Simulink.SimulationData.' ...
                        'Dataset/find">find</a> to access elements by name' ...
                        ' or block path.\n']);
            else
                fprintf('\n  Use getElement to access elements by index or \n');
                fprintf('  find to access elements by name.\n');
            end
            
            % Print links for methods and superclasses
            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ', mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n', mc.Name);
            end

        end
       %% -----------------------------------------------------------------
                                                    
    end % Public Methods

    %% Hidden Methods
    methods (Hidden = true)
        
        function this = utSetElements(this, elements)
        % Utility function to set all the elements of the Dataset in 1
        % call. This function is hidden, as we only use it internally in
        % Simulink logging. Note that no checks are done in this function
        % for efficiency.
        
            this.Elements = elements;
        end
       %% -----------------------------------------------------------------
        
    end
    
    %% Private Properties
    properties (Access = 'private')
        Elements = {};
    end % Private properties    
    
end % Dataset
