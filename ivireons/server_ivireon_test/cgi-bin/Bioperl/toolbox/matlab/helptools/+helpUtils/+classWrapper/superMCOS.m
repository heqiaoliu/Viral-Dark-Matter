classdef superMCOS < helpUtils.classWrapper.MCOS & helpUtils.classWrapper.super
    properties (SetAccess=private, GetAccess=private)
        isAbstractMethod = false
    end
    
    methods
        function cw = superMCOS(metaClass, subClassPath, subClassPackageName, isAbstractMethod)
            packagedName = metaClass.Name;
            className = regexp(packagedName, '\w*$', 'match', 'once');
            classDir = which(packagedName);
            classDir = fileparts(classDir);
            if isempty(classDir)
                [~, classDir] = helpUtils.splitClassInformation(packagedName);
                if isempty(classDir)
                    classDir = '';
                else
                    classDir = fileparts(classDir);
                end
            end
            cw = cw@helpUtils.classWrapper.MCOS(packagedName, className, classDir);
            cw.metaClass = metaClass;
            if isempty(cw.classPaths)
                % classdef is not an M-file
                packageList = regexp(cw.packagedName, '\w*(?=\.)', 'match');
                if isempty(packageList)
                    allClassDirs = helpUtils.hashedDirInfo(['@' cw.className]);
                    cw.classPaths = {allClassDirs.path};
                else
                    topPackageDirs = helpUtils.hashedDirInfo(['+' packageList{1}]);
                    packagePaths = {topPackageDirs.path};
                    if ~isscalar(packageList)
                        subpackages = sprintf('/+%s', packageList{2:end});
                        packagePaths = strcat(packagePaths, subpackages);
                    end
                    cw.classPaths = strcat(packagePaths, ['/@' cw.className]);
                end
            end
            cw.subClassPath = subClassPath;
            cw.subClassPackageName = subClassPackageName;
            if nargin > 3
                cw.isAbstractMethod = isAbstractMethod;
            end
        end

        function classInfo = getProperty(cw, elementName)
            classdefInfo = cw.getPropertyHelpFile;
            classInfo = helpUtils.classInformation.propertyMCOS(cw.className, fileparts(classdefInfo.definition), elementName, cw.subClassPackageName);
        end

        function b = hasClassHelp(cw)
            if cw.metaClass.Hidden
                b = false;
            elseif strcmp(cw.className, 'handle')
                b = true;
            else
                classInfo = cw.getClassHelpFile;
                b = classInfo.hasHelp;
            end
        end

        function classInfo = getPropertyHelpFile(cw)
            classInfo = cw.getClassHelpFile;
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, ~)
            classInfo = cw.innerGetLocalMethod(elementName, cw.isAbstractMethod);
        end

        function b = isConstructor(cw, ~) %#ok<MANU>
            b = false;
        end

        function classInfo = getClassHelpFile(cw)
            classInfo = helpUtils.classInformation.simpleMCOSConstructor(cw.className, fullfile(cw.classDir, [cw.className '.m']), false);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.13 $  $Date: 2009/12/14 22:25:24 $
