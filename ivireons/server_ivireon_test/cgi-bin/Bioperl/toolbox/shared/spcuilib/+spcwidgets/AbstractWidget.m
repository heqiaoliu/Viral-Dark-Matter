classdef (CaseInsensitiveProperties = true) AbstractWidget < hgsetget
    %AbstractWidget   Define the AbstractWidget class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2009/08/14 04:06:22 $

    properties (GetAccess = private, SetAccess = private)              
        WidgetListeners;
        WidgetHandle;
    end

    methods

        function varargout = addlistener(this, varargin)
            %ADDLISTENER Add a listener.
            
            l = uiservices.addlistener(this, varargin{:});
            
            if isempty(this.WidgetListeners)
                this.WidgetListeners = l;
            else
                this.WidgetListeners = [this.WidgetListeners; l];
            end
            
            if nargout > 0
                varargout = {l};
            end

        end
        
        function val = isprop(this, prop)
            val = ~isempty(findprop(this,prop));
        end                                    
    end   
end

% [EOF]
