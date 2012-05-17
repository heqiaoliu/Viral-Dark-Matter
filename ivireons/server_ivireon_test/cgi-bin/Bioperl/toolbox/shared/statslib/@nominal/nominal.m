classdef nominal < categorical
%NOMINAL Arrays for nominal data.
%   Nominal arrays are used to store discrete values that are not numeric and
%   that do not have an ordering.  A nominal array provides efficient storage
%   and convenient manipulation of such data, while also maintaining
%   meaningful labels for the values.
%
%   Use the NOMINAL constructor to create a nominal array from a numeric,
%   logical, or character array, or from a cell array of strings.  Nominal
%   arrays can be subscripted, concatenated, reshaped, etc. much like ordinary
%   numeric arrays.  You can test equality between elements of two nominal
%   arrays, or between a nominal array and a single string representing a
%   nominal value.  Type "methods nominal" for more operations available for
%   nominal arrays.  Nominal arrays are often used as grouping variables.
%
%   Each nominal array carries along a list of possible values that it can
%   store, known as its levels.  The list is created when you create a nominal
%   array, and you can access it using the GETLEVELS method, or modify it
%   using the ADDLEVELS, MERGELEVELS, or DROPLEVELS methods.  Assignment to
%   the array will also add new levels automatically if the values assigned
%   are not already levels of the array.
%
%   You can change the order of the list of levels for a nominal array using
%   the REORDERLEVELS method, however, that order has no significance for the
%   values in the array.  The order is used only for display purposes, or when
%   you convert the nominal array to numeric values using methods such as
%   DOUBLE or SUBSINDEX, or compare two arrays using ISEQUAL.  If you need to
%   work with values that have a mathematical ordering, you should use an
%   ordinal array instead.
%
%   Examples:
%      % Create a nominal array from string data in a cell array
%      colors = nominal({'r' 'b' 'g'; 'g' 'r' 'b'; 'b' 'r' 'g'},{'blue' 'green' 'red'})
%
%      % Find elements meeting a criterion
%      colors == 'red'
%      ismember(colors,{'red' 'blue'})
%
%      % Compare two nominal arrays
%      colors2 = fliplr(colors)
%      colors == colors2
%
%   See also NOMINAL/NOMINAL, ORDINAL, GROUPINGVARIABLE, NOMINAL/GETLEVELS.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5.2.1 $  $Date: 2010/06/14 14:28:37 $

    methods
        function b = nominal(varargin) %nominal(a,labels,levels,edges)
%NOMINAL Create a nominal array.
%   B = NOMINAL(A) creates a nominal array from A.  A is a numeric, logical,
%   character, or categorical array, or a cell array of strings. NOMINAL
%   creates levels of B from the sorted unique values in A, and creates
%   default labels for them.
%
%   B = NOMINAL(A,LABELS) creates a nominal array from A, labeling the levels
%   in B using LABELS.  LABELS is a character array or cell array of strings.
%   NOMINAL assigns the labels to levels in B in order according to the sorted
%   unique values in A.
%
%   B = NOMINAL(A,LABELS,LEVELS) creates a nominal array from A, with possible
%   levels defined by LEVELS.  LEVELS is a vector whose values can be compared
%   to those in A using the equality operator.  NOMINAL assigns labels to each
%   level from the corresponding elements of LABELS.  If A contains any values
%   not present in LEVELS, the levels of the corresponding elements of B are
%   undefined.  Pass in [] for LABELS to allow NOMINAL to create default labels.
%
%   B = NOMINAL(A,LABELS,[],EDGES) creates a nominal array by binning the
%   numeric array A, with bin edges given by the numeric vector EDGES.  The
%   uppermost bin includes values equal to the rightmost edge.  NOMINAL
%   assigns labels to each level in B from the corresponding elements of
%   LABELS.  EDGES must have one more element than LABELS.
%
%   By default, an element of B is undefined if the corresponding element of A
%   is NaN (when A is numeric), an empty string (when A is character), or
%   undefined (when A is categorical).  NOMINAL treats such elements as
%   "undefined" or "missing" and does not include entries for them among the
%   possible levels for B.  To create an explicit level for those elements
%   instead of treating them as undefined, you must use the LEVELS input, and
%   include NaN, the empty string, or an undefined element.
%
%   You may include duplicate labels in LABELS in order to merge multiple
%   values in A into a single level in B.
%
%   Examples:
%      colors1 = nominal({'r' 'b' 'g'; 'g' 'r' 'b'; 'b' 'r' 'g'},{'blue' 'green' 'red'})
%      colors2 = nominal({'r' 'b' 'g'; 'g' 'r' 'b'; 'b' 'r' 'g'}, ...
%          {'red' 'green' 'blue'},{'r' 'g' 'b'})
%      toss = nominal(randi([1 4],5,2),{'odd' 'even' 'odd' 'even'},1:4)
%
%   See also NOMINAL, ORDINAL, HISTC.

            b = b@categorical(varargin{:});
        end % nominal constructor
    end

    methods(Static = true)
        function a = empty(varargin)
            if nargin == 0
                codes = [];
            else
                codes = zeros(varargin{:});
                if ~isempty(codes)
                        error('stats:nominal:empty:EmptyMustBeZero', ...
                              'At least one dimension must be zero.');
                end
            end
            a = nominal(codes);
        end
    end
    
    methods(Access = 'public', Hidden = true)
        [b,varargout] = sort(a,dim,mode)
        
        function [y,i] = sortrows(varargin),  throwUndefinedError; end
    end
end

function throwUndefinedError
st = dbstack;
name = regexp(st(2).name,'\.','split');
me = MException(['stats:' name{1} ':UndefinedFunction'], ...
      'Undefined function or method ''%s'' for input arguments of type ''%s''.',name{2},name{1});
throwAsCaller(me);
end

% The following function is required by the compiler because the inferior
% class depends on it.
%#function handle_graphicsrc
