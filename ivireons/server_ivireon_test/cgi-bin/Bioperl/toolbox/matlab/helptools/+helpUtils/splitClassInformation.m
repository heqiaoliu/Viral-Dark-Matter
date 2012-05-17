function [classInfo, whichTopic, malformed] = splitClassInformation(topic, helpPath, implementor, justChecking)
    if nargin < 4
        justChecking = true;
        if nargin < 3
            implementor = false;
        end
    end
    
    if nargin > 1
        helpPath = regexprep(helpPath, '[@+]', '');
        while ~isempty(helpPath)
            classInfo = innerResolveImplicitPath(fullfile(helpPath, topic), implementor, justChecking);
            if ~isempty(classInfo)
                [classInfo, whichTopic] = finishSplitClassInformation(classInfo, justChecking);
                malformed = false;
                return;
            end
            [helpPath, pop] = fileparts(helpPath);
            if isempty(pop)
                break;
            end
        end
    end
    
    topicIsDotM = ~isempty(regexp(topic, '\.[mp]$', 'once'));
    [classInfo, whichTopic, malformed] = innerSplitClassInformation(topic, implementor, justChecking, topicIsDotM);
    
    if ~isempty(classInfo)
        [classInfo, whichTopic] = finishSplitClassInformation(classInfo, justChecking);
    end
end

%% ------------------------------------------------------------------------
function [classInfo, whichTopic, malformed] = innerSplitClassInformation(topic, implementor, justChecking, topicIsDotM)
    whichTopic = [];
    
    [classInfo, malformed] = resolveExplicitPath(topic, implementor, justChecking);
    if isempty(classInfo) && ~malformed
        if helpUtils.isObjectDirectorySpecified(topic)
            malformed = true;
            return;
        end
        % just a slash and dot separated list of names
        [classInfo, whichTopic] = resolveImplicitPath(topic, implementor, justChecking);
        if topicIsDotM && isempty(classInfo)
            [classInfo, whichTopic] = resolveUnaryClass(topic, justChecking);
            if isempty(classInfo) && ~isempty(regexp(topic, '[\\/]', 'once'))
                % which may have found an object dir
                [classInfo, malformed] = resolveExplicitPath(whichTopic, implementor, justChecking);
            end
            if isempty(classInfo) && ~malformed
                % see if this is loosely qualified with missing
                % class directory sentinels (+,@)
                badClassInfo = resolveImplicitPath(topic(1:end-2), implementor, justChecking);
                if ~isempty(badClassInfo)
                    malformed = true;
                end
            end
        end
    end
end

%% ------------------------------------------------------------------------
function [classInfo, malformed] = resolveExplicitPath(topic, implementor, justChecking)
    classInfo = [];
    malformed = false;
    
    UDDParts = regexp(topic, '^(?<path>.*?[\\/])?(?<package>@\w+)[\\/](?<class>@\w+)(?<methodSep>[\\/])?(?<method>(?(methodSep)\w+))?(?(method)\.[mp])?$', 'names');
    if ~isempty(UDDParts)
        % Explicitly two @ directories
        classInfo = UDDClassInformation(UDDParts, justChecking, implementor);
        malformed = isempty(classInfo);
    else
        MCOSParts = regexp(topic, '^(?<path>[\\/]?([^@+][^\\/]*[\\/])*)?(?<packages>\+\w+([\\/]\+\w+)*)?(?<classSep>(?(packages)[\\/]|(?(path)|^[\\/]?))@)?(?<class>(?(classSep)\w+))(?<methodSep>[\\/])?(?<method>(?(methodSep)\w+))?(?<mp>(?(method)\.[mp]))?(?<ext>(?(method)(?(mp)|\.\w+)))?$', 'names');
        if ~isempty(MCOSParts)
            % Explicitly zero or more + directories and/or one @ directory
            classInfo = MCOSClassInformation(topic, MCOSParts, justChecking, implementor);
            malformed = isempty(classInfo);
        end
    end
end

%% ------------------------------------------------------------------------
function [classInfo, whichTopic] = resolveImplicitPath(topic, implementor, justChecking)
    classInfo = [];
    
    imports = builtin('_toolboxCallerImports');
    firstName = regexp(topic, '\w+', 'match', 'once');
    for i = 1:length(imports)
        thisImport = imports{i};
        if thisImport(end) == '*';
            [classInfo, whichTopic] = innerResolveImplicitPath([thisImport(1:end-1) topic], implementor, justChecking);
        else
            names = regexp(thisImport, '^(?<qualifiers>.*\.)?(?<lastItem>.*)$', 'names');
            if strcmpi(firstName, names.lastItem)
                [classInfo, whichTopic] = innerResolveImplicitPath([names.qualifiers topic], implementor, justChecking);
            end
        end
        if ~isempty(classInfo)
            classInfo.unaryName = topic;
            return;
        end
    end
    [classInfo, whichTopic] = innerResolveImplicitPath(topic, implementor, justChecking);
end

%% ------------------------------------------------------------------------
function [classInfo, whichTopic] = innerResolveImplicitPath(topic, implementor, justChecking)
    classInfo = [];
    whichTopic = [];
    
    objectParts = regexp(topic, '^(?<pathAndPackage>.+?)(?<s1>[.\\/])?(?<class>(?(s1)\w+))(?<s2>[.\\/])?(?<method>(?(s2)\w+))$', 'names');
    if ~isempty(objectParts)
        objectParts.pathAndPackage = regexprep(objectParts.pathAndPackage, '\\', '/');
        if isempty(objectParts.method)
            allPackageInfo = [];
        else
            [classInfo, allPackageInfo] = ternaryClassInformation(objectParts, justChecking, implementor);
            if isempty(classInfo)
                [objectParts, allPackageInfo] = convertClassToPackage(objectParts, allPackageInfo);
            end
        end
        if isempty(classInfo) && ~isempty(objectParts.class)
            classInfo = binaryClassInformation(objectParts, justChecking, implementor, allPackageInfo);
            if isempty(classInfo)
                [objectParts, allPackageInfo] = convertClassToPackage(objectParts, allPackageInfo);
            end
        end
        if isempty(classInfo)
            [classInfo, whichTopic] = unaryClassInformation(objectParts, justChecking, allPackageInfo);
        end
        if ~isempty(classInfo)
            classInfo.isMinimal = isempty(regexp(objectParts.pathAndPackage, '[\\/.]', 'once'));
        end
    end
end

%% ------------------------------------------------------------------------
function [classInfo, whichTopic] = finishSplitClassInformation(classInfo, justChecking)
    if justChecking && ~classInfo.isAccessible
        classInfo = [];
        whichTopic = [];
    else
        whichTopic = classInfo.minimizePath;
    end
end

%% ------------------------------------------------------------------------
function classInfo = UDDClassInformation(UDDParts, justChecking, implementor)
    classInfo = [];
    
    packagePath = [UDDParts.path UDDParts.package];
    inputClassName = UDDParts.class(2:end);
    methodName = UDDParts.method;
    
    isUnspecifiedConstructor = isempty(methodName);
    if isUnspecifiedConstructor
        methodName = inputClassName;
    end
    
    allPackageInfo = helpUtils.hashedDirInfo(packagePath);
    for i = 1:length(allPackageInfo)
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = helpUtils.getPackageName(packagePath);
        [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName);
        if isDocumented
            classIndex = strcmpi(packageInfo.classes, inputClassName);
            if any(classIndex)
                className = packageInfo.classes{classIndex};
                classHandle = helpUtils.classWrapper.rawUDD(className, packagePath, packageID, isUnspecifiedConstructor, implementor);
                classInfo = classHandle.getClassInformation(methodName, justChecking);
                if ~isempty(classInfo)
                    return;
                end
            end
        end
    end
end

%% ------------------------------------------------------------------------
function classInfo = MCOSClassInformation(topic, MCOSParts, justChecking, implementor)
    classInfo = [];
    
    inputClassName = MCOSParts.class;
    methodName = MCOSParts.method;
    
    if isempty(MCOSParts.packages)
        if isempty(methodName)
            allPackageInfo = helpUtils.hashedDirInfo(topic);
            classInfo = resolvePackageInfo(allPackageInfo, true, justChecking);
        else
            allPackageInfo = helpUtils.hashedDirInfo([MCOSParts.path '@' inputClassName]);
            for i = 1:length(allPackageInfo)
                packageInfo = allPackageInfo(i);
                packagePath = packageInfo.path;
                packageName = helpUtils.getPackageName(packagePath);
                [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName);
                if isDocumented || ischar(packageID)
                    % MCOS or OOPS class or UDD package
                    [fixedName, foundTarget] = helpUtils.extractFile(packageInfo, methodName);
                    if foundTarget
                        % MCOS or OOPS class/method or UDD packaged function
                        if strcmp(inputClassName, fixedName)
                            classInfo = helpUtils.classInformation.localConstructor('', inputClassName, packagePath, justChecking);
                        elseif isDocumented
                            classInfo = helpUtils.classInformation.packagedFunction(inputClassName, packagePath, fixedName);
                        else
                            classHandle = helpUtils.classWrapper.rawMCOS(fixedName, packagePath, '', false, false, false);
                            classInfo = helpUtils.classInformation.fileMethod(classHandle, inputClassName, packagePath, packagePath, fixedName, '');
                            classInfo.setImplementor(implementor);
                        end
                        return;
                    end
                end
            end
        end
    else
        if isempty(MCOSParts.ext)
            helpFunction = '';
        else
            helpFunction = helpUtils.getHelpFunction(MCOSParts.ext);
            if isempty(helpFunction)
                return;
            end
        end
        
        packagePath = [MCOSParts.path MCOSParts.packages];
        allPackageInfo = helpUtils.hashedDirInfo(packagePath);
        
        if isempty(inputClassName) && isempty(methodName)
            if ~isempty(allPackageInfo)
                % MCOS Package
                classInfo = helpUtils.classInformation.package(allPackageInfo(1).path, true);
            end
            return;
        end
        
        isUnspecifiedConstructor = isempty(methodName);
        if isUnspecifiedConstructor
            methodName = inputClassName;
        end
        
        for i = 1:length(allPackageInfo)
            packageInfo = allPackageInfo(i);
            packagePath = packageInfo.path;
            packageName = helpUtils.getPackageName(packagePath);
            className = '';
            
            classHasNoAtDir = false;
            if ~isempty(inputClassName)
                classIndex = strcmpi(packageInfo.classes, inputClassName);
                if any(classIndex)
                    className = packageInfo.classes{classIndex};
                end
            elseif ~isUnspecifiedConstructor
                if isempty(MCOSParts.ext)
                    [className, foundTarget] = helpUtils.extractFile(packageInfo, methodName);
                    if foundTarget
                        if ~helpUtils.isClassMFile(fullfile(packagePath, className))
                            classInfo = helpUtils.classInformation.packagedFunction(packageName, packagePath, className);
                            return;
                        end
                        classHasNoAtDir = true;
                        isUnspecifiedConstructor = true;
                    end
                elseif ~isempty(helpFunction)
                    packageList = dir(fullfile(packagePath, ['*' MCOSParts.ext]));
                    itemIndex = strcmpi({packageList.name}, [MCOSParts.method MCOSParts.ext]);
                    if any(itemIndex)
                        itemFullName = packageList(itemIndex).name;
                        itemName = itemFullName(1:end-length(MCOSParts.ext));
                        classInfo = helpUtils.classInformation.packagedUnknown(packageName, packagePath, itemName, itemFullName, helpFunction);
                        return;
                    end
                end
            end
            
            if ~isempty(className)
                classHandle = helpUtils.classWrapper.rawMCOS(className, packagePath, packageName, classHasNoAtDir, isUnspecifiedConstructor, implementor);
                classInfo = classHandle.getClassInformation(methodName, justChecking);
                if ~isempty(classInfo)
                    return;
                end
            end
        end
    end
end


%% ------------------------------------------------------------------------
function [classInfo, allPackageInfo] = ternaryClassInformation(objectParts, justChecking, implementor)
    classInfo = [];
    
    allPackageInfo = getPackageInfo(objectParts.pathAndPackage);
    for i = 1:length(allPackageInfo)
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = helpUtils.getPackageName(packagePath);
        [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName);
        if isDocumented
            classIndex = strcmpi(packageInfo.classes, objectParts.class);
            className = '';
            classHasNoAtDir = false;
            if any(classIndex)
                className = packageInfo.classes{classIndex};
            elseif ischar(packageID)
                [className, foundTarget] = helpUtils.extractFile(packageInfo, objectParts.class);
                if foundTarget
                    classHasNoAtDir = true;
                end
            end
            if ~isempty(className)
                if ischar(packageID)
                    classHandle = helpUtils.classWrapper.rawMCOS(className, packagePath, packageID, classHasNoAtDir, false, implementor);
                else
                    classHandle = helpUtils.classWrapper.rawUDD(className, packagePath, packageID, false, implementor);
                end
                classInfo = classHandle.getClassInformation(objectParts.method, justChecking);
                if ~isempty(classInfo)
                    return;
                end
            end
        end
    end
end

%% ------------------------------------------------------------------------
function [classInfo, allPackageInfo] = binaryClassInformation(objectParts, justChecking, implementor, allPackageInfo)
    classInfo = [];
    
    if ~isstruct(allPackageInfo)
        allPackageInfo = getPackageInfo(objectParts.pathAndPackage);
    end
    for i = 1:length(allPackageInfo)
        classHandle = [];
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = helpUtils.getPackageName(packagePath);
        [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName);
        if isDocumented
            classIndex = strcmpi(packageInfo.classes, objectParts.class);
            if any(classIndex)
                objectParts.class = packageInfo.classes{classIndex};
                if ischar(packageID)
                    classHandle = helpUtils.classWrapper.rawMCOS(objectParts.class, packagePath, packageID, false, true, implementor);
                else
                    classHandle = helpUtils.classWrapper.rawUDD(objectParts.class, packagePath, packageID, true, implementor);
                end
            else
                [className, foundTarget] = helpUtils.extractFile(packageInfo, objectParts.class);
                if foundTarget
                    if ischar(packageID) && helpUtils.isClassMFile(fullfile(packagePath, className))
                        % MCOS Class
                        classInfo = helpUtils.classInformation.fullConstructor([], packageName, className, packagePath, true, true, justChecking);
                    else
                        classInfo = helpUtils.classInformation.packagedFunction(packageName, packagePath, className);
                    end
                    return;
                else
                    packageList = dir(packagePath);
                    items = regexpi({packageList.name}, ['^(?<name>' objectParts.class ')(?<ext>\.\w+)$'], 'names');
                    items = [items{:}];
                    for item = items
                        helpFunction = helpUtils.getHelpFunction(item.ext);
                        if ~isempty(helpFunction)
                            % unknown packaged item with help extension
                            itemFullName = [item.name item.ext];
                            classInfo = helpUtils.classInformation.packagedUnknown(packageName, packagePath, item.name, itemFullName, helpFunction);
                            return;
                        end
                    end
                    
                end
            end
        end
        if isempty(classHandle) && ischar(packageID)
            [packagePath, classDir] = fileparts(packagePath);
            if ~isempty(classDir) && classDir(1) == '@'
                packageSplit = regexp(packageName, '(?<package>.*(?=\.))?\.?(?<class>.*)', 'names');
                packageName = packageSplit.package;
                classHandle = helpUtils.classWrapper.rawMCOS(packageSplit.class, packagePath, packageName, false, false, implementor);
            end
        end
        if ~isempty(classHandle)
            classInfo = classHandle.getClassInformation(objectParts.class, justChecking);
            if ~isempty(classInfo)
                return;
            end
        end
    end
    
    classMFile = which([objectParts.pathAndPackage '.m']);
    if isempty(classMFile)
        classMFile = which([objectParts.pathAndPackage '.p']);
    end
    if ~helpUtils.isObjectDirectorySpecified(classMFile)
        [packagePath, className] = fileparts(classMFile);
        classHandle = helpUtils.classWrapper.rawMCOS(className, packagePath, '', true, false, implementor);
        classInfo = classHandle.getClassInformation(objectParts.class, justChecking);
        if ~isempty(classInfo)
            return;
        end
    end
end

%% ------------------------------------------------------------------------
function [classInfo, whichTopic] = unaryClassInformation(objectParts, justChecking, allPackageInfo)
    className = objectParts.pathAndPackage;
    [classInfo, whichTopic] = resolveUnaryClass(className, justChecking);
    
    if isempty(whichTopic) && ~isempty(regexp(className, '.*\w$', 'once'))
        if ~isstruct(allPackageInfo)
            allPackageInfo = getPackageInfo(className);
        end
        classInfo = resolvePackageInfo(allPackageInfo, false, justChecking);
        if isempty(classInfo) && (isequal(objectParts.s2, '.') || (isempty(objectParts.s2) && isequal(objectParts.s1, '.')))
            % which may have used an extension as a target
            whichTopic = [];
        end
    end
    
    if ~isempty(classInfo)
        classInfo.unaryName = className;
    end
end

%% ------------------------------------------------------------------------
function [classInfo, whichTopic] = resolveUnaryClass(className, justChecking)
    classInfo = [];
    
    whichTopic = helpUtils.safeWhich(className);
    if ~isempty(whichTopic)
        [isClassMFile, className] = helpUtils.isClassMFile(whichTopic);
        if isClassMFile
            classInfo = helpUtils.classInformation.simpleMCOSConstructor(className, whichTopic, justChecking);
        end
    end
end

%% ------------------------------------------------------------------------
function classInfo= resolvePackageInfo(allPackageInfo, isExplicitPackage, justChecking)
    classInfo = [];
    for i = 1:length(allPackageInfo)
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = helpUtils.getPackageName(packagePath);
        [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName);
        if isDocumented
            % Package
            classInfo = helpUtils.classInformation.package(packagePath, isExplicitPackage);
            return;
        elseif ischar(packageID) && ~isempty(regexp(packagePath, '.*[\\/]@\w*$', 'once'));
            % MCOS or OOPS Class
            classInfo = helpUtils.classInformation.fullConstructor([], '', packageName, packagePath, false, true, justChecking);
            return;
        end
    end
end

%% ------------------------------------------------------------------------
function [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName)
    packageID = packageName;
    isDocumented = ~isempty(regexp(packageInfo.path, '.*[\\/]\+\w*$', 'once'));
    if ~isDocumented && (~isempty(packageInfo.classes) || any(strcmpi(packageInfo.m, 'schema.m')));
        packageID = findpackage(packageName);
        if ~isempty(packageID)
            isDocumented = strcmp(packageID.Documented, 'on');
        end
    end
end

%% ------------------------------------------------------------------------
function [objectParts, newPackageInfo] = convertClassToPackage(objectParts, oldPackageInfo)
    uddPackageInfo = helpUtils.hashedDirInfo([objectParts.pathAndPackage '/@' objectParts.class]);
    mcosPackageInfo = helpUtils.hashedDirInfo([objectParts.pathAndPackage '/+' objectParts.class]);
    newPackageInfo = [uddPackageInfo; mcosPackageInfo];
    for i = 1:numel(oldPackageInfo)
        packageIndex = strcmpi(oldPackageInfo(i).packages, objectParts.class);
        if any(packageIndex)
            newPackageInfo = [newPackageInfo; helpUtils.hashedDirInfo(fullfile(oldPackageInfo(i).path, ['+' oldPackageInfo(i).packages{packageIndex}]))]; %#ok<AGROW>
        end
    end
    objectParts.pathAndPackage = [objectParts.pathAndPackage, '/', objectParts.class];
    objectParts.class = objectParts.method;
    objectParts.method = '';
end

%% ------------------------------------------------------------------------
function allPackageInfo = getPackageInfo(packagePath)
    packagePath = regexprep(packagePath, '\.(\w*)$', '/$1');
    allPackageInfo = helpUtils.hashedDirInfo(regexprep(packagePath, '(^|/)(\w*)$', '$1@$2'));
    pathSeps = regexp(packagePath, '[/.]');
    if isempty(pathSeps)
        allPackageInfo = [allPackageInfo; helpUtils.hashedDirInfo(['+' packagePath])];
    else
        for pathSep = fliplr(pathSeps);
            packagePath = [packagePath(1:pathSep-1), '/+', packagePath(pathSep+1:end)];
            allPackageInfo = [allPackageInfo; helpUtils.hashedDirInfo(packagePath)]; %#ok<AGROW>
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $  $Date: 2009/12/14 22:24:56 $
