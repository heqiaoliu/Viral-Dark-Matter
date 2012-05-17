
%   Copyright 2009 The MathWorks, Inc.

classdef MFileInfo
    
    properties
        pName = '';
        pPath = '';
        pFileExists = false;
        pIsMFile = false;
        pIsMEXFile = false;
        pIsBuiltin = false;
        pIsShipping = false; % We do not analyze shipping M-files.
        pIsScript = false;
        pCallTree = {};
        pCallees = {};  % No sub- or nested functions
        pHasEMLPragma = false;
        pHasEMLSupport = false;
        pMLint = {};
        pToolbox = '';
        pCategory = '';
        pOneline = '';
        pNrLines = 0;
        pHasOverloads = false;
        pUsesClass = false;
        pUsesFnHandle = false;
        pUsesCellArray = false;
        pUsesGlobal = false;
        pNestedFunctions = false;
        pStructNames = {};  % Names of structures in file
        pListFields = {};   % Names of subfields for each structure
    end
    
    methods
        function obj = MFileInfo(aName, aPath)
            obj.pName = aName;
            obj.pPath = aPath;
        end
        
        function obj = analyze(obj)
            
            if ~exist(obj.pPath,'file')
                obj.pFileExists = false;
                % No such file then it is probably a builtin.
%                 if ~isempty(strfind(obj.pPath,'built-in'))
                if exist(obj.pName,'builtin') % detect built-in
                    obj.pIsBuiltin = true;
                    obj.pIsShipping = true;
                    X = emlcoderprivate.supportedEMLFunctions(); %XXX: Ugly duplicated code.
                    if ismember(obj.pName,X)
                        obj.pHasEMLSupport = true;
                    end
                end
                return;
            end
            obj.pFileExists = true;
            
            % Try to normalize the path to be robust below.
            [p,name,ext] = fileparts(obj.pPath);
            
            obj.pName = name;
            obj.pPath = fullfile(p,[name,ext]);
            
            if strcmpi(ext,'.m')
                obj.pIsMFile = true;
            end
            
            C = which(obj.pName,'-ALL');
            obj.pHasOverloads = (numel(C) > 1);
            
            if emlcoderprivate.inMATLABToolbox(obj.pPath)
                obj.pIsShipping = true;
                X = emlcoderprivate.supportedEMLFunctions(); 
                if ismember(obj.pName,X)
                    obj.pHasEMLSupport = true;
                end
            elseif exist(obj.pPath) == 3 %#ok<EXIST>
                obj.pIsMEXFile = true;
            elseif obj.pIsMFile
                obj = obj.analyzeContents;
            else
                % We're done.
            end
            
        end
        
        function obj = analyzeContents(obj)
            obj.pMLint = mlintmex('-struct','-eml',obj.pPath);
            if ~isempty(obj.pMLint) && iscell(obj.pMLint)
                assert(numel(obj.pMLint) == 1);
                obj.pMLint = obj.pMLint{1};
            end
            T = mtree(obj.pPath,'-file','-com');
            
%             dumptree(T)
%             fprintf('======================= Analyzing %s\n', obj.pName);
            [obj.pStructNames, obj.pListFields] = emlcoderprivate.AnalyzeStructures(T);
            
            % Callees: all 'Isfun' nodes without nested and sub-functions
            % Generate list of callees
            ees = unique(strings(mtfind(T,'Isfun',true)));
            
            % Remove all sub-functions and nested functions for ees
            I = false(size(ees));
            caller = obj.pName;
            for i = 1:numel(ees)
                ee = ees{i};
                C = which(ee,'in',caller);
                if isequal(fullfile(C),obj.pPath)
                    % This is a sub-function or nested function, so
                    % ignore it.
                    I(i) = true;
                end
                % Also remove 'i' and 'j'
                if ismember(ee,{'i','j'})
                    I(i) = true;
                end
            end
            ees(I) = [];
            obj.pCallees = ees;

            % Functions in call tree: all 'CALL' nodes not from MATLAB install 
            % Remove all MATLAB functions and self for calltree
            CallTree = unique(strings(Left(mtfind(T,'Kind','CALL'))));
            I = false(size(CallTree));
            caller = obj.pName;
            for i = 1:numel(CallTree)
                fun = CallTree{i};
                C = which(fun,'in',caller);
                % Mark functions from MATLAB install as 'to be removed'
                if ~isempty(strfind(C,matlabroot))
                    I(i) = true;
                end
                % Mark functions 'i' and 'j' as 'to be removed'
                if ~isempty(strfind(C,matlabroot))
                    I(i) = true;
                end
                % If function is within calling file, mark it as 'local'
                if isequal(fullfile(C),obj.pPath)
                    CallTree{i} = sprintf('%s (local)',CallTree{i});
                end
                % Also remove 'i' and 'j'
                if ismember(fun,{'i','j'})
                    I(i) = true;
                end
            end
            CallTree(I) = [];
            obj.pCallTree = CallTree;
            
            function result = Lookat_Kind(pattern)
                subtree = mtfind(T,'Kind',pattern);
                if ~isempty(strings(subtree))
                    result = true;
                else
                    result = false;
                end
            end
            
            % Determine whether file is a script or a function
            obj.pIsScript = ~Lookat_Kind('FUNCTION');
            
            % Determine whether file includes EML pragma
            comments = strings(mtfind(T,'Kind','COMMENT'));
            if ~isempty(regexp(['' comments{:}],'#eml','once'))
                obj.pHasEMLPragma = true;
            end
            
            % This should never happen except maybe if invoking screener on
            % a MATLAB function (?)
            % If function is part of MATLAB, check whether supported
            if obj.pIsShipping
                X = emlcoderprivate.supportedEMLFunctions();
                if ismember(obj.pName,X)
                    obj.pHasEMLSupport = true;
                end
            end
            
            % Determine whether there is class usage
            class1 = mtfind(T,'Kind','METHODS');
            class2 = mtfind(T,'Kind','CLASSDEF');
            if ~isempty(strings(class1)) || ~isempty(strings(class2))
                obj.pUsesClass = true;
            end
            
            % Determine whether there is function handle usage
            obj.pUsesFnHandle = Lookat_Kind('AT');
            
            % Determine whether there is cell array usage
            obj.pUsesCellArray = Lookat_Kind('CELL');
            
            % Determine whether there is global variable usage
            obj.pUsesGlobal = Lookat_Kind('GLOBAL');
   
            % Scan M-Lint messages to gain more information
            % Any message about nested functions?
            for i = 1:numel(obj.pMLint)
                m = obj.pMLint(i);
                if ~isempty(strfind(m.message,...
                        'Embedded MATLAB does not support nested functions'))
                    obj.pNestedFunctions = true;
                end
            end

            % Number of lines in file
            obj.pNrLines = max(lineno(T));
            
            
        end
        
        function c = callees(obj)
            c = obj.pCallees;
        end
    end
end