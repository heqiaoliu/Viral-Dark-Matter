classdef AbstractItem
    %
    
	% Class definition for @AbstractItem - the ancestor of all type of
	% items that can be shown in signal viewer widget
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:25:57 $
    
    properties
        Name
        Source
    end    
    methods
        % Constructor
        function obj = AbstractItem()
            obj.Name = '';
            obj.Source = [];
        end
        % SET methods
        function obj = set.Name(obj,val)
            if ischar(val)
                obj.Name = val;
            else
                DAStudio.error('Slcontrol:sigselector:ItemInvalidName');
            end
        end
        function obj = set.Source(obj,val)
            if isempty(val) || isstruct(val)
                obj.Source = val;
            else
                DAStudio.error('Slcontrol:sigselector:ItemInvalidSource');                
            end
        end
    end
    methods
        obj = setNameFromSource(obj);
    end
end

