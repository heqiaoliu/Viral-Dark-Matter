classdef AbstractSystemObjectScopeCfg < uiscopes.AbstractScopeCfg
    %AbstractSystemObjectScopeCfg   Define the AbstractSystemObjectScopeCfg class.
    
    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.1.8.2 $  $Date: 2010/05/20 03:07:33 $  
    
    
    methods
        
        function this = AbstractSystemObjectScopeCfg(varargin)
            %AbstractSystemObjectScopeCfg   Construct the AbstractSystemObjectScopeCfg class
            this@uiscopes.AbstractScopeCfg(varargin{:});            
        end
        
        function b = isVisibleAtLaunch(~)
            b = false;
        end
        
        function crFcn = getCloseRequestFcn(~, hScope)
            crFcn = @(h, ev) lochide(hScope);
        end
                
        function hiddenTypes = getHiddenTypes(~)
            hiddenTypes = {'Sources', 'Visuals'};
        end
        
        function scopeTitle = getScopeTitle(~, hScope)
            scopeTitle = getAppName(hScope);
            if ~isempty(hScope.DataSource) && ~isempty(hScope.DataSource.SystemObject)
                scopeTitle = hScope.DataSource.SystemObject.Name;
            end
        end
        
        function b = isSerializable(~)
            b = false;
        end
    end
end

% -------------------------------------------------------------------------
function lochide(hscope)
%HIDE  Hides the application window.

sourceObject = getExtInst(hscope,'Sources','Streaming');
systemObject = sourceObject.SystemObject;
if isempty(systemObject)
    visible(hscope, 'off');
else
    hide(systemObject);
end
end

% [EOF]
