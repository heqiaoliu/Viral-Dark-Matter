classdef (Hidden = true) ProductInfo
    %PRODUCTINFO Product information for Targets Common area
    %   PRODUCTINFO Product information for Targets Common area
    %
    %   This is an undocumented class. Its methods and properties are likely to
    %   change without warning from one release to the next.
    
    %   Copyright 2007-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:38:47 $
    
    properties(Constant = true)
        productId = 'TargetCommon';
    end
    
    methods(Static = true)
        function error(component, messageId, varargin)
            fullId = [TargetCommon.ProductInfo.productId ':' component ':' messageId];
            try
                DAStudio.error(fullId, varargin{:});
            catch e
                e.throwAsCaller;
            end
        end
        
        function warning(component, messageId, varargin)
            fullId = [TargetCommon.ProductInfo.productId ':' component ':' messageId];
            DAStudio.warning(fullId, varargin{:});
        end
        
        function [id, msg] = message(component, messageId, varargin)
            fullId = [TargetCommon.ProductInfo.productId ':' component ':' messageId];
            [msg id] = DAStudio.message(fullId, varargin{:});
        end
    end
end
