function [allProps, allValues] = convertToPVArrays(varargin)
%convertToPVArrays Convert a variable argument list into cell arrays of properties and values.
% [allProps, allValues] = convertToPVArrays(varargin) Creates a cellarray of
% properties and property values from the input arguments.  All input properties have
% to be strings.
%  Input parameters:
%    Property-value pairs 
%    Pairs of cells       The first cell contains the properties, the second cell
%                         contains the values.
%    Structures           The properties are given by the field names, the values are 
%                         given by the field values.
   

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/02/25 08:01:52 $

% Create a cell array of properties that are being passed.
index = 1;
allProps = {};
allValues = {};

while index <= numel(varargin)
    switch class(varargin{index})
        case 'char'
            % varargin{index} is the property and varargin{index+1} is the value.
            if (index + 1 > numel(varargin))
                error('distcomp:distcomppvparser:invalidPVPair', ...
                      'Invalid param-value pairs specified.');
            end
            prop = varargin{index};
            value = varargin{index+1};
            
            allProps = {allProps{:} prop}; %#ok<*CCAT>
            allValues = {allValues{:} value};
            
            % Update index.
            index = index+2;
        case 'cell'
            % varargin{index} is a cell array of strings and
            % varargin{index+1} is a cell array of the corresponding values.
            % The number of properties must match the number of values
            if (index + 1 > numel(varargin))
                error('distcomp:distcomppvparser:invalidPVPair', ...
                      'Invalid param-value pairs specified.');
            end
            prop = varargin{index};
            value = varargin{index+1};
            if ~iscellstr(prop)
                error('distcomp:distcomppvparser:invalidPVPair', ...
                      'Invalid param-value pairs specified.');
            end
            if (numel(prop) ~= numel(value))
                error('distcomp:distcomppvparser:invalidPVPair', ...
                      'Invalid param-value pairs specified.');
            end
            
            % Concatenate properties and values
            allProps = {allProps{:} prop{:}};
            allValues = {allValues{:} value{:}};
            
            % Update index.
            index = index+2;
        case 'struct'
            % The fieldnames are the properties and the field values are the
            % property values.
            
            % Concatenate properties.
            propStruct = varargin{index};
            prop = fieldnames(propStruct);
            % Concatenate values.
            value = struct2cell(propStruct);
            
            allProps = {allProps{:} prop{:}};
            allValues = {allValues{:} value{:}};
            
            % Update index.
            index = index+1;
        otherwise
            error('distcomp:distcomppvparser:invalidPVPair', ...
                  'Invalid param-value pairs specified.');
    end % End of switch
end % End of while
