function classProperty = getProperty(metaClass, propertyName)
    classProperties = metaClass.Properties;
    classProperty = [];

    if ~isempty(classProperties)
        % remove properties that do not match propertyName
        classProperties(cellfun(@(c)~strcmpi(c.Name, propertyName), classProperties)) = [];
        if ~isempty(classProperties)
            % just in case this filtered down to more that one
            classProperty = classProperties{1};
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/14 22:24:53 $
