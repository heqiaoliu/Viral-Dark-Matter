classdef (Hidden = true) ProductInfo
    %PRODUCTINFO provides product information for PIL area
    %   PRODUCTINFO provides product information for PIL area
    %
    %   This is an undocumented class. Its methods and properties are likely to
    %   change without warning from one release to the next.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.8.4 $
    
    properties(Constant = true)
        productId = 'PIL';
    end
    
    methods(Static = true)
        function error(component, messageId, varargin)
            fullId = [rtw.pil.ProductInfo.productId ':' component ':' messageId];
            try
                DAStudio.error(fullId, varargin{:});
            catch e
                e.throwAsCaller;
            end
        end
        
        function warning(component, messageId, varargin)
            fullId = [rtw.pil.ProductInfo.productId ':' component ':' messageId];
            DAStudio.warning(fullId, varargin{:});
        end
        
        function [id, msg] = message(component, messageId, varargin)
            fullId = [rtw.pil.ProductInfo.productId ':' component ':' messageId];
            [msg id] = DAStudio.message(fullId, varargin{:});
        end
    end
end
