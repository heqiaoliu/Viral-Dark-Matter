classdef abstractMethod < helpUtils.classInformation.localMethod
    properties (SetAccess=private, GetAccess=private)
        definitionFile = '';
    end
    
    methods
        function ci = abstractMethod(classWrapper, className, basePath, derivedPath, methodName, packageName)
            ci@helpUtils.classInformation.localMethod(classWrapper, className, basePath, derivedPath, methodName, packageName);
            ci.definitionFile = fullfile(basePath, [className, '.m']);
        end
    end
    
    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, ~)
            helpText = helpUtils.callHelpFunction(@ci.getHelpTextFromFile, ci.definitionFile);
            needsHotlinking = true;
        end
    end
    
    methods (Access=private)
        function helpText = getHelpTextFromFile(ci, fullPath)
            helpText = '';
            classFile = fileread(fullPath);
            allAbstractHelps = ci.getAllAbstractHelps(classFile);
            allAbstractHelps(~strcmp(ci.element, {allAbstractHelps.method})) = [];
            for abstractHelp = allAbstractHelps
                helpText = abstractHelp.help;
                if ~isempty(helpText)
                    helpText = regexprep(helpText, '^\s*%', ' ', 'lineanchors');
                    helpText = regexprep(helpText, '\r', '');
                    return;
                end
            end
        end
    end
    
    methods (Static, Access=protected)
        function allAbstractHelps = getAllAbstractHelps(classFile)
            classFile = regexprep(classFile, '\.\.\..*\n', '', 'dotexceptnewline');
            abstractSections = regexp(classFile, '^\s*methods\>.*\(.*\<Abstract(?!\s*=\s*false).*\).*(?<inside>.*\n)*?^\s*end\>', 'names', 'dotexceptnewline', 'lineanchors');
            % cast the input to regexp to char so empty will do the right thing
            allAbstractHelps = regexp(char([abstractSections.inside]), '^(?<help>[ \t]*+%.*+\n)*[ \t]*+((\w+|\[[^\]]*\])\s*=\s*)?(?<method>\w++)', 'names', 'dotexceptnewline', 'lineanchors');
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/24 19:34:12 $
