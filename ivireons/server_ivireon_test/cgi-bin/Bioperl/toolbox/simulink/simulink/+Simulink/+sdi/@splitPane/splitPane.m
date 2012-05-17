classdef splitPane < handle
        
    % Copyright 2009-2010 The MathWorks, Inc.
    
    properties (SetObservable = true, AbortSet = true)
        parent;
        leftUpPane;
        rightDownPane;
        orientation;
        dividerWidth;
        dividerColor;
        dividerLocation;
        dividerLocationUpdate;
        hDivider;
        hComponent;
        minimumLeft;
        minimumRight;
        divPos1;
        leftCallback;
        rightCallback;
        clickedCallback;
        paneVisibility;
    end
    
    methods
        function this = splitPane(varargin)
            if nargin < 5
                error('All inputs are required at this time.')
            end
            
            this.parent = varargin{1};
            this.orientation = varargin{2};
            this.dividerWidth = varargin{3};
            this.dividerColor = varargin{4};
            this.dividerLocation = varargin{5}; 
            this.paneVisibility{1} = 'on';
            this.paneVisibility{2} = 'on';
            
            if (nargin > 5)
                this.minimumLeft = varargin{6};                
            end
            
            if (nargin > 6)
                this.minimumRight = varargin{7};                
            end
                        
            addlistener(this,'dividerLocation','PostSet',...
                        @this.handlePropertyEvents);
            addlistener(this,'dividerLocationUpdate','PostSet',...
                        @this.handlePropertyEvents);
            
            if strcmpi(this.orientation(1),'v')
                % vertical
                divPos = [0,this.dividerLocation,1,this.dividerWidth];
                leftUpPos = [0,0,1,this.dividerLocation];
            else
                % horizontal
                divPos = [this.dividerLocation,0,this.dividerWidth,1];
                leftUpPos = [0,0,this.dividerLocation,1];
            end
            
            this.addSplitter(divPos);
            this.divPos1 = divPos;
                        
            % Recompute the sub-containers dimensions now that the divider is displayed
            divPos = get(this.hDivider,'position');
            if strcmpi(this.orientation(1),'v')
                h2PosStart = this.dividerLocation + divPos(4);
                rightDownPos = [0,h2PosStart,1,1-h2PosStart];
            else
                % horizontal
                h2PosStart = this.dividerLocation + divPos(3);
                rightDownPos = [h2PosStart,0,1-h2PosStart,1];
            end
            
            % Prepare the sub-panes
            this.leftUpPane = this.addPane(leftUpPos);
            this.rightDownPane = this.addPane(rightDownPos);
            
        end
        
        function addDivider(this)
            delete(this.hDivider);
            this.addSplitter(this.divPos1);            
        end            
        
        function setVisibility(this, flag)
            set(this.hDivider,'vis', flag);            
        end
        
        function setLeftUpVisible(this, flag)
            set(this.leftUpPane,'vis',flag);
            ch = get(this.leftUpPane, 'children');
            set(ch, 'vis', flag);
        end
        
        function setRightDownVisible(this, flag)
            set(this.rightDownPane, 'vis', flag);
            ch = get(this.rightDownPane, 'children');
            set(ch, 'vis', flag);
        end
        
        function setDividerVisible(this, flag)
            set(this.hDivider,'vis', flag); 
        end
        
        function addSplitter(this, pos)
            
            % create split pane
            if strcmpi(this.orientation(1),'h')
                javaSplit = javax.swing.JSplitPane(javax.swing.JSplitPane.HORIZONTAL_SPLIT);
            else
                javaSplit = javax.swing.JSplitPane(javax.swing.JSplitPane.VERTICAL_SPLIT);
            end
            
            % cache string dictionary
            stringDict = Simulink.sdi.StringDict;
            
            % add arrows
            javaSplit.setOneTouchExpandable(1);

            splitter = javaSplit.getComponent(0);
            
            % Place onscreen at the correct position & size (but still normalized to container)
            [this.hComponent, this.hDivider] = javacomponent...
                                               (splitter, [], this.parent);
            set(this.hDivider, 'tag', 'splitpane divider', 'units', 'norm',...
                'pos', pos);
            
            % useful for finding children which are dividers
            setappdata(this.hDivider, 'Object', this);            
            pause(0.01);
            dvPosPix = getpixelposition(this.hDivider);
            
            if strcmpi(this.orientation(1), 'h')
                newPixelPos = [dvPosPix(1:2) this.dividerWidth dvPosPix(4)];
            else  % =vertical
                newPixelPos = [dvPosPix(1:3) this.dividerWidth];
            end
            setpixelposition(this.hDivider,newPixelPos);
            this.hComponent.DividerSize = this.dividerWidth;
            
            % Set the divider color
            this.hComponent.setBackground(java.awt.Color(this.dividerColor(1),...
                                          this.dividerColor(2),               ...
                                          this.dividerColor(3)));
            
            this.hComponent.ComponentResizedCallback = @this.dividerResizedCallback;
            this.hComponent.MouseDraggedCallback     = @this.dividerClickedCallback;
            this.hComponent.MouseReleasedCallback = @this.dividerReleasedCallback;
            this.hComponent.MouseClickedCallback = @this.dividerClickedCallback;
            
            
            awtListeners = this.hComponent.getToolkit.getAWTEventListeners;
            
            count = length(awtListeners);
            
            % find the buggy AWTEventListner and remove it
            for i = 1:count
                test = strcmpi(class(awtListeners(i).getListener),...
                               'javax.swing.plaf.basic.BasicLookAndFeel$AWTEventHelper');
                if test
                    this.hComponent.getToolkit.removeAWTEventListener(awtListeners(i).getListener);
                    break;
                end
            end
            
            import java.awt.*
            if this.orientation(1)=='h'
                jLeft  = splitter.getComponent(0);
                jRight = splitter.getComponent(1);
                jLeft.setBackground(java.awt.Color(this.dividerColor(1),...
                                    this.dividerColor(2),               ...
                                    this.dividerColor(3)));
                jRight.setBackground(java.awt.Color(this.dividerColor(1),...
                                    this.dividerColor(2),               ...
                                    this.dividerColor(3)));
                
                jLeft = handle(jLeft, 'callbackproperties');
                jRight = handle(jRight, 'callbackproperties');
                set(jLeft, 'ActionPerformedCallback', {@this.dividerActionCallback,...
                    jRight, stringDict.splitLeft, jLeft}, 'ToolTipText',           ...
                    stringDict.splitHideLeft);
                set(jRight,'ActionPerformedCallback', {@this.dividerActionCallback,...
                    jLeft, stringDict.splitRight, jRight}, 'ToolTipText',          ...
                    stringDict.splitHideRight);
                jLeft.setCursor(Cursor(Cursor.HAND_CURSOR));   
                jRight.setCursor(Cursor(Cursor.HAND_CURSOR));  
            else
                jTop = splitter.getComponent(0);
                jBot = splitter.getComponent(1);
                jTop.setBackground(java.awt.Color(this.dividerColor(1),...
                                    this.dividerColor(2),               ...
                                    this.dividerColor(3)));
                jBot.setBackground(java.awt.Color(this.dividerColor(1),...
                                    this.dividerColor(2),               ...
                                    this.dividerColor(3)));
                jTop = handle(jTop, 'callbackproperties');
                jBot = handle(jBot, 'callbackproperties');
                set(jTop,'ActionPerformedCallback', {@this.dividerActionCallback,...
                    jBot, stringDict.splitTop, jTop}, 'ToolTipText', stringDict.splitHideTop);
                set(jBot,'ActionPerformedCallback',{@this.dividerActionCallback,...
                    jTop, stringDict.splitBottom, jBot}, 'ToolTipText', stringDict.splitHideBottom);
                jTop.setCursor(Cursor(Cursor.HAND_CURSOR));   
                jBot.setCursor(Cursor(Cursor.HAND_CURSOR));   
            end
        end
        
        function setPosition(this, pos)
            this.dividerLocation = pos;
            this.updatePanes();
        end
        
        function addCallbackLeft(this, func)
            this.leftCallback = func;
        end
        
        function addCallbackRight(this, func)
            this.rightCallback = func;            
        end
        
        function addClickedCallback(this, func)
            this.clickedCallback = func;            
        end
        
        % if user just clicks on the divider. Used for snapping
        function dividerClickedCallback(this, s, e)
            % cache string dictionary
            stringDict = Simulink.sdi.StringDict;
            
            % Bring back both arrows
            jLeft = this.hComponent.getComponent(0);
            jRight = this.hComponent.getComponent(1);
            javaMethodEDT('setVisible', jLeft, true);
            javaMethodEDT('setVisible', jRight, true);
                        
            if(this.orientation(1) == 'h')
                jLeft.setToolTipText(stringDict.splitHideLeft);
                jRight.setToolTipText(stringDict.splitHideRight);
            else
                jLeft.setToolTipText(stringDict.splitHideTop);
                jRight.setToolTipText(stringDict.splitHideBottom);
            end     
                    
            % make everything visible
            leftVis = get(this.leftUpPane, 'vis');
            rightVis = get(this.rightDownPane, 'vis');
            
            if strcmpi(leftVis, 'off')
                set(this.leftUpPane, 'vis', 'on');
                this.paneVisibility{1} = 'on';
                ch = get(this.leftUpPane, 'children');
                count = length(ch);
                
                % Show all the children dividers and their children too
                for i = 1:count
                    tag = get(ch(i), 'Tag');
                    if(strcmpi(tag, 'splitpane divider'))
                        obj = getappdata(ch(i), 'Object');
                        obj.showVis();
                    else
                        set(ch(i), 'vis', 'on');
                    end
                end    
                
                this.dividerLocation = 0.6;
                this.dividerLocationUpdate = 0.6;
                this.updatePanes();                
            end
            
            if strcmpi(rightVis, 'off')
                set(this.rightDownPane, 'vis', 'on');
                this.paneVisibility{2} = 'on';
                ch = get(this.rightDownPane, 'children');
                count = length(ch);
                
                % Show all the children dividers and their children too
                for i = 1:count
                    tag = get(ch(i), 'Tag');
                    if(strcmpi(tag, 'splitpane divider'))
                        obj = getappdata(ch(i), 'Object');
                        obj.showVis();
                    else
                        set(ch(i), 'vis', 'on');
                    end
                end
                
                this.dividerLocation = 0.6;
                this.dividerLocationUpdate = 0.6; 
                this.updatePanes();                
            end
            this.dividerResizedCallback(s, e);            
        end
        
        % When mouse is released. 
        function dividerReleasedCallback(this, ~, ~)
            this.dividerLocationUpdate = this.dividerLocation;
        end
        
        
        % When the component is resized. Gets called when figure is resized
        % or divider is dragged
        function dividerResizedCallback(this, varargin)
            try
                pixelPos = getpixelposition(this.hDivider);
                hParent = get(this.hDivider, 'parent');
                parentPixelPos = getpixelposition(hParent);
                parentPixelPos(1:2) = 0;
            catch %#ok
                % Don't error out as someone might have deleted the handle
            end
            
            try
                if strcmpi(this.orientation(1), 'h')
                    % Drag in X direction
                    deltaX = javaMethodEDT('getX', varargin{2});
                    newDvPos = (pixelPos(1) + deltaX - parentPixelPos(1))...
                                / parentPixelPos(3);
                    if ~isempty(this.minimumLeft)
                        minL = this.minimumLeft/parentPixelPos(3);
                    else
                        minL = 0.1;
                    end
                    
                    if ~isempty(this.minimumRight)
                        minR = this.minimumRight/parentPixelPos(3);
                    else
                        minR = 0.1;
                    end
                else  % vertical
                    % Drag in Y direction
                    deltaY = -varargin{2}.getY;
                    newDvPos = (pixelPos(2) + deltaY - parentPixelPos(2))...
                                / parentPixelPos(4);
                    if ~isempty(this.minimumLeft)
                        minL = this.minimumLeft/parentPixelPos(4);
                    else
                        minL = 0.1;
                    end
                    
                    if ~isempty(this.minimumRight)
                        minR = this.minimumRight/parentPixelPos(4);
                    else
                        minR = 0.1;
                    end
                end
                
                newDvPos = max(minL, newDvPos);
                newDvPos = min(1-minR, newDvPos);
                
                % new divider location
                this.dividerLocation = newDvPos;
                drawnow;
                
            catch %#ok
                % when resizing the figure window
                % resize the width of the divider to match initial width
                if strcmpi(this.orientation(1), 'h')
                    width = parentPixelPos(3);
                    dvPos = get(this.hDivider, 'pos');
                    width = this.dividerWidth/width;
                    if(width > 0)
                        set(this.hDivider, 'pos', [dvPos(1:2) width dvPos(4)]);
                    end
                else
                    height = parentPixelPos(4);
                    dvPos = get(this.hDivider, 'pos');
                    height = this.dividerWidth/height;
                    if (height > 0)
                        set(this.hDivider, 'pos', [dvPos(1:3) height]);
                    end
                end
            end
        end
        
        function h = addPane(this, pos)
            % add new pane
            h = uipanel('parent', this.parent, 'units', 'norm',...
                        'position', pos, 'bordertype', 'none', 'tag', 'splitpane');
        end
        
        % event handler
        function handlePropertyEvents(this,src,~)
            switch src.Name
                case 'dividerLocationUpdate'
                    % update the size of panes too
                    this.updatePanes();                    
                case 'dividerLocation'
                    % just update the location of divider
                    if (this.dividerLocation > 1 || this.dividerLocation < 0)
                        this.dividerLocation = 0.6;
                    end
                    
                    dvPos = get(this.hDivider, 'pos');
                    if strcmpi(this.orientation(1), 'h')
                        set(this.hDivider, 'position', ...
                            [this.dividerLocation dvPos(2:4)]);
                    else
                        set(this.hDivider, 'position', ...
                            [dvPos(1) this.dividerLocation dvPos(3:4)]);
                    end    
                    drawnow;
                    
            end
        end
        
        % update pane sizes
        function updatePanes(this)
            drawnow;
            dvPos = get(this.hDivider, 'pos');            
            
            if strcmpi(this.orientation(1), 'h')
                if (1-dvPos(1) > 0)
                    set(this.leftUpPane, 'position', [0,0,dvPos(1),1]);
                    set(this.rightDownPane, 'position', [dvPos(1), 0,...
                        1-dvPos(1), 1]);
                end
            else               
                if (1-dvPos(2) > 0)
                    set(this.leftUpPane, 'position', [0,0,1,dvPos(2)]);
                    set(this.rightDownPane, 'position', [0,dvPos(2),1 ...
                        ,1-dvPos(2)]);
                end
            end
            drawnow;
            
        end
        
        % helper function for making a divider visible
        function showVis(this)
            set(this.hDivider, 'vis', 'on');
            ch1 = get(this.leftUpPane, 'children');
            if ~isempty(this.paneVisibility{1})
                set(this.leftUpPane, 'vis', this.paneVisibility{1});
                set(ch1, 'vis', this.paneVisibility{1});            
            end
            
            if ~isempty(this.paneVisibility{2})
                ch2 = get(this.rightDownPane, 'children');
                set(this.rightDownPane, 'vis', this.paneVisibility{2});
                set(ch2, 'vis', this.paneVisibility{2});
            end
        end
        
        % Divider arrow callback
        function dividerActionCallback(this, ~, ~, varargin)
            try
                % clicked arrow
                str = varargin{2};
                dvPos = this.dividerLocation;                
                minL = 0.1;
                minR = 0.1;
                test = any(strcmp(str, {'right','top'}));
                
                if test
                    flag = (dvPos <= minL);  % flushed left/bottom
                    dvFlush = 0.99;                    
                else  % left/bottom
                    flag = (dvPos >= 1 - minR);  % flushed right/top
                    dvFlush = 0.001;
                end
                if flag  % flushed on the side => move back to center
                    this.dividerLocation = 0.6;
                    dvPos = get(this.hDivider, 'pos');
                    if test
                        set(this.leftUpPane, 'vis', 'on');
                        this.paneVisibility{1} = 'on';
                        ch = get(this.leftUpPane, 'children');
                        count = length(ch);
                        
                        % make all the children visible
                        for i = 1:count
                            tag = get(ch(i), 'Tag');
                            if(strcmpi(tag, 'splitpane divider'))
                                obj = getappdata(ch(i), 'Object');
                                obj.showVis();
                            else
                                set(ch(i), 'vis', 'on'); 
                            end
                        end
                        
                        % reposition panes
                        if strcmpi(this.orientation(1), 'h')
                            set(this.rightDownPane, 'position', [dvPos(1),0,...
                            1-dvPos(1),1]);
                        else
                            set(this.rightDownPane, 'position', [0,dvPos(2),1 ...
                            ,1-dvPos(2)]);
                        end
                        
                        % evaluate left callback if exists
                        if ~isempty(this.leftCallback)
                            feval(this.leftCallback);
                        end                            
                    else
                        set(this.rightDownPane, 'vis', 'on');   
                        this.paneVisibility{2} = 'on';
                        ch = get(this.rightDownPane, 'children');
                        count = length(ch);
                        
                        % make all the children visible
                        for i = 1:count
                            tag = get(ch(i), 'Tag');
                            if(strcmpi(tag, 'splitpane divider'))
                                obj = getappdata(ch(i), 'Object');
                                obj.showVis();
                            else
                                set(ch(i), 'vis', 'on'); 
                            end
                        end
                        
                        % reposition panes                                                
                        if strcmpi(this.orientation(1), 'h')
                            set(this.leftUpPane, 'position', [0,0,dvPos(1),1]);
                        else
                            set(this.leftUpPane, 'position', [0,0,1,dvPos(2)]);
                        end
                        
                        % evaluate right callback if it exists
                        if ~isempty(this.rightCallback)
                            feval(this.rightCallback);
                        end  
                    end
                    % update panes
                    this.dividerLocationUpdate = this.dividerLocation;
                    drawnow();
                    
                    % reset tool tips of arrows
                    newStr = convertPositionHelper(str);
                    javaMethodEDT('setVisible', varargin{1}, true);
                    toolTipText = DAStudio.message('SDI:sdi:splitHideButton',...
                                                    newStr);
                    varargin{1}.setToolTipText(toolTipText);
                    javaMethodEDT('setVisible', varargin{3}, true);
                    
                    toolTipText = DAStudio.message('SDI:sdi:splitHideButton',...
                                                    str);
                    varargin{3}.setToolTipText(toolTipText);
                        
                else
                    
                    this.dividerLocation = dvFlush;
                    drawnow();                    
                    dvPos = get(this.hDivider, 'pos');
                    if test
                        set(this.rightDownPane, 'vis', 'off'); 
                        this.paneVisibility{2} = 'off';
                        ch = get(this.rightDownPane, 'children');
                        set(ch, 'vis', 'off');
                        
                        if strcmpi(this.orientation(1), 'h')
                            set(this.leftUpPane, 'position', [0,0,dvPos(1),1]);
                        else
                            set(this.leftUpPane, 'position', [0,0,1,dvPos(2)]);
                        end
                        if ~isempty(this.rightCallback)
                            feval(this.rightCallback);
                        end  
                    else
                        set(this.leftUpPane, 'vis', 'off');
                        this.paneVisibility{1} = 'off';
                        ch = get(this.leftUpPane, 'children');
                        set(ch, 'vis', 'off');
                        if strcmpi(this.orientation(1), 'h')                           
                            set(this.rightDownPane, 'position', [dvPos(1),0,...
                                1-dvPos(1),1]);
                        else
                            set(this.rightDownPane, 'position', [0,dvPos(2),1 ...
                                ,1-dvPos(2)]);
                        end
                        
                        if ~isempty(this.leftCallback)
                            feval(this.leftCallback);
                        end    
                    end
                    
                    drawnow; 
                    
                    % reset tool tips of arrows
                    toolTipText = DAStudio.message('SDI:sdi:splitShowButton',...
                                                    str);
                    varargin{1}.setToolTipText(toolTipText);
                    javaMethodEDT('setVisible', varargin{3}, false);                    
                end
                
            catch %#ok                
                disp(lasterr);
            end
            
            % helper for converting 'top' to 'bottom' and vice versa
            function newStr = convertPositionHelper(str)
                
                % cache String dictionary
                stringDict = Simulink.sdi.StringDict;
                
                if(strcmpi(str, stringDict.splitTop))
                    newStr = stringDict.splitBottom;
                elseif(strcmpi(str, stringDict.splitBottom))
                    newStr = stringDict.splitTop;
                elseif(strcmpi(str, stringDict.splitLeft))
                    newStr = stringDict.splitRight;
                else
                    newStr = stringDict.splitLeft;
                end                    
            end
        end
        
        
        
    end
    
end
