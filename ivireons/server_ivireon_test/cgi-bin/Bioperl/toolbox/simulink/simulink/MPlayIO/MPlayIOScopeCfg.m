classdef MPlayIOScopeCfg < scopeextensions.MPlayScopeCfg
    % MPlayIOScopeCfg: This extends from MPlayScopeCfg class.
    % and overwrites its getCloseRequestFcn() to hide the 
    % mplay instead of deleting it when the figure is closed.
    %  
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.10.1 $  $Date: 2009/06/16 05:33:36 $
 
    methods
 
        function this = MPlayIOScopeCfg(varargin)
            %MPlayIOScopeCfg   Construct the MPlayIOScopeCfg class      
            this@scopeextensions.MPlayScopeCfg(varargin{:});            
        end
        
        function closeFcn = getCloseRequestFcn(this, hScope)
            % Hide the figure when closed.
            closeFcn = @(h, ev) set(hScope.Parent, 'Visible', 'off');
        end
    end
end
 
% [EOF]

