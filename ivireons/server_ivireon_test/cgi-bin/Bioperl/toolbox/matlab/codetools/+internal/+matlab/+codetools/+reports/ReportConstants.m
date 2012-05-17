classdef ReportConstants
    %REPORTCONSTANTS String contants for the directory reports
    
    % Copyright 2009 The MathWorks, Inc.
    
    properties(SetAccess = private, Constant)
        Error = sprintf('ERROR');
        
        %% call types
        Variable = sprintf('variable');
        Unknown = sprintf('unknown');
        Builtin = sprintf('built-in');
        MatlabToolbox = sprintf('toolbox/matlab');
        Private = sprintf('private');
        CurrentDirectory = sprintf('current dir');
        Toolbox = sprintf('toolbox');
        JavaMethod = sprintf('Java method');
        StaticMethod = sprintf('static class method');
        PackageFunction = sprintf('package function');
        Other = sprintf('other');
    end
    
    methods
    end
    
end

