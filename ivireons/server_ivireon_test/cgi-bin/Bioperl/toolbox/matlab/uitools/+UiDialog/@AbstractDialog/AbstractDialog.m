classdef AbstractDialog < handle
    % $Revision: 1.1.6.6 $  $Date: 2009/07/23 18:42:44 $
    % Copyright 2007-2009 The MathWorks, Inc.
    %ABSTRACTDIALOG Summary of this class goes here
    %   Detailed explanation goes here

    properties(GetAccess='protected',SetAccess='protected')
        Peer;
        WaitFlag;
    end
    
    

    methods(Abstract=true,Access='public')
        show(obj)
    end
    
    methods(Abstract=true,Access='protected')
        setPeerTitle(obj)
    end

    methods
        function delete(obj)
            if ishandle(obj.Peer)
                delete(obj.Peer);
            end
        end
    end
    
    methods(Access='protected')
        % Get the parent frame.
        function parframe = getParentFrame(~)
            parframe = [];
            if isempty(gcbf)
                parframe = com.mathworks.hg.peer.utils.DialogUtilities.getFocussedWindow;
            else
                % disable the warning when using the 'JavaFrame' property
                % this is a temporary solution
                [ lastWarnMsg lastWarnId ] = lastwarn;
                oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                jf = get(gcbf, 'javaframe');
                warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                lastwarn(lastWarnMsg,lastWarnId);
                if isempty(jf)
                    return;
                end
                if ishghandle(gcbf)
                    parframe = com.mathworks.hg.peer.utils.DialogUtilities.getCallbackFigure(jf);
                end
            end
        end
        
        function blockMATLAB(obj)
            obj.WaitFlag = handle(java.lang.Object);
            waitfor(obj.WaitFlag);
        end
        
        function unblockMATLAB(obj)
            delete(obj.WaitFlag);
            obj.WaitFlag = [];
        end
    end
    
   
end
