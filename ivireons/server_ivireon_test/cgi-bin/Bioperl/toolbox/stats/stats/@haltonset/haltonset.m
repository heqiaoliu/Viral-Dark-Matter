classdef haltonset < qrandset
%HALTONSET Create a Halton sequence point set.
%   P = HALTONSET(D) constructs a new Halton sequence point set object in D
%   dimensions.
%
%   P = HALTONSET(D,PROP,VAL,...) specifies a set of property-value
%   pairs that are applied to the point set before creating it.
%
%   HALTONSET is a quasi-random point set class that produces points from
%   the Halton sequence.  This point set object has the following
%   properties and methods:
%
%   haltonset properties:
%     Read-only:
%      Type             - Name of the sequence ('Halton').
%      Dimensions       - Number of dimensions in the set (fixed at creation).
%
%     Settable:
%      Skip             - Number of initial points to omit.
%      Leap             - Number of points to miss out between returned points.
%      ScrambleMethod   - Structure containing the current scramble settings.
%
%   haltonset methods:
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
%   Halton sets support the following scramble types:
%
%      Name             - Additional options
%      ===================================================
%      RR2              - A permutation of the radical inverse coefficients
%                         derived by applying a reverse-radix operation to
%                         all of the possible coefficient values.  There
%                         are no additional options for this scramble.
%
%   Examples:
%
%      Create a 5-dimensional point set and get the first 1024 points:
%         P = haltonset(5);
%         X = net(P,1024)
%
%      Create a point set and get the 1st, 3rd, 5th... points:
%         P = haltonset(5);
%         X = P([1 3 5 7 9 11 13],:)
%
%      Create a scrambled point set:
%         P = haltonset(5);
%         P = scramble(P,'RR2');
%         X = net(P,1024)
%
%   See also NET, QRANDSTREAM, SCRAMBLE, SUBSREF.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:20:42 $

%   References:
%      [1] Kocis, L., and W. J. Whiten, "Computational
%      Investigations of Low-Discrepancy Sequences," ACM Transactions on
%      Mathematical Software, Vol. 23, No. 2, pp. 266-294, 1997.


    % Generation algorithm properties
    properties(SetAccess = 'private', GetAccess = 'private')
        % Prime bases to use for each dimension
        Bases = [];

        % length (Base-1) coefficient permutation vectors for each
        % dimension.  This is only used for smaller numbers of dimensions:
        % above the threshold we calculate the permutations as needed since
        % storing them takes too much memory.
        PerformCoeffPermute = false;
        CoeffPermutations = {};
    end

    % Constructor
    methods
        function obj = haltonset(varargin)
        %HALTONSET Construct a new Halton point set object
        %   HALTONSET(D) constructs a new point set object with D
        %   dimensions.
        %
        %   HALTONSET(D,PROP,VAL,...) specifies a set of property-value
        %   pairs that are applied to the point set before creating the
        %   stream.

        obj = obj@qrandset(varargin{:});

        obj.Bases = getPrimes(obj.Dimensions);
        end
    end

    % Overloaded methods and protected helpers
    methods(Access = 'protected')
        function NPoints = getNumPoints(obj)
        %GETNUMPOINTS Return number of points in the set
        %   GETNUMPOINTS(P) returns the number of points that are in the
        %   point set P.  Halton point sets contain up to 2^53 points.
        %   This function does not take into account any skip or leap
        %   settings.

        NPoints = 2^53;
        end

        function T = getType(obj)
        %GETTYPE Return type of point set
        %   GETTYPE(P) returns the string 'Halton' for this point set.

        T = 'Halton';
        end
    end

    % Scrambling methods
    methods(Access = 'protected')
        function SNames = getScrambleList(obj)
        SNames = {'RR2'};
        end

        function obj = addScramble(obj, S)
        obj = addScramble@qrandset(obj, S);

        % RR2 is the only scramble allowed so it must be this.  Create the
        % permutations for the coefficients.
        if obj.Dimensions<=100
            % Create and store the permutations
            obj.CoeffPermutations = getRR2PermArray(obj.Bases);
        else
            % Use a function to create permutations on-the-fly.  Make
            % sure that the cache is set up for this.
            getRR2Perm(obj.Bases(end));
            obj.CoeffPermutations = {};
        end
        obj.PerformCoeffPermute = true;

        end

        function obj = clearScramble(obj)
        obj = clearScramble@qrandset(obj);
        obj.CoeffPermutations = {};
        obj.PerformCoeffPermute = false;
        end

        function S = checkScramble(obj, S)
        ExistingS = obj.ScrambleMethod;
        if ~isempty(ExistingS)
            error('stats:haltonset:InvalidScramble', ...
                'Only a single scramble may be set at one time.');
        end

        % Call base class check to check the names
        S = checkScramble@qrandset(obj, S);

        if ~isempty(S) && ~isempty(S.Options)
            warning('stats:haltonset:IncorrectScrambleOptions', ...
                'Scramble options for RR2 will be ignored.');
        end
        end
    end

    % Point generation methods
    methods(Access = 'protected')
        function X = generateSingle(obj, Index)
        %GENERATESINGLE Generate a single point.
        %   GENERATESINGLE(P,IDX) where IDX is a scalar index generates a
        %   single specified point from the point set. This method is used
        %   by the default implementations of all other generate methods
        %   and must be overloaded by subclasses.

        X = haltonPoints(obj, indexSkipAndLeap(obj, Index)-1, 1);
        end

        function X = generateSequence(obj, Count)
        %GENERATESEQUENCE Generate a set of successive points.
        %   GENERATESEQUENCE(P,COUNT) generates COUNT points from the set.

        X = haltonPoints(obj, obj.Skip, Count);
        end

        function X = generateIndexed(obj, Idx)
        %GENERATEINDEXED Generate a set of specified points.
        %   GENERATESEQUENCE(P,IDX) where IDX is an index vector generates
        %   length(IDX) points from the point set.  This method contains
        %   the implementation used by SUBSREF. The default implementation
        %   calls GENERATESINGLE multiple times. It should be overloaded by
        %   child classes that can provide a faster implementation than
        %   this.

        X = haltonPoints(obj, indexSkipAndLeap(obj, Idx)-1);
        end

        function X = generateStream(obj, StreamState, Count)
        %GENERATESTREAM Generate a set of points using a stream state.
        %   GENERATESTREAM(P,STATE,COUNT) generates COUNT points using the
        %   information in the StreamState object STATE as the start point.
        %   The StreamState object is updated after the operation so that a
        %   subsequent call will generate the next set of numbers in the
        %   set.

        CorrectedIndex = StreamState.SequenceIndex;
        if isempty(CorrectedIndex)
            CorrectedIndex = indexSkipAndLeap(obj, StreamState.Index)-1;
        end
        X = haltonPoints(obj, CorrectedIndex, Count);
        StreamState.Index = StreamState.Index+Count;
        StreamState.SequenceIndex =CorrectedIndex + (obj.Leap+1)*Count;
        end
    end

    methods(Access = 'private')
        X = haltonPoints(obj, Start, Count)
    end
end
