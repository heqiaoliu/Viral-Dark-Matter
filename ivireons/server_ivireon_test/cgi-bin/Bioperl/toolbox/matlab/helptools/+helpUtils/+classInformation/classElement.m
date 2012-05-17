classdef classElement < helpUtils.classInformation.classItem
    properties (SetAccess=protected, GetAccess=protected)
        element = '';
    end

    methods
        function ci = classElement(packageName, className, element, definition, minimalPath, whichTopic)
            ci@helpUtils.classInformation.classItem(packageName, className, definition, minimalPath, whichTopic);
            ci.element = element;
        end
        
        function topic = fullTopic(ci)
            topic = ci.makeTopic(ci.fullClassName);
        end
        
        function docTopic = getDocTopic(ci, justChecking)
            ci.prepareSuperClassName;
            isSuperClassPage = false;
            if ~isempty(ci.fullSuperClassName)
                docTopic = innerGetDocTopic(ci, ci.makeTopic(ci.fullSuperClassName));
                if ~isempty(docTopic) && ~justChecking
                    refPages = com.mathworks.mlwidgets.help.HelpInfo.getAllReferencePageUrls(docTopic, true);
                    if ~isempty(refPages)
                        actualURL = char(refPages(1).getFullUrl);
                        isSuperClassPage = ~isempty(regexpi(actualURL, ['\<' ci.superClassName '\.html$'], 'once'));
                    end                    
                end
            else
                docTopic = '';
            end
            if isempty(docTopic) || isSuperClassPage 
                subTopic = innerGetDocTopic(ci, ci.fullTopic);
                if ~isempty(subTopic) 
                    docTopic = subTopic;
                end
            end
        end
                
        function setImplementor(ci, ~) %#ok<MANU>
        end
    end
    
    methods (Access=private)
        function topic = makeTopic(ci, className)       
            topic = [className '/' ci.element];
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/14 22:24:59 $
