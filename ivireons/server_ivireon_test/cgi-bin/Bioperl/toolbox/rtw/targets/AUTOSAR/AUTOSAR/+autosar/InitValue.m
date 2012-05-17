classdef InitValue < handle
%CONSTANT specifies a constant value for use with the AUTOSAR target
%

%   Copyright 2010 The MathWorks, Inc.

    properties (SetAccess=private,GetAccess=public)
        Value;
    end
    

    methods (Access=public)
        
        function this = InitValue(value)
            this.Value=value;
        end
    
    end

end
