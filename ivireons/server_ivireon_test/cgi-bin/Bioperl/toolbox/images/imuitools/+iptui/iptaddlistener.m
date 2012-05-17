% This undocumented class may be removed in a future release.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/13 17:36:51 $

classdef iptaddlistener < handle
    
    properties (Dependent)
        Enabled
    end
    
    properties (Access = private)
        ListenerHandles
    end
    
    methods

        %---------------------------------------
        function this = iptaddlistener(varargin)
            %iptaddlistener Create listener object.
            
            h = varargin{1};
            this.ListenerHandles = addlistener(h(1),varargin{2:end});
            for i = 2:numel(h)
                this.ListenerHandles(i) = addlistener(h(i),varargin{2:end});
            end
            
        end
        
        %--------------------
        function delete(this)
            %delete Delete listener.
            
            % When this object is destroyed, we explicity destroy all of
            % the created listeners.  We need to explicity destroy them
            % because the ADDLISTENER helper function creates additional
            % references to the listener objects it creates.  This breaks
            % "scope-based" cleanup of the listeners.
            delete(this.ListenerHandles);
            
        end
        
        %-------------------------------------
        function set.Enabled(this, newEnabled)
            %set.Enabled Set boolean enabled state.
            
            if isa(this.ListenerHandles(1), 'handle.listener')
                if newEnabled
                    newEnabled = 'on';
                else
                    newEnabled = 'off';
                end
            end
            for i = 1:numel(this.ListenerHandles)
                this.ListenerHandles(i).Enabled = newEnabled;
            end
        end
        
        %-----------------------------------
        function enabled = get.Enabled(this)
            %get.Enabled Get boolean enabled state.
            if isa(this.ListenerHandles(1), 'handle.listener')
                enabled = strcmpi(this.ListenerHandles(1).Enabled, 'on');
            else
                enabled = this.ListenerHandles(1).Enabled;
            end
        end
        
        %--------------------------------------------
        function setEnabledProperty(these,newEnabled)
            %setEnableProperty Sets Enabled property for arrays of objects.

            % we need this method because we cannot call set.Enabled or
            % get.Enabled on arrays of iptaddlistener objects.
            for i = 1:numel(these)
                these(i).Enabled = newEnabled;
            end
            
        end
        
    end
    
end % iptaddlistener
