classdef TextData < uiscopes.CoreData
    %TextData   Define the TextData class.
    %
    %   TextData methods:
    %       setData - Set a data name/value pair.
    %       rmData  - Remove a data name/value pair.
    %
    %   TextData properties:
    %       DataMap - 

    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/04/27 19:53:32 $

    properties (Access = protected)

        %DataMap   Holds all the data name/value pairs
        DataMap;
        
        %RunningDataWidth Store the data and name widths.  Use them as the
        %starting points for determining how wide to make the data display.
        %This is to avoid flicker when data lengths change during playback.
        RunningDataWidth = 1;
        RunningNameWidth = 1;
    end

    methods

        function this = TextData
            %TextData   Construct the TextData class.
            
            % Create a map object to store the data.
            this.DataMap = containers.Map;

        end
        
        function setData(this, name, data, fmt)
            %setData Set data name/value pairs
            %   setData(H, NAME, DATA) Store the values in DATA with the
            %   tag NAME.  NAME is used in the display to identify the
            %   data.
            %
            %   setData(H, NAME, DATA, FMT) Specify the format to be used
            %   when converting the data to a string for display.  FMT is
            %   %s for strings and %g for all other data by default.
            %
            %   See also rmData.
            
            % Consider using a containers.Map object instead of a structure
            % here.
                        
            if nargin < 4
                if ischar(data)
                    fmt = '%s';
                else
                    fmt = '%g';
                end
            end
            
            % Save the data and the format into a structure.
            pair.Data   = data;
            pair.Format = fmt;
            
            % Add the structure to the hashmap.
            this.DataMap(name) = pair;
        end
        
        function rmData(this, name)
            %rmData(H, NAME) Remove the data specified by NAME.
            
            % Only call remove if the key exists.
            if this.DataMap.isKey(name)
                this.DataMap.remove(name);
            end
        end
        
        function text = toText(this)
            %toText   Convert the data to text for display.
            
            text = '';
            
            allData = this.DataMap;
            fields = keys(allData);
            data = cell(length(fields), 1);
            
            % Calculate the lengths of the names and data after converting
            % the data to a string.
            dataWidth = this.RunningDataWidth;
            nameWidth = this.RunningNameWidth;
            for indx = 1:length(fields)
                field = allData(fields{indx});
                
                % Convert the data to string format.
                fmt = field.Format;
                if ischar(fmt)
                    data{indx} = sprintf(fmt, field.Data);
                elseif isnumeric(fmt)
                    data{indx} = sprintf(['%.' num2str(fmt) 'g'], field.Data);
                elseif isa(fmt, 'function_handle')
                    data{indx} = fmt(field.Data);
                else
                    error('spcuilib:scopeextensions:TextData:toText:InvalidFormat', ...
                        'Format must be a valid sprintf format, a number or a function handle.');
                end
                
                % Calculate the width of the largest data/name.
                dataWidth = max(dataWidth, length(data{indx}));
                nameWidth = max(nameWidth, length(fields{indx}));
            end
            
            % Convert the name and data to 'name:data' format.
            for indx = 1:length(fields)
                text = sprintf(['%s%' num2str(nameWidth+2) 's %-' num2str(dataWidth) 's\n'], ...
                    text, [fields{indx} ':'], data{indx});
            end
            
            if ~isempty(text)
                text(end) = [];
            end
            
            this.RunningNameWidth = nameWidth;
            this.RunningDataWidth = dataWidth;
            
        end
    end
end

% [EOF]
