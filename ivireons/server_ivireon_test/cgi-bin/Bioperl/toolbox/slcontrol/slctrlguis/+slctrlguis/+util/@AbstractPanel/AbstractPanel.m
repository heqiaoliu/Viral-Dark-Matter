%  Author(s): John Glass
%  Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:31:02 $
classdef (Hidden = true) AbstractPanel < slctrlguis.util.AbstractJavaGUI
    properties(SetAccess='private',GetAccess = 'private')
        QEFrame;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Panel = getPanel(obj)
            Panel = javaMethodEDT('getPanel',obj.getPeer);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showinQEFrame(obj)            
            pnl = obj.getPanel;
            QEFrame = javaObjectEDT('com.mathworks.mwswing.MJFrame');
            QEFrame.getContentPane.add(pnl);
            QEFrame.setName('QEFrame')
            QEFrame.setTitle('QEFrame')
            QEFrame.pack;
            QEFrame.show;
            obj.QEFrame = QEFrame;
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setFrameSize(obj,width,height)
            obj.QEFrame.setSize(width,height);
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function disposeQEFrame(obj)
            obj.QEFrame.dispose;
        end
    end
end