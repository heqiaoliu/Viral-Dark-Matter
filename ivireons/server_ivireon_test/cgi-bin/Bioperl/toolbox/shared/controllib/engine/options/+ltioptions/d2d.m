classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) d2d < ltioptions.RateConversion
    % Options class for specifying options for D2D command.
    %
    % See also D2DOPTIONS.
    
    % Author: Murad Abu-Khalaf 26-Oct-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:40 $
    methods (Access=protected)       
       function [MethodList,ErrID] = getSupportedMethods(~)
          MethodList = {'zoh','tustin','prewarp'};
          ErrID = 'Control:transformation:d2d07';
       end       
       function cmd = getCommandName(~)
          cmd = 'd2d';
       end
    end        
end