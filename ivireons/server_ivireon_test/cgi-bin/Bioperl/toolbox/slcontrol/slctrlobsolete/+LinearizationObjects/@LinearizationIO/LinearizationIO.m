classdef LinearizationIO
    %
    
    % Load old UDD LinearizationIO objects
    
    %  Author(s): John Glass
    %  Revised:
    % Copyright 1986-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:36:00 $
    
    % PUBLIC PROPERTIES
    properties
        Active = 'on';
        Block = '';
        OpenLoop = 'off';
        PortNumber = 1;
        Type = 'in';
        Description = '';
    end
    % PUBLIC METHODS
    methods (Static = true)
        function obj = loadobj(obj_old)
            obj = linearize.IOPoint;
            obj.Active = obj_old.Active;
            obj.Block = obj_old.Block;
            obj.OpenLoop = obj_old.OpenLoop;
            obj.PortNumber = obj_old.PortNumber;
            obj.Type = obj_old.Type;
            obj.Description = obj_old.Description;
        end
    end
end