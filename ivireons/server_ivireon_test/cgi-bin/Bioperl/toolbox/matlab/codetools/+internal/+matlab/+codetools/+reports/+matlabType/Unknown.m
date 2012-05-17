classdef(Hidden) Unknown < internal.matlab.codetools.reports.matlabType.MatlabFileType

    %Copyright 2009 The MathWorks, Inc.
    properties
    end
    
    methods
        function string = char(~)
            string = sprintf('unknown');
        end

    end
    
end

