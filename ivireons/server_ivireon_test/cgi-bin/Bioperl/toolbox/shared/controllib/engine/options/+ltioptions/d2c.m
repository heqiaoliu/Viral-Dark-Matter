classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) d2c < ltioptions.RateConversion
    % Options class for specifying options for D2C command.
    %
    % See also D2COPTIONS.
    
    % Author: Murad Abu-Khalaf 26-Oct-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:39 $    
    methods (Access=protected)       
       function [MethodList,ErrID] = getSupportedMethods(~)
          MethodList = {'zoh','tustin','matched','prewarp'};
          ErrID = 'Control:transformation:d2c08';
       end
       
       function cmd = getCommandName(~)
          cmd = 'd2c';
       end
    end
end