% Copyright 2009 The MathWorks, Inc.

classdef DepViewerUIActionScope < handle
    properties 
        ui
        tab
    end
    methods
        function obj=DepViewerUIActionScope(hui, htab)
            obj.ui = hui;
            obj.tab = htab;
            
            obj.ui.beginUIAction();
        end
        function delete(obj)
            obj.ui.endUIAction();
        end
    end
end
