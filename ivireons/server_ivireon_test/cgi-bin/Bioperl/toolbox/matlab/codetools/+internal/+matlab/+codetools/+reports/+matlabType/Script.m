classdef(Hidden) Script < internal.matlab.codetools.reports.matlabType.MatlabFileType

    %Copyright 2009 The MathWorks, Inc.
    properties
    end
    
    methods
        function string = char(~)
            string = sprintf('script');
        end

    end
    
end

