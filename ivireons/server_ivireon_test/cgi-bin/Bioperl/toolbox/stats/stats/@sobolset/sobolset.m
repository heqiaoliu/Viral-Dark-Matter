classdef sobolset < qrandset
%SOBOLSET Create a Sobol sequence point set.
%   P = SOBOLSET(D) constructs a new Sobol sequence point set in D
%   dimensions.
%
%   P = SOBOLSET(D,PROP,VAL,...) specifies a set of property-value pairs
%   that are applied to the point set before creating it.
%
%   SOBOLSET is a quasi-random point set class that produces points from
%   the Sobol sequence. The Sobol sequence is a base-2 digital sequence
%   that fills space in a highly uniform manner.  This point set object
%   has the following properties and methods:
%
%   sobolset properties:
%     Read-only:
%      Type             - Name of the sequence ('Sobol').
%      Dimensions       - Number of dimensions in the set (fixed at creation).
%
%     Settable:
%      Skip             - Number of initial points to omit.
%      Leap             - Number of points to miss out between returned points.
%      PointOrder       - Point generation method: 'standard' or 'graycode'.
%      ScrambleMethod   - Structure containing the current scramble settings.
%
%   sobolset methods:
%      scramble         - Apply a new scramble.
%      net              - Get an initial net from the sequence.
%      size             - Get the size of the point set.
%      length           - Get the number of points in the sequence.
%
%   Indexing:
%      Points in the set can be accessed by indexing using parentheses, for
%      example P(1:10, :) returns a matrix that contains all of the columns
%      of the first 10 points in the set.
%
%   Sobol sets support the following scramble types:
%
%      Name               - Description and options
%      ====================================================================
%      MatousekAffineOwen - A random linear scramble combined with a random
%                           digital shift.  The structure of the random
%                           matrix is that described in Matousek (1998).
%                           There are no additional options for this
%                           scramble.
%
%   Examples:
%
%      Create a 5-dimensional point set and get the first 1024 points:
%         P = sobolset(5);
%         X = net(P,1024)
%
%      Create a point set and get the 1st, 3rd, 5th... points:
%         P = sobolset(5);
%         X = P([1 3 5 7 9 11 13], :)
%
%      Create a scrambled point set:
%         P = sobolset(5);
%         P = scramble(P,'MatousekAffineOwen');
%         X = net(P,1024)
%
%   See also NET, QRANDSTREAM, SCRAMBLE, SUBSREF.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:17 $

%   References:
%      [1] Bratley, P., and B. L. Fox, "ALGORITHM 659 Implementing Sobol's
%          Quasirandom Sequence Generator," ACM Transactions on
%          Mathematical Software, Vol. 14, No. 1, pp. 88-100, 1988.
%      [2] Joe, S., and F. Y. Kuo, "Remark on Algorithm 659: Implementing 
%          Sobol's Quasirandom Sequence Generator," ACM Transactions on
%          Mathematical Software, Vol. 29, No. 1, pp. 49-57, 2003.
%      [3] Hong, H. S., and F. J. Hickernell, "ALGORITHM 823: Implementing 
%          Scrambled Digital Sequences," ACM Transactions on Mathematical
%          Software, Vol. 29, No. 2, pp. 95-109, 2003.
%      [4] Matousek, J., "On the L2-discrepancy for anchored boxes,"
%          Journal of Complexity, Vol. 14, pp. 527-556, 1998.

    properties
        %POINTORDER Control order of points in the sequence.
        %   The PointOrder property contains a string that specifies the
        %   order in which the Sobol sequence points are produced.  The
        %   property value must be one of 'standard' or 'graycode'.  When
        %   set to 'standard' the points produced match the original Sobol
        %   sequence implementation.  When set to 'graycode', the sequence
        %   is generated using an implentation that uses the Gray code of
        %   the index instead of the index itself.
        %
        %   See also SOBOLSET.
        PointOrder = 'standard';
    end

    % Scrambling data properties
    properties(SetAccess = 'private', GetAccess = 'private')
        DirectionNumbers = [];
        DigitalShifts = [];
        GrayCodeSet = false;
    end

    % Constructor
    methods
        function obj = sobolset(varargin)
        %SOBOLSET Construct a new Sobol point set object.
        %   P = SOBOLSET(D) constructs a new point set object with D
        %   dimensions and returns the object.
        %
        %   P = SOBOLSET(D,PROP,VAL,...) specifies a set of property-value
        %   pairs that are applied to the point set before creating it.

        obj = obj@qrandset(varargin{:});
        if isempty(obj.DirectionNumbers)
            obj.DirectionNumbers = standardDirectionNumbers(obj.Dimensions);
        end
        end
    end


    % Set/get functions
    methods
        function obj = set.PointOrder(obj, val)
        if ~any(strcmpi(val, {'standard', 'graycode'}))
            error('stats:sobolset:InvalidPointOrder', ...
                'PointOrder must be either ''standard'' or ''graycode''.');
        end
        obj.PointOrder = lower(val);
        obj.GrayCodeSet = strcmpi(val, 'graycode');
        end
    end

    methods(Hidden)
        function dispProperties(obj)
        dispProperties@qrandset(obj);
        fprintf('        PointOrder : %s\n', obj.PointOrder);
        end
    end

    % Overloaded methods and protected helpers
    methods(Access = 'protected')
        function NDims = getMaxDims(obj)
        %GETMAXDIMS  Get the maximum number of dimensions supported.
        %   GETMAXDIMS(P) returns the maximum number of dimensions
        %   supported by the point set.  Sobol sets currently support 1111
        %   dimensions.

        NDims = 1111;
        end

        function NPoints = getNumPoints(obj)
        %GETNUMPOINTS Return number of points in the set.
        %   GETNUMPOINTS(P) returns the number of points that are in the
        %   point set P.  Sobol point sets contain 2^53 points.  This
        %   function does not take into account any skip or leap settings.

        NPoints = 2^53;
        end

        function T = getType(obj)
        %GETTYPE Return type of point set.
        %   GETTYPE(P) returns the string 'Sobol' for this point set.

        T = 'Sobol';
        end
    end

    % Scrambling methods
    methods(Access = 'protected')
        function SNames = getScrambleList(obj)
        SNames = {'MatousekAffineOwen'};
        end

        function obj = addScramble(obj, S)
        obj = addScramble@qrandset(obj, S);

        % MatousekAffineOwen is the only scramble allowed so it must be
        % this.  Create new scrambled direction numbers and digital
        % shifts.
        obj.DirectionNumbers = modOwenDirectionNumbers(obj.Dimensions);
        obj.DigitalShifts = digitalShifts(obj.Dimensions);
        end

        function obj = clearScramble(obj)
        obj = clearScramble@qrandset(obj);
        obj.DirectionNumbers = standardDirectionNumbers(obj.Dimensions);
        obj.DigitalShifts = [];
        end

        function S = checkScramble(obj, S)
        ExistingS = obj.ScrambleMethod;
        if ~isempty(ExistingS)
            error('stats:sobolset:InvalidScramble', ...
                'Only a single scramble may be set at one time.');
        end

        % Call base class check to check the names
        S = checkScramble@qrandset(obj, S);

        if ~isempty(S) && ~isempty(S.Options)
            warning('stats:sobolset:IncorrectScrambleOptions', ...
                'Scramble options for MatousekAffineOwen will be ignored.');
        end
        end
    end

    % qrandstream interface methods.
    methods(Hidden = true)
        function StreamState = createStreamState(obj)
        %CREATESTREAMSTATE Create an appropriate qrandstate object.
        %   CREATESTREAMSTATE(P) is called when a stream is generated from
        %   a point set.   It must return a new object of class qrandstate.
        %   Subclasses may return custom state classes that include
        %   additional information.

        StreamState = sobolstate;
        end
    end

    % Point generation method overloads
    methods(Access = 'protected')
        function X = generateSingle(obj, Index)
        %GENERATESINGLE Generate a single point.
        %   GENERATESINGLE(P,IDX) where IDX is a scalar index generates a
        %   single specified point from the sobol point set.

        X = sobolPoint(obj.DirectionNumbers, indexSkipAndLeap(obj, Index) - 1, ...
            obj.GrayCodeSet);
        X = digitalShift(obj, X);
        X = convertToDouble(X);
        end

        function X = generateSequence(obj, Count)
        %GENERATESEQUENCE  Generate a sequence of points.
        %   GENERATESEQUENCE(P,COUNT) generates COUNT points from the
        %   sequence.

        if obj.HasSkipLeap
            X = sobolSequence(obj.DirectionNumbers, obj.Skip, obj.Leap, ...
                Count, obj.GrayCodeSet);
        else
            X = sobolNet(obj.DirectionNumbers, Count, obj.GrayCodeSet);
        end
        X = digitalShift(obj, X);
        X = convertToDouble(X);
        end

        function X = generateIndexed(obj, Idx)
        %GENERATEINDEXED Generate a set of specified points.
        %   GENERATESEQUENCE(P,IDX) where IDX is an index vector generates
        %   length(IDX) points from the point set.  This method contains
        %   the implementation used by SUBSREF. The default implementation
        %   calls GENERATESINGLE multiple times. It should be overloaded by
        %   child classes that can provide a faster implementation than
        %   this.

        X = sobolIndexed(obj.DirectionNumbers, indexSkipAndLeap(obj, Idx)-1, ...
            obj.GrayCodeSet);
        X = digitalShift(obj, X);
        X = convertToDouble(X);
        end

        function X = generateStream(obj, StreamState, Count)
        %GENERATESTREAM Generate a set of points using a stream state.
        %   GENERATESTREAM(P,STATE,COUNT) generates COUNT points using the
        %   information in the StreamState object STATE as the start point.
        %   The StreamState object is updated after the operation so that a
        %   subsequent call will generate the next set of numbers in the
        %   set.

        L = obj.Leap;
        CorrectedIndex = StreamState.SequenceIndex;
        if isempty(CorrectedIndex)
            CorrectedIndex = indexSkipAndLeap(obj, StreamState.Index)-1;
        end

        % Sequence generator function handles the case of PointData is
        % empty
        X = sobolSequence(obj.DirectionNumbers, CorrectedIndex, L, ...
            Count, obj.GrayCodeSet, StreamState.LastPointData);

        StreamState.Index = StreamState.Index+Count;
        StreamState.SequenceIndex = CorrectedIndex + (L+1)*Count;
        if Count>1
            StreamState.LastPointData = X(end,:);
        else
            StreamState.LastPointData = X;
        end

        X = digitalShift(obj, X);
        X = convertToDouble(X);
        end
    end


    % Methods that implement various algorithms for generating Sobol points
    methods(Access = 'private')
        X = digitalShift(obj, X);
    end
end
