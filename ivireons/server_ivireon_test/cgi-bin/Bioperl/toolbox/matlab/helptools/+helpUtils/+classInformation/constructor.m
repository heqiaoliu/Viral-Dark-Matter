classdef constructor < helpUtils.classInformation.classItem
    properties (SetAccess=protected, GetAccess=protected)
        metaClass = [];
        packagedName = '';
        classError = false;
        classLoaded = false;
    end

    methods
        function ci = constructor(packageName, className, definition, whichTopic, justChecking)
            ci@helpUtils.classInformation.classItem(packageName, className, definition, definition, whichTopic);
            if ~justChecking
                ci.loadClass;
                if ci.classError
                    ci.isAccessible = false;
                elseif isempty(ci.metaClass)
                    ci.isAccessible = true;
                else
                    ci.isAccessible = ~ci.metaClass.Hidden;
                end
            end
        end
        
        function b = isConstructor(ci)
            b = ~ci.isClass;
        end
        
        function b = isMCOSClass(ci)
            ci.loadClass;
            b = ~isempty(ci.metaClass);
        end
        
        function topic = fullTopic(ci)
            topic = ci.fullClassName;
            if ci.isConstructor
                topic = [topic '/' ci.className];
            end                
        end
    end

    methods (Access=protected)
        function loadClass(ci)
            if ~ci.classLoaded
                ci.classLoaded = true;
                try
                    ci.packagedName = helpUtils.makePackagedName(ci.packageName, ci.className);
                    ci.metaClass = meta.class.fromName(ci.packagedName);
                catch e %#ok<NASGU>
                    ci.classError = true;
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2009/12/14 22:25:02 $
