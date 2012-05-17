classdef AbstractMLStreamingHandler < uiscopes.AbstractDataHandler
    %AbstractMLStreamingHandler   Define the AbstractMLStreamingHandler class.

    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:31 $
    
    methods

        function this = AbstractMLStreamingHandler(srcObj)
            %AbstractMLStreamingHandler   Construct the AbstractMLStreamingHandler class.
            
            this@uiscopes.AbstractDataHandler(srcObj);
            
        end
        
        function str = getTimeStatusString(this)
          hSource = this.Source;
          str = sprintf('T=%g', hSource.getTimeOfDisplayData);
        end 
        
        function str = getStatusControlTooltip(~, control)
          switch control
            case 'Frame'
              str = '';
            otherwise
              str = '';
          end
        end
        
        % Displays the Frame name in IMTool title as
        % <Name>_<FrameNumber>. The default value in the base
        % class is 'Frame'.
        function name = getExportFrameName(this)
            name = [genvarname(this.Source.SystemObject.Name) ...
                '_' num2str(this.Source.FrameCount)];
        end
    end
end

% [EOF]
