classdef SignalItem < slctrlguis.sigselector.AbstractItem
    %
    
	% Class definition for @SignalItem - the item to show regular signals in
	% signal viewer widget
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:08 $
    
    properties
        Selected        
    end
    properties (Hidden = true, Transient = true)
        TreeID
    end
    
    
    methods
        % Constructor
        function obj = SignalItem()
            obj = obj@slctrlguis.sigselector.AbstractItem();
            obj.Selected = false;
        end
        % SET for Selected
        function obj = set.Selected(obj,val)
            if islogical(val)
                obj.Selected = val;
            else
                DAStudio.error('Slcontrol:sigselector:SignalItemInvalidSelected');
            end
        end
    end
    
end

