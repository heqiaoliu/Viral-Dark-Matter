classdef packagedItem < helpUtils.classInformation.base
    properties
        packagedName = '';
    end

    methods
        function ci = packagedItem(packageName, packagePath, itemName, itemFullName)
            definition = fullfile(packagePath, itemFullName);
            ci@helpUtils.classInformation.base(definition, definition, definition);
            ci.packagedName = [packageName '.' itemName];
        end
        
        function topic = fullTopic(ci)
            topic = ci.packagedName;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/14 22:25:13 $
