classdef ClassHelpContainer < helpUtils.containers.abstractHelpContainer
    % CLASSHELPCONTAINER - stores help and class information related to a
    % MATLAB Object System class
    %
    % Remark:
    % Creation of this object should be made by the static 'create' method
    % of helpUtils.containers.HelpContainerFactory class.
    %
    % Example:
    % filePath = which('RandStream');
    % helpContainer = helpUtils.containers.HelpContainerFactory.create(filePath);
    %
    % The code above constructs a ClassHelpContainer object.
    
    % Copyright 2009 The MathWorks, Inc.
    
    properties (Access = private)
        % StructPropertyHelpContainers stores metadata & help comments
        % for properties in a struct where each field corresponds
        % to one ClassMemberHelpContainer.
        StructPropertyHelpContainers;
        
        % StructMethodHelpContainers - stores metadata & help comments for
        % methods in a struct where each field corresponds to one
        % ClassMemberHelpContainer.
        StructMethodHelpContainers;
        
        % StructAbstractHelpContainers - stores metadata & help comments 
        % for abstract methods in a struct where each field corresponds to
        % one ClassMemberHelpContainer.
        StructAbstractHelpContainers;
        
        % ConstructorHelpContainer - stores metadata & help comments for constructor
        ConstructorHelpContainer;
        
        minimalPath; % minimal path to class
        
        classInfo; % used to extract help comments for class members
    end
    
    properties (SetAccess = private)        
        % onlyLocalHelp - boolean flag determines two things:
        % 1. To store entire help or just H1 line
        % 2. to store help information for inherited methods and properties
        onlyLocalHelp;
    end

    properties (GetAccess = private, Constant)
        Property    = 0; % constant defined for properties
        Method      = 1; % constant defined for methods
        Constructor = 2; % constant defined for constructors
    end

    
    methods
        %% ---------------------------------
        function this = ClassHelpContainer(filePath, classMetaData, onlyLocalHelp)
            % constructor takes three input arguments:
            % 1. filePath - Full file path to M-file
            % 2. classMetaData - ?className
            % 3. onlyLocalHelp - a boolean flag to determine whether to
            % include inherited methods/properties and methods defined
            % outside the classdef M-file.
            
            mFileName = classMetaData.Name;
            ci = helpUtils.splitClassInformation(mFileName, '', true);
            
            helpStr = ci.getHelp;
            
            if ~onlyLocalHelp
                helpStr = helpUtils.containers.extractH1Line(helpStr);
            end
            
            mainHelpContainer = helpUtils.containers.ClassMemberHelpContainer(...
                'classHelp', helpStr, classMetaData, ~onlyLocalHelp);
            
            this = this@helpUtils.containers.abstractHelpContainer(mFileName, filePath, mainHelpContainer);
            
            this.minimalPath = helpUtils.minimizePath(filePath, false);

            this.classInfo = ci;
            
            this.onlyLocalHelp = onlyLocalHelp;
            
            this.buildStructMethodHelpContainers;
            this.buildStructPropertyHelpContainers;
        end
        
        %% ---------------------------------
        function propIterator = getPropertyIterator(this)
            % GETPROPERTYITERATOR - returns iterator for property help objects
            propIterator = helpUtils.containers.ClassMemberIterator(this.StructPropertyHelpContainers);
        end
        
        %% ---------------------------------
        function methodIterator = getMethodIterator(this)
            % GETMETHODITERATOR - returns iterator for method help objects
            methodIterator = helpUtils.containers.ClassMemberIterator(this.StructMethodHelpContainers, this.StructAbstractHelpContainers);
        end

        %% ---------------------------------
        function methodIterator = getConcreteMethodIterator(this)
            % GETCONCRETEMETHODITERATOR - returns iterator for non-abstract method help objects
            methodIterator = helpUtils.containers.ClassMemberIterator(this.StructMethodHelpContainers);
        end

        %% ---------------------------------
        function methodIterator = getAbstractMethodIterator(this)
            % GETABSTRACTMETHODITERATOR - returns iterator for abstract method help objects
            methodIterator = helpUtils.containers.ClassMemberIterator(this.StructAbstractHelpContainers);
        end

        %% ---------------------------------
        function constructorIterator = getConstructorIterator(this)
            % GETCONSTRUCTORITERATOR - returns iterator for constructor helpContainer
            constructorStruct = struct;
            constructorHelpContainer = this.getConstructorHelpContainer;

            if ~isempty(constructorHelpContainer)
                constructorStruct.(this.classInfo.className) = constructorHelpContainer;
            end

            constructorIterator = helpUtils.containers.ClassMemberIterator(constructorStruct);
        end
        %% ---------------------------------
        function conHelp = getConstructorHelpContainer(this)
            % GETCONSTRUCTORHELPOBJ - returns constructor help container object
            conHelp = this.ConstructorHelpContainer;
        end
        
        %% ---------------------------------
        function propertyHelpContainer = getPropertyHelpContainer(this, propName)
            % GETPROPERTYHELPCONTAINER - returns help container object for property
            propertyHelpContainer = getMemberHelpContainer(this.StructPropertyHelpContainers, propName);
        end
        
        %% ---------------------------------
        function methodHelpContainer = getMethodHelpContainer(this, methodName)
            % GETMETHODHELPCONTAINER - returns the help container object for method
            try
                methodHelpContainer = getMemberHelpContainer(this.StructMethodHelpContainers, methodName);
            catch %#ok<CTCH>
                methodHelpContainer = getMemberHelpContainer(this.StructAbstractHelpContainers, methodName);
            end
        end
        
        %% ---------------------------------
        function result = hasNoHelp(this)
            % ClassHelpContainer is considered empty if all of the
            % following have null help comments:
            % - Main class
            % - Constructor
            % - All properties and methods
            result = hasNoHelp@helpUtils.containers.abstractHelpContainer(this) && ...
                this.ConstructorHelpContainer.hasNoHelp && ...
                hasNoMemberHelp(this.getPropertyIterator) && ...
                hasNoMemberHelp(this.getMethodIterator);
        end

        %% ---------------------------------
        function result = isClassHelpContainer(this) %#ok<MANU>
            % ISCLASSHELPCONTAINER - returns true because object is of
            % type ClassHelpContainer
            result = true;
        end
    end
    
    methods (Access = private)
        %% ---------------------------------
        function buildStructPropertyHelpContainers(this)
            % BUILDSTRUCTPROPERTYHELPCONTAINERS - initializes the struct
            % StructPropertyHelpContainers to store all the
            % ClassMemberHelpContainer objects for properties that meet the
            % requirements as specified in the
            % helpUtils.containers.HelpContainerFactory help comments.
            
            propMetaData = cullMetaData(this.mainHelpContainer.metaData.Properties, ...
                'SetAccess', 'GetAccess');
            
            if ~isempty(propMetaData) && this.onlyLocalHelp
                % Remove any properties inherited from super classes
                propMetaData(cellfun(@(c)~strcmp(c.DefiningClass.Name, this.mFileName), propMetaData)) = [];
            end
            
            this.StructPropertyHelpContainers = this.getClassMembersStruct(helpUtils.containers.ClassHelpContainer.Property, propMetaData);
        end

        %% ---------------------------------
        function buildStructMethodHelpContainers(this)
            % BUILDSTRUCTMETHODHELPCONTAINERS - does 2 things:
            %    1. Creates the struct StructMethodHelpContainers storing all
            %    the method ClassMemberHelpContainers.
            %    2. Creates the struct StructAbstractHelpContainers storing
            %    all the abstract method ClassMemberHelpContainers.
            %    3. Invokes buildConstructorHelpContainer to build a
            %    ClassMemberHelpContainer object for the constructor.
            %
            % Remark:
            % Refer to helpUtils.XMLUtil.HelpContainerFactory help for details on
            % requirements for methods that give rise to
            % ClassMemberHelpContainer objects.
            
            methodMetaData = cullMetaData(this.mainHelpContainer.metaData.Methods,'Access');
            
            constructorMeta = methodMetaData(cellfun(@(c)strcmp(c.Name, regexp(this.mFileName, '\w+$', 'match', 'once')), methodMetaData));
            
            this.buildConstructorHelpContainer(constructorMeta);
            
            superConstructorIndices = cellfun(@(c)~strcmp(c.Name, regexp(c.DefiningClass.Name, '\w+$', 'match', 'once')), methodMetaData);
            
            methodMetaData = methodMetaData(superConstructorIndices);
            
            if this.onlyLocalHelp
                % remove all inherited methods
                methodMetaData(cellfun(@(c)~strcmp(c.DefiningClass.Name, this.mFileName), methodMetaData)) = [];
            end
            
            % get abstract methods out before local methods are removed
            % since abstract methods are not recognized by which -subfun
            abstractIndices = cellfun(@(c)c.Abstract, methodMetaData);
            abstractMetaData = methodMetaData(abstractIndices);
            methodMetaData(abstractIndices) = [];
            
            if this.onlyLocalHelp
                classMethodNames = which('-subfun', this.minimalPath);
                localMethods = regexp(classMethodNames, '\w+$', 'match', 'once');
                
                % remove non-local methods
                [~, ia] = intersect(cellfun(@(c)c.Name, methodMetaData, 'UniformOutput', false), localMethods);
                methodMetaData = methodMetaData(ia);
            end
            
            this.StructMethodHelpContainers = this.getClassMembersStruct(helpUtils.containers.ClassHelpContainer.Method, methodMetaData);
            this.StructAbstractHelpContainers = this.getClassMembersStruct(helpUtils.containers.ClassHelpContainer.Method, abstractMetaData);            
        end
        
        %% ---------------------------------
        function classMemberStruct = getClassMembersStruct(this, memberType, memberMetaArray)
            % GETCLASSMEMBERSSTRUCT - returns a 1x1 struct storing all the
            % ClassMemberHelpContainer objects individually as fields.
            
            classMemberStruct = struct;
            
            for i = 1:length(memberMetaArray)
                memberHelp = this.getMemberHelp(memberMetaArray{i}, memberType);
                memberName = memberMetaArray{i}.Name;
                
                classMemberStruct.(memberName) = ...
                    helpUtils.containers.ClassMemberHelpContainer(memberType, ...
                    memberHelp, memberMetaArray{i}, ~this.onlyLocalHelp);
            end
        end
        
        %% ---------------------------------
        function buildConstructorHelpContainer(this, constructorMeta)
            % BUILDCONSTRUCTORHELPOBJ - initializes constructor help
            % container object
            if ~isempty(constructorMeta)
                constructorMeta = constructorMeta{1};
                constructorHelp = this.getMemberHelp(constructorMeta, helpUtils.containers.ClassHelpContainer.Constructor);
                this.ConstructorHelpContainer = ...
                    helpUtils.containers.ClassMemberHelpContainer('constructor', ...
                    constructorHelp, constructorMeta, ~this.onlyLocalHelp);
            else
                % create empty ClassMemberHelpContainer array
                this.ConstructorHelpContainer = helpUtils.containers.ClassMemberHelpContainer;
                this.ConstructorHelpContainer(end) = [];
            end
        end
        
        %% ---------------------------------
        function helpStr = getMemberHelp(this, memberMeta, memberType)
            % GETMEMBERHELP - this function centralizes all the methods of
            % extracting help for a particular class member.
            switch memberType
            case helpUtils.containers.ClassHelpContainer.Method
                elementInfo = this.classInfo.getMethodInfo(memberMeta, ~this.onlyLocalHelp);

            case helpUtils.containers.ClassHelpContainer.Property
                elementInfo = this.classInfo.getPropertyInfo(memberMeta);

            case helpUtils.containers.ClassHelpContainer.Constructor
                elementInfo = this.classInfo.getConstructorInfo(true);
            end
            
            if ~isempty(elementInfo)
                helpStr = elementInfo.getHelp;
            else
                % True for built-in class members.
                % Eg: RandStream.advance method
                helpStr = '';
            end
            
            if isempty(helpStr)
                % Built-in class members may have non-empty help in
                % metadata.
                % Eg: inputParser.CaseSensitive property
                helpStr = memberMeta.Description;
            end
        end
    end
end

%% ---------------------------------
function memberHelpContainer = getMemberHelpContainer(memberStruct, memberName)
    % GETMEMBERHELPCONTAINER - helper function to retrieve specific help
    % container for a class member
    if isfield(memberStruct, memberName)
        memberHelpContainer = memberStruct.(memberName);
    else
        error('MATLAB:ClassHelpContainer:UndefinedClassMember', ...
            'The ClassHelpContainer does not store help information for: %s', mat2str(memberName));
    end
    
end

%% ---------------------------------
function metaData = cullMetaData(metaData, accessField1, accessField2)
    % CULLMETADATA - filters out members that are private:
    % Properties filtered out have both SetAccess and GetAccess = private
    % Methods filtered out have SetAccess = private
    
    if ~isempty(metaData)
        metaData(cellfun(@(c)c.Hidden, metaData)) = [];
        privateIndices = cellfun(@(c)strcmp(c.(accessField1), 'private'), metaData);
        if nargin > 2 % Use case: filtering properties
            privateIndices = privateIndices & cellfun(@(c)strcmp(c.(accessField2), 'private'), metaData);
        end
        metaData(privateIndices) = [];
        [~, uniqueIndices] = unique(cellfun(@(c)c.Name, metaData, 'UniformOutput', false));
        metaData = metaData(uniqueIndices);
    end
end

%% ---------------------------------
function result = hasNoMemberHelp(memberIterator)
    % HASNOMEMBERHELP - given an iterator to class member help
    % containers, hasNoMemberHelp returns false if at least one of the
    % class members has non-null help.  It returns true otherwise.
    result = true;
    
    while memberIterator.hasNext
        memberHelpContainer = memberIterator.next;
        
        if ~isempty(memberHelpContainer.getHelp)
            result = false;
            return;
        end
    end
end