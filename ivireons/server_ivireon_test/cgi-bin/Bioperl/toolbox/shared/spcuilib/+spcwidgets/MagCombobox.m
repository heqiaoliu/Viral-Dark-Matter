classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true)  MagCombobox < spcwidgets.AbstractWidget
    %MagCombobox   Define the MagCombobox class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:46:21 $

    properties
        Parent;
        Enable;
        Mag;
        SelectedItem;
        Visible;
        Tag;
    end
    properties (GetAccess = private, SetAccess = private)       
        JavaHandle;
        ApiHandle;                    
    end

    methods
        function h = MagCombobox(varargin)
            %MagCombobox Constructor for MagCombobox object.
            %
            % NOTE: This component relies on Image Processing Toolbox.
            %       Do not use unless IPT is available to customers.            
            
            mlock;
            % Was a "singleton first arg" passed?
            % If so, it's the parent handle
            if mod(nargin,2)==1
                h.Parent=varargin{1};
                varargin=varargin(2:end);
            end
            if isempty(h.Parent)
                % No parent passed, or handle was empty
                %
                % Try to find an existing toolbar in the current figure
                % A new figure may need to be opened (via call to gcf)
                % A new toolbar may need to be created
                parent = findobj(gcf,'type','uitoolbar');
                if isempty(parent)
                    parent = uitoolbar;
                end
                h.Parent = parent;
            end
            
            % Instantiate Java widget
            
            % xxx bug fix to force HG flush prior to instantiating Java widget.  Java
            % knows nothing about HG's queue, and the Java widget could appear in the
            % wrong position on the toolbar.
            drawnow;
            
            [h.JavaHandle,h.ApiHandle] = createMagComboBox(h.Parent);
            if ~isempty(varargin)
                set(h,varargin{:});
            end
        end    
        
        %------------------------------------------------------
        function val = setAccess(this,val,method, translate)
            if translate
                if strcmpi(val, 'on')
                    javaValue = true;
                else
                    javaValue = false;
                end
            else
                javaValue = val;
            end
            
            cb = this.JavaHandle;
            if isjava(cb)
                javaMethodEDT(method, cb, javaValue);
                %     set(this.JavaHandle,prop,val);
            else
                error('spcuilib:spcwidgets:MagCombobox:schema',...
                    'Invalid handle.');
            end
        end
        
        function val = getAccess(this,val,method, translate)
            cb = this.JavaHandle;
            if isjava(cb)
                val = javaMethodEDT(method, cb);
                %     val = get(cb,prop);
                % else
                %     val = '<invalid>';  % invalid handle
            end
            
            if translate
                if val
                    val = 'on';
                else
                    val = 'off';
                end
            end
        end
        
        %------------------------------------------------------
        function set.Enable(this,val)
            method = 'setEnabled';
            translate = true;
            this.Enable = setAccess(this,val,method, translate);
        end
        
        %------------------------------------------------------
        function val = get.Enable(this)
            method = 'isEnabled';
            translate = true;
            val = getAccess(this,this.Enable,method, translate);
        end
            
        %------------------------------------------------------
        function set.Mag(this,val)
            method = 'setMag';
            translate = false;
            this.Mag = setAccess(this,val,method, translate);
        end
        
        %------------------------------------------------------
        function val = get.Mag(this)
            method = 'getMag';
            translate = false;
            val = getAccess(this,this.Mag,method, translate);
        end
        %------------------------------------------------------
        function set.SelectedItem(this,val)
            method = 'setSelectedItem';
            translate = false;
            this.SelectedItem = setAccess(this,val,method, translate);
        end
        
        %------------------------------------------------------
        function val = get.SelectedItem(this)
            cb = this.JavaHandle;
            if isjava(cb)
                val = javaMethodEDT('getSelectedItem', cb);
                if isempty(val)
                    val = '';
                end
            else
                val = '';
            end
        end
        
        %------------------------------------------------------
        function val = get.Visible(this)
            method = 'isVisible';
            translate = true;
            val = getAccess(this,this.Enable,method, translate);
        end
            
        %------------------------------------------------------
        function set.Visible(this,val)
            method = 'setVisible';
            translate = true;
            this.Visible = setAccess(this,val,method, translate);
        end
        
        %------------------------------------------------------
        function delete(h)
            %DELETE Delete Java widget.
            
            % Handle could have been "pulled out" from under us
            % the only object passed in here is a Java-based combobox no need to change
            % the call here to ishghandle
            if isjava(h.JavaHandle) && ishandle(h.Parent)
                % Delete the Java-based combobox widget by deleting its parent
                jc = get(h.Parent,'JavaContainer');
                cp = jc.getComponentPeer;
                cp.remove(h.JavaHandle.getParent);
                
                %theWidget = javacomponent(h.cb);
                %delete(theWidget);
            end
            
            % Clear all private handles
            h.JavaHandle=[];
            h.APIHandle=[];
            
        end
        %------------------------------------------------------
        function y = isHandle(h)
            %ISHANDLE True if MagCombobox is managing a valid widget.            
            y = isjava(h.JavaHandle);            
        end
        %------------------------------------------------------
        function setScrollPanel(hSP,cb)
            %setScrollPanel Attach mag combo box to a scroll panel.
            
            if ~isempty(hSP.ApiHandle)
                hSP.ApiHandle.setScrollpanel(cb);
            end            
        end
        %------------------------------------------------------
    end

end

% [EOF]
