classdef qrandset
%QRANDSET Quasi-random point set class.
%   QRANDSET is a base class that encapsulates a sequence of multi-
%   dimensional quasi-random numbers.  This base class is abstract and
%   cannot be instantiated directly.  Concrete subclasses include SOBOLSET
%   and HALTONSET.
%
%   All point sets that inherit from QRANDSET have the following properties
%   and methods:
%
%   qrandset properties:
%     Read-only:
%      Type             - String that contains the name of the sequence.
%      Dimensions       - Number of dimensions in the set (fixed at creation).
%
%     Settable:
%      Skip             - Number of initial points to omit.
%      Leap             - Number of points to miss out between returned points.
%      ScrambleMethod   - Structure containing the current scramble settings.
%
%   qrandset methods:
%      scramble         - Apply a new scramble.  Each specific point set
%                         class supports a different set of scramble
%                         options: for more details see the help for a
%                         specific class.
%      net              - Get an initial net from the sequence.
%      size             - Get the size of the point set.
%      length           - Get the number of points in the sequence.
%
%   Indexing:
%      Points in the set can be accessed by indexing using parentheses, for
%      example P(1:10, :) returns a matrix that contains all of the columns
%      of the first 10 points in the set.
%
%   See also HALTONSET, NET, QRANDSTREAM, SCRAMBLE, SOBOLSET, SUBSREF.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:12 $

    properties(SetAccess='private')
        %DIMENSIONS (Read-only) Number of dimensions in the point set.
        %   The Dimensions property of a point set contains a positive
        %   integer that indicates the number of dimensions for which the
        %   points have values.  For example, a point set with Dimensions=5
        %   will produce points that each have 5 values.
        %
        %   This property can be set by specifying the number of dimensions
        %   when constructing a new point set.  After construction, the
        %   property's value cannot be changed.  The default number of
        %   dimensions is 2.
        %
        %   See also QRANDSET.
        Dimensions = 2;
    end
    properties(Dependent = true, SetAccess = 'private')
        %TYPE (Read-only) Name of sequence on which the point set P is
        %   based. P.Type returns a string that contains the name of the
        %   sequence on which the point set is based, for example 'Sobol'.
        %   The Type property for a point set cannot be changed.
        Type;
    end
    properties
        %SKIP Number of initial points to omit from the sequence.
        %   The Skip property of a point set contains a positive integer
        %   which specifies the number of initial points in the sequence
        %   that are omitted from the point set.  The default Skip value is
        %   0.
        %
        %   Initial points of a sequence sometimes exhibit undesirable
        %   properties, for example the first point is often (0,0,0,...)
        %   and this may "unbalance" the sequence since its counterpart,
        %   (1,1,1,...), is never produced.  Another common reason is that
        %   initial points often exhibit correlations among different
        %   dimensions which disappear later in the sequence.
        %
        %   Example:
        %      % No skipping produces the standard Sobol sequence.
        %      P = sobolset(5);
        %      P(1:3,:)
        %
        %      % Skip the first point of the sequence.  The point set now
        %      % starts at the second point of the basic Sobol sequence.
        %      P.Skip = 1;
        %      P(1:3,:)
        %
        %   See also LEAP, NET, QRANDSET, SUBSREF.
        Skip = 0;
        
        %LEAP Number of points to leap over and omit for each point taken from the sequence.
        %   The Leap property of a point set contains a positive integer
        %   which specifies the number of points in the sequence to leap
        %   over and omit for every point taken.  The default Leap value is
        %   0, which corresponds to taking every point from the sequence.
        %
        %   Leaping is a technique that is used to improve the quality
        %   of a point set, however the Leap values must be chosen with
        %   care; poor Leap values can create sequences that do not fill
        %   the entire space.
        %
        %   Example:
        %      % No leaping produces the standard Halton sequence.
        %      P = haltonset(5);
        %      P(1:5,:)
        %
        %      % Set a leap of 1.  The point set now includes every other 
        %      % point from the sequence.
        %      P.Leap = 1;
        %      P(1:5,:)
        %
        %   See also NET, QRANDSET, SKIP, SUBSREF.
        Leap = 0;
    end
    properties(Dependent = true)
        %SCRAMBLEMETHOD Settings that control scrambling.
        %   The ScrambleMethod property contains a structure that defines
        %   which scrambles should be applied to the sequence.  The
        %   structure consists of two fields:
        %      Type    : A string containing the name of the scramble.
        %      Options : A cell array of parameter values for the scramble.
        %
        %   Different point sets support different scramble types as
        %   outlined in the help for each point set class.  An error is
        %   produced if an invalid scramble type is set for a point set.
        %
        %   The ScrambleMethod property also accepts an empty matrix as a
        %   value.  This will clear all scrambling and set the property to
        %   contain a (0x0) structure.
        %
        %   The SCRAMBLE method provides an alternative, easier way to set
        %   scrambles.
        %
        %   Example:
        %      P = sobolset(5);
        %      P = scramble(P, 'MatousekAffineOwen');
        %      P.ScrambleMethod
        %
        %   See also QRANDSET, SCRAMBLE.
        ScrambleMethod;
    end

    properties(GetAccess = 'protected', SetAccess = 'protected')
        NumPoints = 0;
        HasSkipLeap = false;
    end

    % ScrambleData ought to be private, but this is breaking save/load
    % at present.
    properties(GetAccess = 'protected', SetAccess = 'protected')
        ScrambleData = struct('Type', {}, 'Options', {});
    end

    % Constructor
    methods
        function obj = qrandset(Dims, varargin)
        %QRANDSET Construct a new point set object.
        %   QRANDSET(D) constructs a new point set object in D dimensions.
        %
        %   QRANDSET(D,PROP,VAL,...) specifies a set of property-value
        %   pairs that are applied to the point set after creation.

        if nargin
            obj.Dimensions = Dims;

            % Do a case-insensitive partial match on the property
            % names and set the values
            if mod(length(varargin),2)~=0
                error('stats:qrandset:WrongNumberArgs', ...
                      'Wrong number of arguments.');
            end
            for n=1:2:length(varargin)
                if ~ischar(varargin{n})
                    error('stats:qrandset:BadPropertyName', ...
                      'Property name must be a string.');
                end
                [NMatch, PName] = isPublicInexact(obj, varargin{n}, 'set');
                if NMatch==1
                    obj.(PName) = varargin{n+1};
                elseif NMatch==0
                    % No match at all
                    error('stats:qrandset:NoSuchField', ...
                        'No public field %s exists for class qrandset.', ...
                        varargin{n});
                else
                    % Ambiguous match
                    error('stats:qrandset:AmbiguousProperty', ...
                        'Ambiguous %s property:  ''%s''.', class(obj), varargin{n});
                end
            end
        end

        obj = recalcNumPoints(obj);
        obj = alterSkipLeap(obj);

        end
    end


    % Set/get methods
    methods
        function obj = set.Dimensions(obj, val)
        if ~checkRealScalarInt(val)
            error('stats:qrandset:InvalidNumberOfDimensions', ...
                'Number of dimensions must be a positive scalar integer.');
        end
        if val<1 || val>obj.getMaxDims
            error('stats:qrandset:InvalidNumberOfDimensions', ...
                'Number of dimensions must be between 1 and %d.', obj.getMaxDims);
        end
        obj.Dimensions = double(val);
        end

        function obj = set.Skip(obj, val)
        if ~checkRealScalarInt(val)
            error('stats:qrandset:InvalidSkip', ...
                'Skip value must be a positive scalar integer.');
        end
        if val<0
            error('stats:qrandset:InvalidSkip', ...
                'Skip value must be greater than or equal to zero.');
        end

        obj.Skip = double(val);
        obj = alterSkipLeap(obj);
        obj = recalcNumPoints(obj);
        
        % Check that the skip has not lead to a negative number of points -
        % this means it is too big
        if obj.NumPoints<1
            error('stats:qrandset:SkipTooLarge', ...
                'Skip value must leave at least one point in the set.');
        end
        end

        function obj = set.Leap(obj, val)
        if ~checkRealScalarInt(val)
            error('stats:qrandset:InvalidLeap', ...
                'Leap value must be a positive scalar integer.');
        end
        if val<0
            error('stats:qrandset:InvalidLeap', ...
                'Leap value must be greater than or equal to zero.');
        end
        obj.Leap = double(val);
        obj = alterSkipLeap(obj);
        obj = recalcNumPoints(obj);
        end

        function T = get.Type(obj)
        % This redirects to a protected method so it can be overridden
        % by subclasses, since get methods cannot be directly
        % overridden yet.
        T = getType(obj);
        end

        function S = get.ScrambleMethod(obj)
        S = obj.ScrambleData;
        end

        function obj = set.ScrambleMethod(obj, S)
        % Only allow full scramble structures to be set.
        if ~isempty(S) && ~isScrambleStruct(S)
            error('stats:qrandset:InvalidScrambleMethod', ...
                ['ScrambleMethod must either be empty or a structure ' ...
                'array containing the fields ''Type'' and ''Options''.']);
        end

        obj = scramble(obj, 'clear');
        for n = 1:numel(S)
            obj = scramble(obj, S(n));
        end
        end
    end

    % Helpers for the set and get methods
    methods(Access = 'protected')
        function T = getType(obj)
        %GETTYPE Get a string describing the point set type.
        %   GETTYPE(P) returns a string that contains the name of the point
        %   set type.

        T = 'Unknown';
        end

        function NDims = getMaxDims(obj)
        %GETMAXDIMS Get the maximum number of dimensions supported.
        %   GETMAXDIMS(P) returns the maximum number of dimensions
        %   supported by the point set.  The default value of this is inf.

        NDims = inf;
        end

        function obj = alterSkipLeap(obj)
        %ALTERSKIPLEAP Respond to Skip or Leap changes.
        %   ALTERSKIPLEAP(P) is called when either the Skip or Leap is
        %   altered.

        obj.HasSkipLeap = obj.Skip>0 || obj.Leap>0;
        end

        function obj = recalcNumPoints(obj)
        %RECALCNUMPOINTS Recalculate the number of points in the set.
        %   RECALCNUMPOINTS(P) is called when the Skip or Leap properties
        %   are altered.  This updates the number of points in the
        %   sequence.
        %
        %   The number of points is updated and cached instead of
        %   calculated on demand for performance reasons.

        % Get number of points in basic sequence
        N = getNumPoints(obj);

        % Adjust for skipping and leaping
        N = N - obj.Skip;
        N = ceil(N/(obj.Leap+1));

        obj.NumPoints = N;
        end

        function N = getNumPoints(obj)
        %GETNUMPOINTS Return number of points in the set.
        %   GETNUMPOINTS(P) returns the number of points that are in the
        %   point set S.  This function does not take into account any skip
        %   or leap settings.

        N = 0;
        end
    end

    % Display  and other information methods
    methods
        function disp(obj)
        %DISP Display a qrandset object.
        %   DISP(P) displays the properties of the quasi-random point set
        %   S, without printing the variable name.  DISP prints out the
        %   number of dimensions and points in the point-set, and follows
        %   this with the list of all property values for the object.
        %
        %   See also QRANDSET.

        if strcmp(get(0,'FormatSpacing'),'loose')
            LooseLine = '\n';
        else
            LooseLine = '';
        end

        fprintf('    %s point set in %d dimensions (%d points)\n', ...
            obj.Type, obj.Dimensions, obj.NumPoints);
        fprintf(LooseLine);
        fprintf('    Properties:\n');
        dispProperties(obj)
        fprintf(LooseLine);
        end

        
        function varargout = size(obj, dim)
        %SIZE Size of point set.
        %   D = SIZE(P), for the point set P, returns the two-element row
        %   vector D = [M,N] containing the number of points in the point
        %   set and the number of dimensions the points are in. These
        %   correspond to the number of rows and columns in the matrix that
        %   would be produced by the expression P(:,:).
        %
        %   [M,N] = SIZE(P) returns the number of points and dimensions for
        %   P as separate output variables.
        %
        %   M = SIZE(P,DIM) returns the length of the dimension specified
        %   by the scalar DIM.  For example, SIZE(P,1) returns the number
        %   of rows (points in the point set). If DIM is greater than 2, M
        %   will be 1.
        %
        %   Example:
        %      P = sobolset(12);
        %
        %      d = size(P)       returns  d = [9.0072e+015 12]
        %      [m,n] = size(P)   returns  m = 9.0072e+015, n = 12
        %      m2 = size(P, 2)   returns  m2 = 12
        %
        %   See also DIMENSIONS, QRANDSET, LENGTH, NDIMS.

        if nargin==1
            if nargout<2
                varargout = {[obj.NumPoints, obj.Dimensions]};
            else
                varargout = repmat({1}, 1, nargout);
                varargout{1} = obj.NumPoints;
                varargout{2} = obj.Dimensions;
            end
        else
            % Dimension was specified
            if ~checkRangeScalarInt(dim, 1, inf)
                error('stats:QRPointSet:InvalidDimension', ...
                    'DIM must be a positive integer scalar.');
            end
            if dim==1
                varargout = {obj.NumPoints};
            elseif dim==2
                varargout = {obj.Dimensions};
            else
                varargout = {1};
            end
        end
        end


        function L = length(obj)
        %LENGTH Length of point set.
        %   LENGTH(P) returns the number of points in the point set P. It
        %   is equivalent to SIZE(P, 1).
        %
        %   See also DIMENSIONS, QRANDSET, SIZE.

        L = obj.NumPoints;
        end


        function N = ndims(obj)
        %NDIMS Number of dimensions in matrix
        %   N = NDIMS(P) returns the number of dimensions in the matrix
        %   that is created by the syntax P(:,:).  Since this is always a
        %   2-dimensional matrix, N is always equal to 2.
        %
        %   See also SIZE.

        N = 2;
        end
    end
    
    
    methods(Hidden)
        function dispProperties(obj)
        %DISPPROPERTIES Display object property values.
        %   DISPPROPERTIES(P) displays a list of the properties and their
        %   current values for the quasi-random point set P.
        %
        %   See also DISP.

        fprintf('              Skip : %d\n', obj.Skip);
        fprintf('              Leap : %d\n', obj.Leap);

        S = obj.ScrambleData;
        if isempty(S)
            ScrambleStr = 'none';
        elseif isscalar(S)
            ScrambleStr = S.Type;
        else
            SNames = {S.Type};
            ScrambleStr = sprintf('%s, ', SNames{:});
            ScrambleStr = ['{', ScrambleStr(1:end-2), '}'];
        end
        fprintf('    ScrambleMethod : %s\n', ScrambleStr);
        end
    end


    % Scrambling
    methods
        function obj = scramble(obj, Action, varargin)
        %SCRAMBLE Modify scramble settings.
        %   R = SCRAMBLE(P,TYPE,P1,P2,...) returns a copy of the point set
        %   P, with a new scramble applied to it.  If the new scramble is
        %   not compatible with any existing scramble settings in P then
        %   the command produces an error.
        %
        %   TYPE is a string that specifies what kind of scrambling to
        %   apply.  Different point sets support different scramble types
        %   as outlined in the help for each point set class. Where
        %   applicable, parameters for the scrambling are passed in as
        %   additional arguments P1, P2...Pn. An error is produced if an
        %   invalid scramble type is used for a point set.
        %
        %   R = SCRAMBLE(P,'clear') removes all of the current scrambling
        %   settings in P.
        %
        %   R = SCRAMBLE(P) removes all of the scrambles from P and then
        %   re-adds them in the order they were originally applied. This
        %   can result in a different point set to the original one because
        %   many scrambling schemes rely on random
        %   numbers.
        %
        %   The current scramble settings are accessed by getting the
        %   SCRAMBLEMETHOD property of P.  This contains a structure array
        %   that consists of two fields:
        %
        %      Type    : A string describing the name of the scramble.
        %      Options : A cell array of parameter values for the scramble.
        %
        %   See also SCRAMBLEMETHOD, SOBOLSET, HALTONSET.

        if nargin==1
            % Rescramble
            Action = 'reapply';
        end

        % Check for a ScrambleMethod
        if isstruct(Action) ...
                && isscalar(Action) ...
                && isfield(Action, 'Type') ...
                && isfield(Action, 'Options')
            varargin = Action.Options;
            Action = Action.Type;
        end

        if ischar(Action)
            switch Action
                case 'clear'
                    obj = obj.clearScramble;
                case 'reapply'
                    S = obj.ScrambleData;
                    obj = obj.clearScramble;
                    for n = 1:numel(S)
                        obj = obj.addScramble(S(n));
                    end
                otherwise
                    % Add the new scramble
                    S = struct('Type', Action, 'Options', {varargin});
                    S = checkScramble(obj, S);
                    obj = addScramble(obj, S);
            end
        else
            error('stats:qrandset:InvalidArgument', ...
                'Scramble type must be a string or a structure.');
        end
        end
    end

    
    methods(Access = 'protected')
        function SNames = getScrambleList(obj)
        %GETSCRAMBLELIST Get the list of valid scramble names.
        %   GETSCRAMBLELIST(P) returns a cell array of the valid scramble
        %   type names for this point set.  These names are used to check
        %   that applied scrambles are valid.

        SNames = {};
        end

        function obj = addScramble(obj, S)
        %ADDSCRAMBLE Add a scramble to the point set.
        %   ADDSCRAMBLE(P,S) adds the scramble defined by the structure S
        %   to the object.

        obj.ScrambleData = [obj.ScrambleData, S];
        end

        function obj = clearScramble(obj)
        %CLEARSCRAMBLE Clear all scrambles from the object.
        %   CLEARSCRAMBLE(P) clears all of the scrambles from the object.

        obj.ScrambleData = struct('Type', {}, 'Options', {});
        end

        function S = checkScramble(obj, S)
        %CHECKSCRAMBLE Check whether a new scramble can be added.
        %   S = CHECKSCRAMBLE(P,S) checks whether the scramble defined by
        %   the structure S is valid and can be set.  This method errors if
        %   it is not.  Modifications to the scramble data such as
        %   completing the name correctly may be done here.

        if ~isempty(S)
            % Check that the scramble name is allowed
            Matched = [];
            if ~isempty(S.Type)
                ValidNames = getScrambleList(obj);
                Matched = strmatch(lower(S.Type), lower(ValidNames));
            end
            if length(Matched)>1
                error('stats:qrandset:AmbiguousScramble', ...
                    'Ambiguous scramble type:  ''%s''.', S.Type);
            elseif isempty(Matched)
                error('stats:qrandset:UnknownScramble', ...
                    'Unknown scramble type:  ''%s''.', S.Type);
            end

            % Convert type name to correct case
            S.Type = ValidNames{Matched};
        end
        end
    end

    % Main point set generation methods
    methods
        function pts = net(obj, NetSize)
        %NET Generate initial net of points.
        %   NET(P,S) generates the net of size S from the point set P. The
        %   S-by-D matrix that is returned contains the first S points in D
        %   dimensions from the point set.
        %
        %   Example:
        %      Get the first 1024 points from the Sobol sequence:
        %         P = sobolset(10);
        %         X = net(P,1024)
        %
        %   See also SUBSREF, QRANDSTREAM.

        if ~checkRangeScalarInt(NetSize, 0, obj.NumPoints)    
            error('stats:qrandset:InvalidNetSize', ...
                'Net size must be a scalar integer between 1 and the number of points in the set..');
        end
        pts = generateSequence(obj, double(NetSize));
        end
    end

    % Utility methods
    methods(Access = 'protected')
        function I = indexSkipAndLeap(obj, I)
        %INDEXSKIPANDLEAP Convert a public point set index into original index.
        %   INDEXSKIPANDLEAP(P,I) returns the index into the underlying
        %   point set that I represents.  This adds in the initial skip and
        %   any leaping.

        if obj.HasSkipLeap
            I = obj.Skip + I + (I-1)*obj.Leap;
        end
        end
    end

    % qrandstream interface methods.  These are hidden as they aren't very
    % useful for normal usage.
    methods(Hidden = true)
        function StreamState = createStreamState(obj)
        %CREATESTREAMSTATE Create an appropriate qrandstate object.
        %   CREATESTREAMSTATE(P) is called when a stream is generated from
        %   a point set.   It must return a new object of class qrandstate.
        %   Subclasses may return custom state classes that include
        %   additional information.

        StreamState = qrandstate;
        end

        function pts = getStreamPoints(obj, StreamState, Count)
        %GETSTREAMPOINTS Generate a set of points using a stream state.
        %   GETSTREAMPOINTS(P,STATE,COUNT) generates COUNT points using the
        %   information in the StreamState object STATE as the start point.
        %   The StreamState object is updated after the operation so that a
        %   subsequent call will generate the next set of numbers in the
        %   set.

        % Check that the stream will not hit the limits of the point set if
        % Count points are generated.  If it will, we need to generate the
        % points in two parts, resetting the state in between.  The
        % calculations here need to be done carefully to avoid overflowing
        % the flint precision limit of a double.
        np = obj.NumPoints;

        if Count<(np - StreamState.Index + 1)
            % There are enough points left for us to generate all of
            % the required ones and to leave a next index for the state
            % to be set to.
            pts = generateStream(obj, StreamState, Count);
        else
            pts = [];
            CountLeft = Count;
            while CountLeft>0
                NumAvail = max(0, np - StreamState.Index + 1);
                Count = min(CountLeft, NumAvail);

                % Call protected method to generate points. This method may be
                % overridden by subclasses.
                pts = [pts; generateStream(obj, StreamState, Count)];
                CountLeft = CountLeft-Count;

                if Count==NumAvail
                    % Need to reset the stream back to the beginning
                    resetState(StreamState, 1);
                end

            end
        end
        end
    end



    % Point generation methods that subclasses are likely to override
    methods (Access = 'protected')
        function X = generateSequence(obj, Count)
        %GENERATESEQUENCE Generate a set of successive points.
        %   GENERATESEQUENCE(P,COUNT) generates COUNT points from the set.
        %   This method contains the implementation used by NET. The
        %   default implementation calls GENERATESINGLE multiple times. It
        %   should be overloaded by child classes that can provide a faster
        %   implementation than this.

        X = zeros(Count, obj.Dimensions);
        for n = 1:Count
            X(n,:) = generateSingle(obj, n);
        end
        end

        function X = generateIndexed(obj, Idx)
        %GENERATEINDEXED Generate a set of specified points.
        %   GENERATESEQUENCE(P,IDX) where IDX is an index vector generates
        %   length(IDX) points from the point set.  This method contains
        %   the implementation used by SUBSREF. The default implementation
        %   calls GENERATESINGLE multiple times. It should be overloaded by
        %   child classes that can provide a faster implementation than
        %   this.

        X = zeros(numel(Idx), obj.Dimensions);
        for n = 1:numel(Idx)
            X(n,:) = generateSingle(obj, Idx(n));
        end
        end

        function X = generateStream(obj, StreamState, Count)
        %GENERATESTREAM Generate a set of points using a stream state.
        %   GENERATESTREAM(P,STATE,COUNT) generates COUNT points using the
        %   information in the StreamState object STATE as the start point.
        %   The StreamState object is updated after the operation so that a
        %   subsequent call will generate the next set of numbers in the
        %   set.

        X = generateSequence(obj, StreamState.Index, Count);
        StreamState.Index = StreamState.Index+Count;
        end
    end

    % Point generation method that subclasses must override
    methods(Abstract, Access = 'protected')
        X = generateSingle(obj, Index)
        %GENERATESINGLE Generate a single point.
        %   GENERATESINGLE(P,IDX) where IDX is a scalar index generates a
        %   single specified point from the point set. This method is used
        %   by the default implementations of all other generate methods
        %   and must be overloaded by subclasses.
    end

    % Override subsref to allow subscripting
    methods
        function varargout = subsref(obj, S)
        %SUBSREF Subscripted reference for qrandset.
        %   X = P(I,J) returns a matrix that contains a subset of the
        %   points from the point set P.  The indices in I select points
        %   from the set and the indices in J select columns from those
        %   points.  I and J are vector of positive integers or logical
        %   vectors.  A colon used as a subscript, as in P(I,:), indicates
        %   the entire row (or column).
        %
        %   X = SUBSREF(P,S) is called for the syntax P(I), P{I}, or P.I.
        %   S is a structure array with the fields:
        %      type -- string containing '()', '{}', or '.' specifying the
        %              subscript type.
        %      subs -- Cell array or string containing the actual subscripts.
        %
        %   Example:
        %      P = sobolset(5);
        %      X = P(1:10,:)      returns all columns of the first 10 points
        %      X = P(end,1)       returns the first column of the last point
        %      X = P([1,4,5], :)  returns points 1, 4 and 5
        %
        %   See also QRANDSET, SUBSREF.

        if strcmp(S(1).type, '.')
            Identifier = S(1).subs;
            if isPublic(obj, Identifier, 'get') || isPublic(obj, Identifier, 'call')
                % Property access or method call
                [varargout{1:nargout}] = builtin('subsref', obj, S);
            else
                error('stats:qrandset:NoSuchMethodOrField', ...
                    'No appropriate method or public field %s for class %s.', ...
                    Identifier, class(obj));
            end

        elseif strcmp(S(1).type, '()')
            % Get the indexed points from the set
            varargout{1} = subsrefBrackets(obj, S(1).subs);

            % Pass on to next level of subscripts if required.
            if length(S)>1
                varargout{1} = subsref(varargout{1}, S(2:end));
            end

        else  % {} index
            error('stats:qrandset:CellRefFromNonCell', ...
                'Cell contents reference from a non-cell array object.');
        end
        end
    end

    % Override subsasgn to prevent assignment
    methods(Hidden)
        function varargout = subsasgn(obj, S, Value)
        %SUBSASGN Subscripted assignment for qrandset.
        %   P = SUBSASGN(P,S,X) is called for the syntax P(I)=X, P{I}=X, or
        %   P.I=X.  S is a structure array with the fields:
        %      type -- string containing '()', '{}', or '.' specifying the
        %              subscript type.
        %      subs -- Cell array or string containing the actual subscripts.
        %
        %   See also QRANDSET, SUBSASGN.

        if strcmp(S(1).type, '.')
            Identifier = S(1).subs;
            if isPublic(obj, Identifier, 'set')
                % Set a property
                [varargout{1:nargout}] = builtin('subsasgn', obj, S, Value);

            elseif isPublic(obj, Identifier, 'get')
                % Property is visible so we don't want to pretend
                % it doesn't exist
                error('stats:qrandset:SetProhibited', ...
                    'Setting the ''%s'' property of the class %s is not allowed.', ...
                    Identifier, class(obj));
            else
                error('stats:qrandset:NoSuchField', ...
                    'No public field %s exists for class %s.', ...
                    Identifier, class(obj));
            end

        elseif strcmp(S(1).type, '()')
            error('stats:qrandset:AssignmentNotAllowed', ...
                'Assignment to a %s using () indexing is not allowed.', ...
                class(obj));
        else % {} assignment
            error('stats:qrandset:CellAssToNonCell', ...
                'Cell contents assignment to a non-cell array object.');
        end
        end

        % Override and hide methods for concatenation and general array
        % manipulation.
        function varargout = horzcat(varargin), throwCatError; end
        function varargout = vertcat(varargin), throwCatError; end
        function varargout = cat(varargin),     throwCatError; end
        function varargout = repmat(varargin),  throwCatError; end
        function varargout = transpose(varargin)
            error('stats:qrandset:TransposeNotAllowed', ...
                'Transposing qrandset objects is not allowed.');
        end
        function varargout = ctranspose(varargin)
            error('stats:qrandset:TransposeNotAllowed', ...
                'Transposing qrandset objects is not allowed.');
        end
        function varargout = reshape(varargin)
            error('stats:qrandset:ReshapeNotAllowed', ...
                'Reshaping qrandset objects is not allowed.');
        end
        function varargout = permute(varargin)
            error('stats:qrandset:PermuteNotAllowed', ...
                'Permuting qrandset objects is not allowed.');
        end 
    end
    methods(Hidden,Static)
        function obj = empty(varargin)
            error('stats:qrandset:EmptyNotAllowed', ...
                'Empty arrays of qrandset objects are not allowed.');
        end
    end
end


function Names = getPublic(obj, Type)
% Return the list of public names for the specified type of operation.
% Type may be one of 'get', 'set' or 'call'.

% The list of public identifiers will depend on the exact class of the
% object, so a list is held for each unique class.

persistent PublicIdents
if isempty(PublicIdents)
    % Initialise the database of lists-per-class to be empty
    PublicIdents = struct;
end

Cname = class(obj);
if ~isfield(PublicIdents, Cname)
    % Initialise the lists of public identifiers for this class
    C = metaclass(obj);
    P = [C.Properties{:}];
    PropGet = strcmp({P.GetAccess}, 'public');
    PropSet = strcmp({P.SetAccess}, 'public');
    PropNames = {P.Name};

    M = [C.Methods{:}];
    MethAccess = strcmp({M.Access}, 'public');
    MethNames = {M.Name};

    PublicIdents.(Cname).get = PropNames(PropGet);
    PublicIdents.(Cname).set = PropNames(PropSet);
    PublicIdents.(Cname).call = MethNames(MethAccess);
end

Names = PublicIdents.(Cname).(Type);
end


function OK = isPublic(obj, Ident, Type)
% Checks whether an identifier is a public property or method.

OK = any(strcmp(Ident, getPublic(obj, Type)));
end


function [NMatches, Corrected] = isPublicInexact(obj, Ident, Type)
% Check whether an identifier matches inexactly to a public property or
% method and return the corrected version

CorrectIdents = getPublic(obj, Type);
MatchIdx = strmatch(lower(Ident), lower(CorrectIdents));
NMatches = length(MatchIdx);
Corrected = '';
if NMatches==1
    Corrected = CorrectIdents{MatchIdx};
end
end

function throwCatError
E = MException('stats:qrandset:NoCatAllowed', ...
    'Concatenation of qrandset objects is not allowed.\nUse a cell array to contain multiple objects.');
E.throwAsCaller;
end

function OK = isScrambleStruct(S)
OK = isstruct(S) && isfield(S, 'Type') && isfield(S, 'Options');
end

function pts = subsrefBrackets(obj, IdxArgs)
% Implements () indexing for the object

COL_INDEX_OP = 0;
if length(IdxArgs)==2 ...
        || (length(IdxArgs)>2 && areHigherDimsOne(IdxArgs))
    % Take point indices from first arg and columns from
    % second.
    PtIdx = IdxArgs{1};
    if ischar(PtIdx) && strcmp(PtIdx, ':')
        PtIdx = 1:obj.NumPoints;
    elseif islogical(PtIdx)
        PtIdx = find(PtIdx);
    elseif ~checkRangeInts(PtIdx, 1, obj.NumPoints)
        error('stats:qrandset:InvalidIndices', ...
            'Point set indices must be integers between 1 and the number of points in the set.');
    end
    
    COL_INDEX_OP = 1;
    Cols = IdxArgs{2};
    if ischar(Cols) && strcmp(Cols, ':')
        % No need to do a column index
        COL_INDEX_OP = 0;
    elseif ~islogical(Cols) && ~checkRangeInts(Cols, 1, obj.Dimensions)
        error('stats:qrandset:InvalidIndices', ...
            'Point dimension indices must be integers between 1 and the number of dimensions in the set.');
    end
    
elseif length(IdxArgs)==1
    % Linear index: need to work out which point indices
    % are required
    PtIdx = IdxArgs{1};
    if islogical(PtIdx)
        PtIdx = find(PtIdx);
    elseif ~checkRangeInts(PtIdx, 1, (obj.NumPoints*obj.Dimensions))
        error('stats:qrandset:InvalidIndices', ...
            'Point set indices must be integers between 1 and the number of values in the set.');
    end
    
    [PtIdx, Cols] = ind2sub(size(obj), PtIdx);
    COL_INDEX_OP = 2;
    
else
    % Too many dimensions and the trailing ones are not equal to 1.
    error('stats:qrandset:badsubscript', ...
        'Index out of bounds.');
end

% Get points
if ~isempty(PtIdx)
    pts = generateIndexed(obj, double(PtIdx(:).'));
else
    pts = zeros(0, obj.Dimensions);
end

if COL_INDEX_OP==1
    % Index a subset of the columns
    pts = pts(:, Cols);
elseif COL_INDEX_OP==2
    if ~isempty(Cols)
        % Work out which columns in each row correspond to the original linear
        % indices
        I = sub2ind(size(pts), reshape(1:numel(Cols), size(Cols)), Cols);
        pts = pts(I);
    else
        pts = [];
    end
end

end

function OK = areHigherDimsOne(IdxArgs)
% Check whether the 3rd and higher dimensions in an index argument are all
% one.  IdxArgs must be a cell of length 3 or greater.
OK = all(cellfun(@(x) isequal(x, 1), IdxArgs(3:end)));
end



function ok = checkRangeInts(val, mn, mx)
ok = checkRealInts(val) && all(val(:)>=mn) && all(val(:)<=mx);
end

function ok = checkRealInts(val)
ok = isnumeric(val) ...
    && all(val(:)==fix(val(:))) ...
    && all(isfinite(val(:)));
end


function ok = checkRangeScalarInt(val, mn, mx)
ok = checkRealScalarInt(val) && (val>=mn) && (val<=mx);
end

function ok = checkRealScalarInt(val)
ok = isnumeric(val) ...
    && isscalar(val) ...
    && val==fix(val) ...
    && isfinite(val);
end
