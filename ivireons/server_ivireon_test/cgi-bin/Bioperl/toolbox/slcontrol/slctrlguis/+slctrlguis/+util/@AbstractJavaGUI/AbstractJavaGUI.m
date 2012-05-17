%  Author(s): John Glass
%  Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:31:01 $
classdef (Hidden = true) AbstractJavaGUI < handle
    properties(SetAccess='private',GetAccess = 'private')
        Peer;
        Listeners;
        CallbackListener;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Peer = getPeer(obj)
            Peer = obj.Peer;
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setPeer(obj,Peer)
            obj.Peer = Peer;
        end
              
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addCallbackListener(obj,CallbackObject,fcn)
            hCallback = handle(CallbackObject);
            Listener = handle.listener(hCallback,'delayed',{@LocalExtractJavaDataFcn,fcn});
            obj.CallbackListener = [obj.CallbackListener;Listener];
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addListener(obj,Listener)
            obj.Listeners = [obj.Listeners;Listener];
        end

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteListeners(obj)
            delete(obj.Listeners)
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalExtractJavaDataFcn(es,ed,fcn)
feval(fcn{1},es,ed.JavaEvent,fcn{2:end});
end