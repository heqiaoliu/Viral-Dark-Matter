classdef BusItem < slctrlguis.sigselector.AbstractItem
    %
    
	% Class definition for @BusItem - the item to show bus signals in
	% signal viewer widget
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:25:59 $
    
    properties
        Hierarchy
    end
    
    methods
        % Constructor
        function obj = BusItem
            obj = obj@slctrlguis.sigselector.AbstractItem();
            obj.Hierarchy = [];
        end
        % GET/SET for Hierarchy        
        function obj = set.Hierarchy(obj,val)
            if isempty(val) || isstruct(val)
                obj.Hierarchy = val;
            else
                DAStudio.error('Slcontrol:sigselector:BusItemInvalidHierarchy');
            end
        end
    end
    
end

