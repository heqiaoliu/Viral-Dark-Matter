classdef AbstractWiredSLHandler < uiscopes.AbstractDataHandler
%ABSTRACTWIREDSLHANDLER define the AbstractDataHandler Class.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/31 18:40:41 $

   methods
      function this = AbstractWiredSLHandler(srcObj)
          this@uiscopes.AbstractDataHandler(srcObj);
      end
      
      function msg = emptyFrameMsg(~)
      %EmptyFrameMsg Text message indicating likely cause of 0x0 video frame size
      % This message should never appear until
      % Simulink supports empty signals
          msg = 'Frame contains no data (size is 0x0)';
      end
      
      function enableData(~)
          % NO OP
      end
      
      function varName = getExportFrameName(this)
          hSrc = this.Source;
          varName = sprintf('%s_%.3f', hSrc.NameShort, getTimeOfDisplayData(hSrc));
          varName = uiservices.generateVariableName(varName);
      end
   end
end
   


% [EOF]
