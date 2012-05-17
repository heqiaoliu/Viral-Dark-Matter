% The ListenerManager Class is designed for internal use only and may
% change in the future.

%  Copyright 2008-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:22 $

classdef ListenerManager < handle
    properties(SetAccess='private',GetAccess = 'public')
        UDDListeners; 
        MCOSPropertyListeners; 
        MCOSEventListeners;
    end
    
    methods(Static)
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function L = createVectListeners(ObjList,varargin)
            % Helper function for vectorization of because of limitations
            % of bridge helper function
            % ObjList is expected to be a homogeneous array
            if isobject(ObjList(1))
                % MCOS Object
                L = addlistener(ObjList,varargin{:});        
            else
                % UDD Object
                if nargin == 3
                    % event
                    L = handle.listener(ObjList,varargin{:});
                else
                    % property change
                    Props = [];
                    PropNames = varargin{1};
                    if ~iscell(PropNames)
                        PropNames = {PropNames};
                    end
                    for ct = 1:length(PropNames)
                        Props = [Props; ObjList(1).findprop(PropNames{ct})];
                    end
                    L = handle.listener(ObjList, Props, ['Property',varargin{2}],varargin{3:end});
                end
            end
        end
    end

    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = ListenerManager()
            % Constructor
        end
        
        
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addListeners(this,Listeners)
            % Add a UDD listener or MCOS property event or MCOS event listener to the Listener Manager
            % addListeners(this,LISTENERS)
            %      LISTENERS is an array of listeners which can be of the
            %      following types UDD, MCOS event, MCOS property event
            if isa(Listeners(1), 'handle.listener')
                this.UDDListeners = [this.UDDListeners; Listeners(:)];
            elseif isa(Listeners(1), 'event.proplistener')
                this.MCOSPropertyListeners = [this.MCOSPropertyListeners; Listeners(:)];
            elseif isa(Listeners(1), 'event.listener')
                this.MCOSEventListeners = [this.MCOSEventListeners; Listeners(:)];
            else
                ctrlMsgUtils.error('Controllib:general:UnexpectedError','Invalid listener specified.')
            end
        end
    

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteListeners(this)
            % Delete All Listeners in the Listener Manager
            delete(this.UDDListeners(ishandle(this.UDDListeners)))
            this.UDDListeners = [];
            
            delete(this.MCOSPropertyListeners)
            this.MCOSPropertyListeners = [];
            
            delete(this.MCOSEventListeners)
            this.MCOSEventListeners = [];
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function replaceListeners(this,L)
            % Replace all Listeners in the Listener Manager
            this.deleteListeners;
            this.addListeners(L);
        end
        
        
        %%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setEnabled(this,B)
            % Enable or Disable All Listeners in the Listener Manager
            % setEnable(this,B) where
            %      B = True, enables the listeners
            %      B = False, disables the listeners
            
            % RE: should we use isvalid/ishandle to make sure list is valid
            % handles?
            if B
                set(this.UDDListeners,'Enabled','on');
            else
                set(this.UDDListeners,'Enabled','off');
            end
            if ~isempty(this.MCOSPropertyListeners)
                [this.MCOSPropertyListeners.Enabled] = deal(B);
            end
            if ~isempty(this.MCOSEventListeners)
                [this.MCOSEventListeners.Enabled] = deal(B);
            end
        end

    end

end

 



