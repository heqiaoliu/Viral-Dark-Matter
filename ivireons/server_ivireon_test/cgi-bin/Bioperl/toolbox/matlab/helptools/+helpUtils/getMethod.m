function classMethod = getMethod(metaClass, methodName)
    classMethods = metaClass.Methods;
    classMethod = [];

    if ~isempty(classMethods)
        % remove methods that do not match methodName
        classMethods(cellfun(@(c)~strcmpi(c.Name, methodName), classMethods)) = [];
        if ~isempty(classMethods)
            % remove methods that are constructors
            classMethods(cellfun(@(c)strcmp(c.Name, c.DefiningClass.Name), classMethods)) = [];
            if ~isempty(classMethods)
                % just in case this filtered down to more that one
                classMethod = classMethods{1};
            end
        end
    end
end
        
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/14 22:24:52 $
