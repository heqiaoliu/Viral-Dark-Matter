function checkSysObjTree(T)
    % checkSysObjTree
    %
    % This function is undocumented and unsupported.  It is needed for the
    % correct functioning of your installation.
    
    % checkSysObjTree(T) - check that classdef conforms to supported
    % syntax.
    % T must be an mtree object for the entire file.
    
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.2.6.1 $  $Date: 2010/07/01 17:20:24 $
    
    logError('clear');
    runChecks(T);
    logError('throw');
end

function runChecks(T)
    
    % mtree found an error.
    if count(T)==1 && iskind(T, 'ERR' )
        logError([mfilename ':SyntaxError'],...
            'Syntax error:\n%s', string(T));
        logError('throw');  % abort checking
    end

    % TO DO:
    % getValueOnlyProps() should be callable
    % getValueOnlyProperties() should only return existing properties
    % 'parseable' properties must have a default value
    % warn if this@matlab.system.API but no parseable properties
    % error if generatesCode() == false
    % error on attempts to set properties of child objects
    %       property.prop = value
    %       set(property,'prop',value)
    
    classDef = mtfind(T, 'Kind', 'CLASSDEF');
    if count(classDef) ~= 1
        logError([mfilename ':BADCLASSDEF'],...
            'File does not contain a valid classdef.');
        logError('throw');  % abort checking
    end
    
%     if ~classDef.Next.isnull
%         logError(classDef.Next, [mfilename ':SUBFUNCTION'],...
%             'Subfunctions are not permitted.');
%         logError('throw');  % abort checking
%     end
    
    baseClassErrStr = ['; class must be singly derived from '...
        '''matlab.system.API'' or ''matlab.system.SourceAPI''.'];
    
    if count(mtfind(T, 'Cexpr.Kind', 'LT')) ~= 1
        logError(classDef, [mfilename ':NOBASECLASS'],['Class has no base class' baseClassErrStr]);
        logError('throw');  % abort checking
    end
    
    if count(mtfind(T, 'Cexpr.Kind', 'LT', 'Cexpr.Right.Kind', 'ID')) ~= 1
        logError(classDef, [mfilename ':MULTIPLEBASECLASSES'], ...
            ['Class has multiple base classes' baseClassErrStr]);
        logError('throw');  % abort checking
    end
    
    if count(mtfind(T, 'Cexpr.Kind', 'LT',...
            'Cexpr.Right.Kind', 'ID',...
            'Cexpr.Right.String', {'matlab.system.API' 'matlab.system.SourceAPI'})) ~= 1
        logError(classDef, [mfilename ':WRONGBASECLASS'],...
            ['Class has an incorrect base class' baseClassErrStr]);
        logError('throw');  % abort checking
    end
    
    className = classDef.Cexpr.Left.string;

    % constructor must exist
    ctor = findFcn(T, className);
    if count(ctor) ~= 1
        logError(classDef, [mfilename ':NOCONSTRUCTOR'],...
            'Class does not have a constructor.');
        logError('throw');  % abort checking
    end
    
    % constructor must have exactly 1 output
    if count(List(ctor.Outs)) == 0
        logError(ctor, [mfilename ':NOCONSTRUCTOROUTPUT'],...
            'Class constructor does not have a output');
        logError('throw');  % abort checking
    elseif count(List(ctor.Outs)) > 1
        logError(ctor, [mfilename ':TOOMANYCONSTRUCTOROUTPUTS'],...
            'Class constructor has too many outputs.');
        logError('throw');  % abort checking
    end

    % Constructor should have no assignments to 'this'
    this = ctor.Outs.first; % for c'tor, 'this' is output, not input.
    % don't use geteq(): it returns assigns like this.Prop = 17, which are ok.
    assigns = mtfind(Tree(ctor), 'Kind', 'EQUALS', 'Left.SameID', this);
    if count(assigns) > 0
        logError(assigns, [mfilename ':CONSTRUCTORASSIGN'],...
            'Assignment to constructor output is not permitted.');
        logError('throw');  % abort checking
    end
    
    % check that there are no events sections
    e = mtfind(T,'Kind','EVENTS');
    if count(e) > 0
        logError(e,[mfilename ':NOEVENTS'],...
            'Events are not supported.');
    end
    
    % check signature of basic authoring methods
    f = findFcn(T,'mOutput');
    nin = count(List(f.Ins));
%     nout = count(List(f.Outs));

%     % Current implementation of simulation appears to pass varargin to
%     % mOutput even if it has no inputs (besides 'this'), resulting in a
%     % runtime error 
%     %   ??? Too many input arguments.
%     % So for the time being, mOutput should take varargin even if mUpdate
%     % is implemented.
%     if count(findFcn(T,'mUpdate')) > 0 && nin > 1
%         logError(f, [mfilename ':MOUTPUTTOOMANYIN'],...
%             'mOutput should have only 1 input when mUpdate is implemented.');
%     end

    if nin < 1
        logError(f, [mfilename ':MOUTPUTTOOFEWIN'],...
            'mOutput should have at least 1 input.');
    end
%     % Sink blocks often use mdlOutput, which would correspond to an mOutput
%     % with no outputs.  We could argue they should use mUpdate instead, but
%     % that may be a bit pedantic.  So we have disabled the check.
%     if nout < 1
%         logError(f, [mfilename ':MOUTPUTTOOFEWOUT'],...
%             'mOutput should have at least 1 output.');
%     end
    
    f = findFcn(T,'mStart');
    nin = count(List(f.Ins));
    nout = count(List(f.Outs));
    if nin > 1
        logError(f, [mfilename ':MSTARTTOOMANYIN'],...
            'mStart should have only 1 input.');
    end
    if nin < 1
        logError(f, [mfilename ':MSTARTTOOFEWIN'],...
            'mStart should have 1 input.');
    end
    if nout > 0
        logError(f, [mfilename ':MSTARTTOOMANYOUT'],...
            'mStart should have no outputs.');
    end
    
    f = findFcn(T,'mReset');
    nin = count(List(f.Ins));
    nout = count(List(f.Outs));
    if nin > 1
        logError(f, [mfilename ':MRESETTOOMANYIN'],...
            'mReset should have only 1 input.');
    end
    if nin < 1
        logError(f, [mfilename ':MRESETTOOFEWIN'],...
            'mReset should have 1 input.');
    end
    if nout > 0
        logError(f, [mfilename ':MRESETTOOMANYOUT'],...
            'mReset should have no outputs.');
    end
    
    f = findFcn(T,'mUpdate');
    nin = count(List(f.Ins));
    nout = count(List(f.Outs));
    if nin < 1
        logError(f, [mfilename ':MUPDATETOOFEWIN'],...
            'mUpdate should have at least 1 input.');
    end
    if nout > 0
        logError(f, [mfilename ':MUPDATETOOMANYOUT'],...
            'mUpdate should have no outputs.');
    end
    
    f = findFcn(T,'mNumInputs');
    nin = count(List(f.Ins));
    nout = count(List(f.Outs));
    if nin > 1
        logError(f, [mfilename ':MNUMINPUTSTOOMANYIN'],...
            'mNumInputs should have only 1 input.');
    end
    if nin < 1
        logError(f, [mfilename ':MNUMINPUTSTOOFEWIN'],...
            'mNumInputs should have 1 input.');
    end
    if nout > 1
        logError(f, [mfilename ':MNUMINPUTSTOOMANYOUT'],...
            'mNumInputs should have only 1 output.');
    end
    if nout < 1
        logError(f, [mfilename ':MNUMINPUTSTOOFEWOUT'],...
            'mNumInputs should have 1 output.');
    end
    
    f = findFcn(T,'mNumOutputs');
    nin = count(List(f.Ins));
    nout = count(List(f.Outs));
    if nin > 1
        logError(f, [mfilename ':MNUMOUTPUTSTOOMANYIN'],...
            'mNumOutputs should have only 1 input.');
    end
    if nin < 1
        logError(f, [mfilename ':MNUMOUTPUTSTOOFEWIN'],...
            'mNumOutputs should have 1 input.');
    end
    if nout > 1
        logError(f, [mfilename ':MNUMOUTPUTSTOOMANYOUT'],...
            'mNumOutputs should have only 1 output.');
    end
    if nout < 1
        logError(f, [mfilename ':MNUMOUTPUTSTOOFEWOUT'],...
            'mNumOutputs should have 1 output.');
    end

    % check no reimplementation input spec API
    inputAPINames = {...
        'getInputSize'...
        'getInputDataType'...
        'getInputFixedPointType'...
        'isInputFixedPoint'...
        'isInputFi'...
        'isInputComplex'...
        };
    for fn = inputAPINames
        f = findFcn(T,fn{1});
        if count(f) > 0
            logError(f,...
                'InputSpecAPIOverride',...
                'Reimplementation of method ''%s'' is not permitted.',...
                fn{1});
        end
    end
    
    % check signatures of calls to input spec API
    inputApiCALLs = mtfind(T,'Kind','CALL','Left.String',inputAPINames);
    inputApiCALLsCorrectArgs = mtfind(inputApiCALLs,...
        'Right.Null',false,             ... has a first child
        'Right.Next.Null', false,       ... and a second child
        'Right.Next.Next.Null', true);  ... and no more
    
    inputApiDOTs = mtfind(T,'Kind','DOT','Right.String',inputAPINames);
    inputApiSUBSCRs = mtfind(T,'Kind','SUBSCR','Left.Member',inputApiDOTs);
    inputApiSUBSCRsCorrectArgs = mtfind(inputApiSUBSCRs,...
        'Right.Null',false,         ... has a first child
        'Right.Next.Null', true);   ... and no more

    mStart = findFcn(T,{'mStart' 'mCheckInputs'});
    mStartInputApiCALLs = mtfind(Tree(mStart),'Kind','CALL','Left.String',inputAPINames);
    mStartInputApiSUBSCRs = mtfind(Tree(mStart),'Kind','SUBSCR','Left.Member',inputApiDOTs);
    outsideMStart = (inputApiCALLs - mStartInputApiCALLs) ...
        | (inputApiSUBSCRs - mStartInputApiSUBSCRs);
    if count(outsideMStart) > 0
        logError(outsideMStart,...
            'InputSpecAPIOutsideMStart',...
            'Input specification API may only be used inside mStart or mCheckInputs.');
    end
    
    badApiCalls = ...
        ... calls without exactly 2 args
        (inputApiCALLs - inputApiCALLsCorrectArgs) ...       
        ... this.getInputSize    (no parens)
        | (inputApiDOTs - Left(inputApiSUBSCRs)) ...
        ... this.getInputSize without exactly 1 arg
        | (inputApiSUBSCRs - inputApiSUBSCRsCorrectArgs); 
    for i = indices(badApiCalls)
        c = badApiCalls.select(i);
        switch kind(c)
            case 'DOT',     s = string(Right(c));
            case 'CALL',    s = string(Left(c));
            case 'SUBSCR',  s = string(Right(Left(c)));
            otherwise,      error('unexpected node kind');
        end
        logError(c,...
            'InputSpecAPIBadArgs',...
            'Call of %s has wrong number of arguments.', ...
            s); %#ok<*AGROW>
    end
    
    % varargout is not permitted with mOutput
    f = mtfind(T,'Fname.String','mOutput','Outs.List.Any.String','varargout');
    if count(f) > 0
        logError(f,...
            'MOutputHasVarargout',...
            'mOutput is not permitted to use varargout');
    end
    
    % search for redundant attributes
    sections = mtfind(T,'Kind','ATTRIBUTES');
    for i = sections.indices; 
        s = sections.select(i); 
        attributeNames = strings(Left(List(Arg(s)))); 
        dups = findDupStrings(attributeNames);
        for d = dups
            logError(s,...
                'DuplicateAttributes',...
                'Attribute ''%s'' occurs multiple times.', d{1}); 
        end
    end
end

function F = findFcn(T, name)
    % mtfind(T,'Fun',name) returns the name ID node, including calls.
    % this returns the FUNCTION node, so it finds declarations only.
    F = mtfind(T,'Fname.String',name);
end

function dupStrings = findDupStrings(allStrings)
    % Return a row vector of strings that appear more than once.
    % use (:) because arg to unique() must be a column
    [uniqueStrings, ~, strIdx] = unique(allStrings(:));
    dupStrings = uniqueStrings(accumarray(strIdx,1) > 1)';
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
