function updateFromXML(helpContainer, xmlFilePath)
    % UPDATEFROMXML - update the help comments stored in a HelpContainer
    % object with strings extracted from input XML M-help file.
    %
    % Usage:
    %   HELPUTILS.XMLUTILS.UPDATEFROMXML(HELPCONTAINER, XMLFILEPATH) takes
    %   the helpContainer and updates its help contents with text extracted
    %   from the XML file whose path is XMLFILEPATH.
    %
    
    % Copyright 2009 The MathWorks, Inc.
    error(nargchk(2,2,nargin));
    
    parseInputs(helpContainer, xmlFilePath);
    
    dom = xmlread(xmlFilePath);
    
    docRootNode = dom.getDocumentElement;
    
    updateMainHelp(docRootNode, helpContainer);
    
    if helpContainer.isClassHelpContainer
        classInfoNode = getUnaryNode(docRootNode, 'class-info');
        
        updateConstructorHelp(classInfoNode, helpContainer);
        
        updateAllPropertiesHelp(classInfoNode, helpContainer);
        
        updateAllMethodsHelp(classInfoNode, helpContainer);
    end
    
end

%%------------------------------------------------------------------------
function parseInputs(helpContainer, xmlFilePath)
    % PARSEINPUTS - checks that the input arguments are of the correct
    % type.
    if ~isa(helpContainer, 'helpUtils.containers.abstractHelpContainer')
        error('MATLAB:updateFromXML:InvalidHelpContainer', ...
            'The first input argument must be a valid HelpContainer object');
    end
    
    if ~ischar(xmlFilePath)
        error('MATLAB:updateFromXML:InvalidXmlPath', ...
            'The second input argument must be a string representing an XML file path');
    end
    
    [~, name] = fileparts(xmlFilePath);
    
    if ~strcmp(name, helpContainer.mFileName) % tested on M-functions only!
        error('MATLAB:updateFromXML:InconsistentInput', ...
            'The help container object and the XML file do NOT correspond to the same M-file');
    end
    
end

%%------------------------------------------------------------------------
function updateMainHelp(docRootNode, helpContainer)
    % UPDATEMAINHELP - updates the help stored in the help container with
    % the relevant text found in the XML file.
    helpNode = getUnaryNode(docRootNode, 'mainHelp');
    
    if ~isempty(helpNode)
        mainHelpTxt = char(helpNode.getTextContent);
        
        if ~isempty(mainHelpTxt)
            helpContainer.updateHelp(mainHelpTxt);
        end
    end
end

%%------------------------------------------------------------------------
function updateConstructorHelp(classInfoNode, helpContainer)
    % UPDATECONSTRUCTORHELP - checks if the XML file contains any new text
    % for the constructor.  If it did find it, the constructor help
    % container is updated with the next text.
    ConstructorsNode = getUnaryNode(classInfoNode, 'constructors');
    
    if ~isempty(ConstructorsNode)
        constructorInfoNode = getUnaryNode(ConstructorsNode, 'constructor-info');
        
        childHelpNode = getUnaryNode(constructorInfoNode, 'help');
        
        constructorHelpTxt = char(childHelpNode.getTextContent);
        
        if ~isempty(constructorHelpTxt)
            constructorHelpContainer = helpContainer.getConstructorHelpContainer();
            constructorHelpContainer.updateHelp(constructorHelpTxt);
        end
    end
end

%%------------------------------------------------------------------------
function updateAllPropertiesHelp(classInfoNode, helpContainer)
    % UPDATEALLPROPERTIESHELP - setups the inputs for and invokes
    % UPDATECLASSMEMBERHELPCONTAINERS to extract help updates for
    % properties.
    PropertiesNode = getUnaryNode(classInfoNode, 'properties');
    
    if ~isempty(PropertiesNode)
        % True if class has no properties updated or has none to begin
        % with
        propertyInfoNodeList = PropertiesNode.getElementsByTagName('property-info');
        
        getPropertyHelpContainerFcnHandle = @(propName) helpContainer.getPropertyHelpContainer(propName);
        
        updateClassMemberHelpContainers(propertyInfoNodeList, getPropertyHelpContainerFcnHandle);
    end
end


%%------------------------------------------------------------------------
function updateAllMethodsHelp(classInfoNode, helpContainer)
    % UPDATEALLMETHODSHELP - setups the inputs for and invokes
    % UPDATECLASSMEMBERHELPCONTAINERS to extract help updates for
    % methods.
    MethodsNode = getUnaryNode(classInfoNode, 'methods');
    
    if ~isempty(MethodsNode)
        methodInfoNodeList = MethodsNode.getElementsByTagName('method-info');
        
        getMethodHelpContainerFcnHandle = @(methodName) helpContainer.getMethodHelpContainer(methodName);
        
        updateClassMemberHelpContainers(methodInfoNodeList, getMethodHelpContainerFcnHandle);
    end
end

%%------------------------------------------------------------------------
function updateClassMemberHelpContainers(XmlNodeList, getMember)
    % updateClassMemberHelpContainers - first extracts the updated help
    % comments for all class member nodes in the XML and for any non-empty help
    % the corresponding class member help container object is updated with the
    % newly translated help.
    
    len = XmlNodeList.getLength;
    
    for i = 0:len-1
        node = XmlNodeList.item(i);
        childHelpNode = getUnaryNode(node, 'help');
        
        if ~isempty(childHelpNode) % class member help needs updating
            
            helpTxt = char(childHelpNode.getTextContent);
            memberName = char(node.getAttribute('name'));
            
            memberHelpContainer = getMember(memberName);
            memberHelpContainer.updateHelp(helpTxt);
        end
    end
end

%%------------------------------------------------------------------------
function node = getUnaryNode(parentNode, nodeTag)
    % GETUNARYNODE - retrieves the 1st element in node list with tag name "nodetag"
    nodeList = parentNode.getElementsByTagName(nodeTag);
    if nodeList.getLength
        node = nodeList.item(0);
    else
        node = [];
    end
end