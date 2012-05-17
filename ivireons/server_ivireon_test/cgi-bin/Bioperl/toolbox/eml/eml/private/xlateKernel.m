function str = xlateKernel(T, sysObj, instanceFcnName)
    % xlateKernel
    %
    % This function is undocumented and unsupported.  It is needed for the
    % correct functioning of your installation.
    
    % str = xlateKernel(T,sysObj,instanceFcnName)
    % T - mtree object for entire file.
    % sysObj - name of System object, used to call .getValueOnlyProps().
    % instanceFcnName - name of function to generate.

    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3.2.1.2.1 $  $Date: 2010/07/01 17:20:24 $
    
    %#ok<*AGROW>

    logError('clear');
    
    checkSysObjTree(T);
    
    propStruct = collectProperties(T);
    [parseableProps defaults] = getParseableProperties(propStruct);
    getableDependentProps = getGetableDependentProperties(T, propStruct);
    
    % t collects all the strings that will go into the output file,
    % so we don't have to construct everything in the final output order.
    % At the end we'll cat everything into the right order.
    t = struct;
    
    t.startInstFcn = startInstanceFcn(instanceFcnName);
    t.propertyVars = generatePropertyVars(propStruct);
    t.internalVars = generateInternalVars();
    
    % construct the switchyard and input parsing functions
    [ctorBody genpi] = translateConstructor(T);
    createCase = generateCreateCase(ctorBody, instanceFcnName);
    stepCase = generateStepCase(T);
%     getCase = generateGetCase(T, propStruct);
    getCase = generateGetCase(parseableProps, getableDependentProps);
    [t.isDone isDoneCase] = generateIsDone(T);
    t.switchYard = generateSwitchYard(createCase, stepCase, isDoneCase, getCase);
    if genpi
        t.parseInputs = generateParseInputsFcns(parseableProps,sysObj,defaults);
    else
        t.parseInputs = '';
    end
    t.setup = generateSetup();
    t.isLocked = generateIsLocked();
    t.reset = generateReset(T);
    t.start = generateStart(T);
    t.output = generateOutput(T);
    t.update = generateUpdate(T);
    t.numInputs = generateNumIO(T,'mNumInputs');
    t.numOutputs = generateNumIO(T,'mNumOutputs');

    [methodList apiList fcnList] = collectAdditionalFunctions(T, getableDependentProps);
    
    methodStr = {};
    for method = methodList
        methodStr{end+1} = generateMethod(T, method{1});
    end
    t.additionalMethods = [ methodStr{:} ];
    
    t.inputSpecAPI = generateInputSpecAPI(apiList);

    fcnStr = {};
    for fcn = fcnList
        fcnStr{end+1} = tree2str(findFcn(T,fcn{1}),0,true);
    end
    fcnStr{end+1} = tree2str(findFcn(T,'getDescription'),0,true);
    t.additionalFcns = [ fcnStr{:} ];
    
    t.endInstFcn = endInstanceFcn(instanceFcnName);

    str = [...
        t.startInstFcn...
        t.propertyVars...
        t.internalVars...
        t.switchYard...
        t.setup...
        t.isLocked...
        t.reset...
        t.start...
        t.output...
        t.update...
        t.numInputs...
        t.numOutputs...
        t.isDone...
        t.parseInputs...
        t.additionalMethods...
        t.endInstFcn...
        t.inputSpecAPI...
        t.additionalFcns...
        ];
    
    logError('throw');
    
end

function str = startInstanceFcn(instanceFcnName)
    str = sprintf([...
        'function varargout = %s(methodName, varargin)\n'...
        '%%#eml\n'...
        '%%#internal\n' ...
        '%%#ok<*EMNST>\n\n'], ...
        instanceFcnName);
end

function str = endInstanceFcn(instanceFcnName)
    str = sprintf('end  %% %s(methodName)\n\n',instanceFcnName);
end

function str = generatePropertyVars(propStruct)
    str = {};
    for i = 1:length(propStruct)
        if ~propStruct(i).isDependent && ~propStruct(i).endsWithEnum
            str{end+1} = ['persistent ' propStruct(i).name ';' newline];
            str{end+1} = ['eml.nodefusecheck(' propStruct(i).name ');' newline];
            if propStruct(i).isPublic || ~propStruct(i).isTunable
                str{end+1} = ['eml.nontunable(' propStruct(i).name ');' newline];
            end
            str{end+1} = newline;
        end
    end
    
    if ~isempty(str)
        str = [ '% Properties' newline str{:} ];
    else
        str = '';
    end
end

function str = generateInternalVars()
    str = [...
        '% Internal variables'                  newline...
        'persistent isInitialized;'             newline...
        'eml.nodefusecheck(isInitialized);'     newline...
                                                newline...
        ];
end

function str = generateSwitchYard(createCase, stepCase, isDoneCase, getCase)
    
    str = [...
        'switch methodName'                             newline...
        '    case ''create'''                           newline...
        createCase...
        '    case ''reset'''                            newline...
        '        if isInitialized'                      newline...
        '            mReset([]);'                       newline...
        '        end'                                   newline...
        '    case ''step'''                             newline...
        stepCase ...
        '    case ''getNumInputs'''                     newline...
        '        varargout{1} = mNumInputs;'            newline...
        '    case ''getNumOutputs'''                    newline...
        '        varargout{1} = mNumOutputs;'           newline...
        isDoneCase...
        '    case ''get'''                              newline...
        getCase ...
        '    otherwise'                                 newline...
        '        eml_assert(false,''Unrecognized method'');'         newline...
        'end'                                           newline...
                                                        newline...
        ];
end

function str = generateMethod(T, name)
    f = findFcn(T,name);
    if f.count > 0
        % xxx(wish) move this check into checkSysObjTree()
        if strcmp(getAttr(f,'Static'),'true')
            logError(f,[mfilename ':STATICCALL'], ...
                'Static method ''%s'' is not supported.', name);
            str = '';
        else
            str = translateDynamicMethod(f);
        end
    else
        str = ['function ' name '(~)' newline 'end' newline];
    end
    str = [str newline];    % add a blank line for separation
end

function str = generateReset(T)
    str = generateMethod(T,'mReset');
end

function str = generateStart(T)
    str = generateMethod(T,'mStart');
    % tack on varargin; 
    % trick relies on at least 1 arg so there is a closing paren to find.
    str = regexprep(str, ')', ',varargin)', 'once');
end

function str = generateOutput(T)
    
    if classdefHas(T,'mOutput')
        str = generateMethod(T,'mOutput');
    else
        str = [...
            'function mOutput(~, varargin)' newline ...
            'end'                           newline ...
                                            newline ...
            ];
    end
end

function str = generateUpdate(T)
    
    if classdefHas(T,'mUpdate')
        str = generateMethod(T,'mUpdate');
    else
        str = [...
            'function mUpdate(~, varargin)' newline ...
            'end'                           newline ...
                                            newline ...
            ];
    end
end

function str = generateNumIO(T,mName)
    if classdefHas(T,mName)
        str = generateMethod(T,mName);
    else
        str = [...
            'function num = ' mName '(~)'   newline ...
            '    num = 1;'                  newline ...
            'end'                           newline ...
                                            newline ...
            ];
    end
end

function [isDone isDoneCase] = generateIsDone(T)
    
    if classdefHas(T,'mIsDone')
        isDone = generateMethod(T,'mIsDone');
        isDoneCase = [...
            '    case ''isDone'''                   newline...
            '        varargout{1} = mIsDone([]);'   newline...
            ];
    else
        isDone = '';
        isDoneCase = '';
    end
end

function str = generateCreateCase(ctorBody, instanceFcnName)
    str = [...
        ctorBody...
        '        isInitialized = false;'                newline...
        '        varargout{1} = @' instanceFcnName ';'  newline...
        ];
end

function str = generateStepCase(T)
    f = findFcn(T,'mOutput');
    nargs = count(List(Outs(f)));
    
    mOutputCallSwitch = generateMOutputCallSwitch(nargs);
    
    str = [...
        '        assert(eml_const(mNumInputs([])) == (nargin-1));'  newline...
        '        assert(eml_const(mNumOutputs([])) >= nargout);'    newline...
        '        setup([], varargin{:});'                           newline...
                                                                    newline...
        mOutputCallSwitch...
                                                                    newline...
        '        mUpdate([], varargin{:});'                         newline...
        ];
    
    function mOutputCallSwitch = generateMOutputCallSwitch(nargs)
        if nargs == 0
            mOutputCallSwitch = ['        mOutput([], varargin{:});' newline];
        else
            str = {};
            
            str{end+1} = [...
                '        switch nargout'        newline...
                ];
            
            for i = 0:nargs
                str{end+1} = sprintf( [...
                    '            case %d\n' ...
                    '                %smOutput([], varargin{:});\n'...
                    ], i, generateVarargoutAssignmentLhs(i));
            end
            
            str{end+1} = [...
                '            otherwise'         newline...
                '                eml_assert(false,''Too many output arguments'');'   newline...
                '        end'                   newline...
                ];
            mOutputCallSwitch = [str{:}];
        end
        
        function str = generateVarargoutAssignmentLhs(i)
            switch i
                case 0
                    str = '';
                case 1
                    str = 'varargout{1} = ';
                otherwise
                    str = [ '[ ' sprintf('varargout{%d} ', 1:i) '] = '];
            end
        end
        
    end
    
end

function str = generateGetCase(parseableProps, getableDependentProps)

    % The error message has been worded to parallel the error from
    % eml_parse_parameter_inputs:
    %   ??? Unrecognized parameter name: 'InputSum'.
    %
    % Must emulate the base class property 'Description'.
    str = [...
        '        switch varargin{1}'                        newline...
        generatePropertyCases(parseableProps, getableDependentProps)...
        '            case ''Description'''                  newline...
        '                varargout{1} = getDescription;'    newline...
        '            otherwise'                             newline...
        '                ' errstr                           newline...
        '        end'                                       newline...
        ];
    
    function str = errstr
        str = 'eml_assert(false,[''Unrecognized property name: '''''',varargin{1},''''''.'']);';
    end

    function str = generatePropertyCases(parseableProps, getableDependentProps)

        if isempty(parseableProps) && isempty(getableDependentProps)
            str = '';
            return;
        end
        
        parseablePropValues = parseableProps;
        getableDependentPropValues = ...
            cellfun(@(x)[x '([])'], getableDependentProps, 'UniformOutput',false);
        
        magicArgs = ...
            [parseableProps      getableDependentProps;
             parseablePropValues getableDependentPropValues ];
        
        fmt = [...
            '            case ''%s''\n'...
            '                varargout{1} = %s;\n'
            ];
        str = sprintf(fmt, magicArgs{:});
    end
end

function [methodList apiList fcnList] = collectAdditionalFunctions(T, getableDependentProps)
    ctor = getClassName(T);
    coreFcns = {...
        ctor ...
        'mOutput' ...
        'mUpdate' ...
        'mReset' ...
        'mStart' ...
        'mNumInputs' ...
        'mNumOutputs' ...
        };
    
    propFcns = cellfun(@(x)['get.' x], getableDependentProps, 'UniformOutput',false);
    
    inputAPINames = {...
        'getInputSize'...
        'getInputDataType'...
        'getInputFixedPointType'...
        'isInputFixedPoint'...
        'isInputFi'...
        'isInputComplex'...
        };
    
    % Breadth-first search the call graph to find the functions called from
    % the coreFcns + propFcns.
    workList = [coreFcns propFcns];
    candidates = [findAllFcns(T) inputAPINames];
    i = 1;
    while i <= length(workList)
        candidates = setdiff(candidates, workList);
        workList = [workList findCalledCandidates(workList{i}, candidates)];
        i = i + 1;
    end
    % now we have a list of everything called; partition it.
    
    % remove coreFcns
    workList = workList(length(coreFcns)+1 : end);
    
    % input spec API fcns that were called
    apiList = intersect(workList,inputAPINames);
    
    % dynamic methods (excluding the core fcns) that were called
    methodList = intersect(workList, findAllDynamicMethods(T));
    
    % static methods and subfunctions that were called
    fcnList = setdiff(workList, [apiList methodList]);
    
    
    function calledCandidates = findCalledCandidates(fName, candidates)
        calledCandidates = unique(strings(mtfind(Tree(findFcn(T, fName)),'String',candidates)));
    end
    
    function fcnList = findAllFcns(T)
        fcnList = strings(Fname(wholetree(T)));
    end
    
end

function str = generateSetup
    str = sprintf([...
        'function setup(~, varargin)\n'...
        '    if ~isInitialized\n'...
        '        isInitialized=true;\n'...
        '        mStart([], varargin{:});\n'...
        '        mReset([]);\n'...
        '    end\n'...
        'end\n\n'...
        ]);
end

function str = generateIsLocked
    str = sprintf([...
        'function L = isLocked(~)\n'...
        '    L = isInitialized;\n'...
        'end\n\n'...
        ]);
end

function str = generateInputSpecAPI(apiCalls)
    str = {};

    % Only emit the fcns that are used.
    if ismember('getInputSize', apiCalls)
        s = 'function sz = getInputSize(~, x)\n    sz = size(x);\nend\n\n';
        str{end+1} = sprintf(s);
    end
    
    if ismember('getInputDataType', apiCalls)
        s = [...
        'function dt = getInputDataType(~, x)\n'                    ...
        '    if isfloat(x) || isinteger(x) || islogical(x)\n'       ...
	    '        dt = class(x);\n'                                  ...
	    '    elseif isa(x,''embedded.fi'')\n'                       ...
	    '        dt = ''fixed-point'';\n'                           ...
	    '    else\n'                                                ...
	    '        eml_assert(false,''Inputs must be either numeric or logical variables or fi objects.'');\n' ...
	    '    end\n'                                                 ...
        'end\n'                                                     ...
        ];
        str{end+1} = sprintf(s);
    end
    
    if ismember('getInputFixedPointType', apiCalls)
        s = 'function ft = getInputFixedPointType(~, x)\n    ft = numerictype(x);\nend\n\n';
        str{end+1} = sprintf(s);
    end
    
    if ismember('isInputFixedPoint', apiCalls)
        s = 'function flag = isInputFixedPoint(~, x)\n    flag = isa(x,''embedded.fi'');\nend\n\n';
        str{end+1} = sprintf(s);
    end
    
    if ismember('isInputFi', apiCalls)
        s = 'function flag = isInputFi(~, x)\n    flag = isa(x,''embedded.fi'');\nend\n\n';
        str{end+1} = sprintf(s);
    end
    
    if ismember('isInputComplex', apiCalls)
        s = 'function flag = isInputComplex(~, x)\n    flag = ~isreal(x);\nend\n\n';
        str{end+1} = sprintf(s);
    end
    
    str = [str{:}];
    
end

% Constructing the maps to translate methods is easily the most complicated
% part of this translator.  
% 
% MATLAB syntax, which does not distinguish between function calls and
% variable access, and also provides two different ways to call methods,
% contributes to the complexity.
% 
% Another contributor is tree2str, which is both elegant and deceptive in
% its simplicity.  You can do powerful things with it, but the techniques
% are a bit subtle.
%
% We cannot rewrite the syntax trees, so short of constructing our own IR
% (which is way beyond the scope of this project), the one translation tool
% at our disposal is tree2str() maps. Tree2str() maps are very simple: they
% map a tree node to a string.  When tree2str() encounters a node in the
% map, it emits the string *instead of processing the subtree under the
% node*.  Many of the patterns of interest are leaf subtrees, which are
% easy.  But when method call A has another method call B in its subtree
% (eg, B is one of the arguments to A) it's more complicated.  When
% tree2str() hits the mapping for A it will not process B, so we must
% ensure that A's mapping incorporates B's mapping.  We accommodate this by
% calling tree2str() on subtrees as we build the map bottom-up, as in this
% pseudo code: 
%     map(B) = tree2str(B,map)
%     map(A) = tree2str(A,map)
% That is, we first call tree2str on subtree B (with some initial state of
% the map) and then add the resulting string to the map as the mapping for
% B.  Then when we construct the mapping for A by calling tree2str() on A,
% the mapping for B will be incorporated.
% 
% In general, for this to work we must always construct the mapping for a
% node's children before we construct the mapping for the node. We can
% ensure this using the node indices, which are numbered in a preorder
% traversal of the syntax tree.  In this ordering, parent nodes always have
% lower numbers than their children.  By constructing node maps from
% highest index down to lowest, we will get the ordering we need.
% 
% Conceptually, once we construct the mapping for a node, the mappings for
% its descendants are no longer necessary and could be removed from the
% map.  But that is extra work, and there is no reason to bother unless we
% encounter a performance problem.
%
% For simplicity, the map will contain some superfluous mappings.  For
% example, consider two mappings:
%   1)      this            =>  '[]'
%   2)      this.property   =>  'property'
% Every occurrence of mapping (2) will have underneath it a superfluous
% mapping (1) that will never be used.  The superfluous mappings are
% harmless, and would be troublesome to remove, so it is safer to leave
% them.
%
% The behavior of tree2str() is unspecified if the map has two entries for
% one node.  There is no notion of one mapping overriding another. Don't do
% that.
%
% Required translations:
%
%   Eliminate 'this':
%       'This' may actually be named anything; it is the first input of a 
%       dynamic method, the first output of the constructor. We preserve a
%       placeholder in argument lists to avoid disturbing nargin.
%
% (1)   'this' in dynamic method declaration (not constructors):
%           
%           function out = method(this,in) =>  function out = method(~,in)
%
%       MAP:
%           this  =>  '~'                           (ID node)
%
% (2)   'this' passed to other methods:
%           y = otherMethod(this, arg)  =>  y = otherMethod([], arg)
%
%       MAP:
%           this  =>  '[]'                          (ID node)
%
% (3)   'this' property accesses:
%           y = 3 * this.property       =>  y = 3 * property
%
%       MAP:
%           this.property       =>  property        (DOT node)
%       
%   Support 'this.method' syntax:
%       Authors have requested support for 'this.method' syntax (symmetric
%       with 'this.property' syntax) but eml doesn't handle it.
%       Syntactically, there are 3 distinct cases:
%
% (4)   no parens:
%           this.method         =>  method([])
%
%       MAP:
%           this.method         =>  method([])      (DOT node, not L child
%                                                   of a SUBSCR node)
%
% (5)   parens without args:
%           this.method()       =>  method([])
%
%       MAP:
%           this.method()       =>  method([])      (SUBSCR node)
%
% (6)   parens with args:
%           this.method(arg)    =>  method([], arg)
%
%       MAP:
%           this.method(arg)    =>  method([], arg) (SUBSCR node)
%
%   Implement input specification API:
%       The implementation of the base class methods getInputSize(), 
%       et. al., requires modifying the last argument of the call:
%
% (7)       getInputSize(this, i)   =>  x = getInputSize([], varargin{i})
%
%           this.getInputSize(i)    => getInputSize([], varargin{i})
%       
%       MAP:
%           find input spec API calls               (CALL,SUBSCR nodes)
%           find last argument
%           arg    => varargin{ arg }               (any node)
%
%
% In the implementation, there is an interaction between patterns (4), (5),
% and (6) that requires explaining.  All three patterns share a
% 'this.method' subtree:
%             DOT:          
%       *Left:  ID:         (this)
%       *Right:  FIELD:         (method)
% What distinguishes (4) from (5) and (6) is whether the DOT node is the
% left child of a SUBSCR node.  The implementation does not attempt to
% immediately distinguish between them.  Instead it applies the mapping for (4)
% to all such subtrees, then later, when applying (5) and (6) we will strip off
% the extraneous '([])'.

function str = translateDynamicMethod(F)
    % Assume we are called on a non-static method; checked at call site.

    map = cell(2,0);
    
    % 'this' param in declaration
    %   this    =>  '~'
    this = F.Ins.first;
    map(:,end+1) = { this; '~' };                               % (1)
    
    %   get.Prop    =>  Prop
    fName = F.Fname.string;
    if strncmp(fName, 'get.', 4)
        map(:,end+1) = { F.Fname; fName(5:end) };
    end
    
    map = horzcat(map, mapThis(F,this));

    str = tree2str(F,0,true,map);
end % translateDynamicMethod(F)

function [str genpi] = translateConstructor(T)
    genpi = false;
    
    map = cell(2,0);

    ctor = findFcn(T,getClassName(T));
    this = ctor.Outs.first;

    % add map for base class c'tor call, like:
    %   this@matlab.system.API(varargin)
    % tree looks like:
    %  40        *Arg:  CALL:  33/34
    %  41           *Left:  ATBASE:  33/16
    %  42              *Left:  ID:  33/12  (this)
    %  43              *Right:  ID:  33/17  (matlab.system.API)
    %  44           *Right:  ID:  33/35  (varargin)
    baseClass = Right(Cexpr(mtfind(T, 'Kind', 'CLASSDEF')));
    baseCtorCall = mtfind(Tree(ctor), ...
        'Kind','CALL',...
        'Left.Kind','ATBASE',...
        'Left.Left.SameID', this, ...
        'Left.Right.SameID', baseClass, ...
        'Right.Kind','ID', ...
        'Right.String', 'varargin');
    if count(baseCtorCall) > 0
        map(:,end+1) = { baseCtorCall; 'parseInputs(varargin{:})' };
        genpi = true;
    end
    
    map = horzcat(map, mapThis(ctor,this));

    % only translate ctor body, don't want declaration
    str = tree2str(ctor.Body,2,false,map);

end % translateConstructor(T)

function map = mapThis(F,this)
    treeF = Tree(F);

    localMethodNames = findAllDynamicMethods(F);

    inputAPINames = {...
        'getInputSize'...
        'getInputDataType'...
        'getInputFixedPointType'...
        'isInputFixedPoint'...
        'isInputFi'...
        'isInputComplex'...
        };
    
    allMethodNames = [localMethodNames inputAPINames ];
    map = cell(2,0);

    % comment out calls to registerComponent
    regComp = mtfind(treeF,'Fun', 'registerComponent');
    map(:,end+1) = { regComp; '%registerComponent'};

    % comment out calls to allowHiddenAccess
    regComp = mtfind(treeF,'Fun', 'allowHiddenAccess');
    map(:,end+1) = { regComp; '%allowHiddenAccess'};

    % All uses of 'this' (besides param in declaration);
    % some of these will be ignored.
    %   this    =>  '[]'
    allRefs = mtfind(treeF,'SameID',this) - this;
    map(:,end+1) = {allRefs; '[]'};                             % (2)
    
    % find everything like 'this.field'
    thisDot = mtfind(treeF, 'Kind', 'DOT', 'Left.SameID', this);
    for i = thisDot.indices;
        d = thisDot.select(i);
        field = string(Right(d));
        if ismember(field,allMethodNames)
            %   this.method     =>  method([])
            % Strictly speaking, we don't want to do this if DOT is the L
            % child of a SUBSRC.  But it is simpler to apply it to
            % everything, then later remove it where it is incorrect.
            map(:,end+1) = { d; [field '( [] )'] };             % (4)
        else
            %   this.property   => property
            map(:,end+1) = { d; field };                        % (3)
        end
    end
    
    % find everything like 'this.method(..)' so we can prepend the '[]'
    % placeholder to the argument list.
    thisDotMethod = mtfind(treeF, ...
        'Kind','SUBSCR', ...
        'Left.Member',thisDot, ...
        'Left.Right.String',allMethodNames);
    
    % find everything like 'this.inputApi(i)'
    thisDotInputApi = mtfind(thisDotMethod,'Left.Right.String',inputAPINames);
    % find everything like 'inputApi(this,i)'
    inputApiCalls = mtfind(treeF,'Kind','CALL','Left.String',inputAPINames);
    % merge the sets and find the last arguments so we can wrap them with
    % 'varargin{ }'.
    inputApiLastArgs = last(Right(thisDotInputApi | inputApiCalls));
    
    % These patterns may be nested so process them bottom up.
    % Since the indices are a preordered numbering of the nodes, parents
    % always have a lower number than their children, and reverse sorting
    % by index will give us a bottom up ordering.
    sortedIndices = sort(indices(thisDotMethod | inputApiLastArgs), 'descend');
    for i = sortedIndices
        c = treeF.select(i);
        
        if ismember(c, thisDotMethod )
            % Prepend '[]' placeholder to argument list.
            % The simplest way to do this is textually: emit the
            % call to text and use regexp to find the opening '('
            % and turn it into '([]'.
            % But due to the above substitution 
            %   'this.method' => 'method([])'
            % when the call is emitted to text it will look like:
            %   method([])(args)
            % So the regexp must also remove the superfluous '([])'.
            if count(Right(c)) > 0
                repl = '( [],';  % add comma before args        % (6)
            else
                repl = '([]';    % no args, no comma            % (5)
            end
            % regexp must account for '( [] )' that was appended to method
            % name earlier.
            s = tree2str(c,0,true,map);
            map(:,end+1) = {c; regexprep(s, '\( \[] )(', repl, 'once')};
        end
        
        if ismember(c, inputApiLastArgs)
            repl = [ 'varargin{' tree2str(c,0,true,map) '}' ];
            if map{1,end} == c                                  % (7)
                % replace entry already in map
                map{2,end} = repl;
            else
                map(:,end+1) = { c; repl };
            end
        end
    end
    
end

function allDynamicMethods = findAllDynamicMethods(T)
    T = wholetree(T);
    % find all the dynamic METHODS sections
    dynamicSections = null(T);
    sections = mtfind(T,'Kind','METHODS');
    for i = sections.indices;
        s = sections.select(i);
        if strcmp(getAttr(s,'Static'),'false')
            dynamicSections = dynamicSections | s;
        end
    end
    % extract the function names from those sections
    allDynamicMethods = strings(Fname(List(Body(dynamicSections))));
end

function yes = classdefHas(T,name)
    yes = count(findFcn(T,name)) > 0;
end

function propStruct = collectProperties(T)
    propCell = cell([0,6]);
    
    tunableProps = getStringsFromCellStrFcn(T,'getTunableProps');
    
    sections = mtfind(T,'Kind','PROPERTIES');
    for i = sections.indices;
        s = sections.select(i);
        isPublic = strcmp(getAttr(s,'Access'),'public');
        isDependent = strcmp(getAttr(s,'Dependent'),'true');
        props = s.Body.List;
        for j = props.indices;
            p = props.select(j);
            name = p.Left.string;
            propCell{end+1,1} = name;
            propCell{end,2} = isPublic;
            propCell{end,3} = isDependent;
            propCell{end,4} = endsWithEnum(name);
            propCell{end,5} = getPropertyDefault(p);
            propCell{end,6} = ismember(name,tunableProps);
        end
    end
    fields = {'name', 'isPublic', 'isDependent',...
        'endsWithEnum', 'default', 'isTunable'};
    propStruct = cell2struct(propCell,fields,2);
    
    function notEnum = endsWithEnum(s)
        notEnum = length(s) >=  4 && strcmpi(s((end-3):end), 'enum');
    end
    
    function default = getPropertyDefault(prop)
        if count(prop.Right) > 0
            default = tree2str(prop.Right,0,true);
            default = patchUpCustomDataType(prop.Left.string,default);
        else
            default = '[]';
        end
        
        function default = patchUpCustomDataType(name,default)
            if ~isempty(regexpi(name,'^custom\w+datatype$','once')) ...
                    && ~isempty(regexpi(default,'^{.*}$','once'))
                default = ['numerictype(' default(2:(end-1)) ')'];
            end
        end
    end
    
    
end


function cs = getStringsFromCellStrFcn(T, fcnName)
    % Extract the cell array of strings from functions of the form:
    %   function s = foo
    %       s = { 'bar'  'fly' };
    %   end
    % Here's an example:
    % 791  *<root>:  FUNCTION: 382/05
    % 795     *Fname:  ID: 382/22  (getTunableProps)
    % 796     *Ins:  ID: 382/38  (this)
    % 793     *Outs:  ID: 382/14  (props)
    % 797     *Body:  EXPR: 384/13
    % 798        *Arg:  EQUALS: 384/13
    % 799           *Left:  ID: 384/07  (props)
    % 800           *Right:  LC: 384/15
    % 801              *Arg:  ROW: 384/16
    % 802                 *Arg:  STRING: 384/16  ('Sensitivity')
    % 803                 >Next:  STRING: 384/31  ('IntensityThreshold')
    % 804                 >Next:  STRING: 385/09  ('MaximumAngleThreshold')
    % 805                 >Next:  STRING: 385/34  ('CornerThreshold')
    
    F = mtfind(T, 'Fname.String', fcnName);
    if F.count == 0
        cs = {};
        return;
    end
    F = mtfind(F,...
        'Body.Next.Null', true,...              % only 1 stmt in body, and
        'Body.Kind',    'EXPR', ...             % it's an
        'Body.Arg.Kind','EQUALS', ...           % assignment
        'Body.Arg.Left.SameID', F.Outs);        % to the output.
    if F.count ~= 1
        logError(f,[mfilename ':BADCELLSTRFCN'], ...
                'Could not extract strings from ''%s''.', fcnName);
        cs = {};
        return;
    end

    rhs = F.Body.Arg.Right;
    cs = eval(tree2str(rhs,0,true));
end

% 'parseable' properties: public, not dependent, don't end with 'Enum'.
function [props defaults] = getParseableProperties(propStruct)
    props = {};
    defaults = {};
    
    for i = 1:length(propStruct)
        if propStruct(i).isPublic && ...
                ~propStruct(i).isDependent && ...
                ~propStruct(i).endsWithEnum
            props{end+1} = propStruct(i).name;
            if strcmp(propStruct(i).default,'[]')
                warning([mfilename ':PublicPropertyNoDefault'],...
                    'public property ''%s'' requires a default value for code generation',...
                    propStruct(i).name);
            end
            defaults{end+1} = propStruct(i).default;
        end
    end
end

% 'getable' dependent props: public, dependent, with a get.Prop method.
function props = getGetableDependentProperties(T, propStruct)
    props = {};

    for i = 1:length(propStruct)
        if propStruct(i).isPublic && ...
                ~propStruct(i).endsWithEnum && ...
                propStruct(i).isDependent && ...
                classdefHas(T,[ 'get.' propStruct(i).name]);
            props{end+1} = propStruct(i).name;
        end
    end
end


function F = findFcn(T, name)
    % mtfind(T,'Fun',name) returns the name ID node, including calls.
    % this returns the FUNCTION node, so it finds declarations only.
    F = mtfind(T,'Fname.String',name);
end

function s = newline
    s = char(10);
end

function className = getClassName(T)
    % GETCLASSNAME get name of class
    % This supports the general case to simplify error handling.
    def = mtfind( T, 'Kind', 'CLASSDEF' );
    switch def.Cexpr.kind
        case 'LT'
            % one or more base classes
            className = def.Cexpr.Left.string;
        case 'ID'
            % no base class
            className = def.Cexpr.string;
        otherwise
            fprintf('getClassName: unexpected Cexpr\n');
            className = [];
    end
end

function logError(arg1, varargin)
% logError('clear')     
%       initialize error list
% logError('throw')
%       throw all accumulated errors, if any; (reinit list)
% logError('id', 'msg', varargin)
%       add a new error to the list
% logError(tree, 'id', 'msg', varargin)
%       add a new error to the list with line number(s) from tree

% All errors will eventually cause translation to abort but we should keep
% checking as long as we reasonably can.  When we find an error beyond
% which checking makes no sense, call logError('throw') to abort
% immediately.

    persistent me;
    if isempty(me)
        me = initList;
    end
    
    if ischar(arg1) && nargin == 1 
        switch arg1
            case 'clear'
                % logError('clear');
                if ~isempty(me.cause)
                    me = initList;
                end
                return;
            case 'throw'
                % logError('throw');
                tmp = me;
                me = initList;
                if ~isempty(tmp.cause)
                    tmp.throwAsCaller;
                end
            otherwise
                error([mfilename ':BADCMD'], '''logError(%s)'' is not valid.\n',arg1);
        end
    elseif isa(arg1,'mtree')
        % logError(tree, id, msg, varargin);
        % add lineno(tree) to message 
        % count(tree) > 1  =>  loop to issue error for each line
        tree = arg1;
        id = varargin{1};
        msg = varargin{2};
        rest = varargin(3:end);
        for loc = lineno(tree)'
            me = me.addCause(MException([mfilename ':' id], ...
                ['L %d: ' msg], loc, rest{:}));
        end
    else
        % logError(id, msg, varargin);
        id = arg1;
        msg = varargin{1};
        rest = varargin(2:end);
        me = me.addCause(MException([mfilename ':' id],msg, rest{:}));
    end
    
    function me = initList
        me = MException([mfilename ':ABORTED'],'');
    end
end
