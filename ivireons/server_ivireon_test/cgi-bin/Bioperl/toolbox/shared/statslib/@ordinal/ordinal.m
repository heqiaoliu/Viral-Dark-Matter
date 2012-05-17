classdef (InferiorClasses = {?matlab.graphics.axis.Axes}) ordinal < categorical
%ORDINAL Arrays for ordinal data.
%   Ordinal arrays are used to store discrete values that have an ordering but
%   are not numeric.  An ordinal array provides efficient storage and
%   convenient manipulation of such data, while also maintaining meaningful
%   labels for the values.
%
%   Use the ORDINAL constructor to create an ordinal array from a numeric,
%   logical, or character array, or from a cell array of strings.  Ordinal
%   arrays can be subscripted, concatenated, reshaped, sorted, etc. much like
%   ordinary numeric arrays.  You can make comparisons between elements of two
%   ordinal arrays, or between an ordinal array and a single string
%   representing a ordinal value.  Type "methods ordinal" for more operations
%   available for ordinal arrays.  Ordinal arrays are often used as grouping
%   variables.
%
%   Each ordinal array carries along a list of possible values that it can
%   store, known as its levels.  The list is created when you create an
%   ordinal array, and you can access it using the GETLEVELS method, or modify
%   it using the ADDLEVELS, MERGELEVELS, or DROPLEVELS methods.  Assignment to
%   the array will also add new levels automatically if the values assigned
%   are not already levels of the array.  The ordering on values stored in an
%   ordinal array is defined by the order of the list of levels.  You can
%   change that order using the REORDERLEVELS method.
%
%   Examples:
%      % Create an ordinal array from integer data
%      quality = ordinal([1 2 3; 3 2 1; 2 1 3],{'low' 'medium' 'high'})
%
%      % Find elements meeting a criterion
%      quality >= 'medium'
%      ismember(quality,{'low' 'high'})
%
%      % Compare two ordinal arrays
%      quality2 = fliplr(quality)
%      quality == quality2
%
%   See also ORDINAL/ORDINAL, NOMINAL, GROUPINGVARIABLE, ORDINAL/GETLEVELS.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/03/31 18:44:37 $

    methods
        function b = ordinal(varargin) %ordinal(a,labels,levels,edges)
%ORDINAL Create an ordinal array.
%   B = ORDINAL(A) creates an ordinal array from A.  A is a numeric, logical,
%   character, or categorical array, or a cell array of strings. ORDINAL
%   creates levels of B from the sorted unique values in A, and creates
%   default labels for them.
%
%   B = ORDINAL(A,LABELS) creates an ordinal array from A, labeling the levels
%   in B using LABELS.  LABELS is a character array or cell array of strings.
%   ORDINAL assigns the labels to levels in B in order according to the sorted
%   unique values in A.
%
%   B = ORDINAL(A,LABELS,LEVELS) creates an ordinal array from A, with
%   possible levels and their order defined by LEVELS.  LEVELS is a vector
%   whose values can be compared to those in A using the equality operator.
%   ORDINAL assigns labels to each level from the corresponding elements of
%   LABELS.  If A contains any values not present in LEVELS, the levels of the
%   corresponding elements of B are undefined.  Pass in [] for LABELS to allow
%   ORDINAL to create default labels.
%
%   B = ORDINAL(A,LABELS,[],EDGES) creates an ordinal array by binning the
%   numeric array A, with bin edges given by the numeric vector EDGES.  The
%   uppermost bin includes values equal to the rightmost edge.  ORDINAL
%   assigns labels to each level in B from the corresponding elements of
%   LABELS.  EDGES must have one more element than LABELS.
%
%   By default, an element of B is undefined if the corresponding element of A
%   is NaN (when A is numeric), an empty string (when A is character), or
%   undefined (when A is categorical).  ORDINAL treats such elements as
%   "undefined" or "missing" and does not include entries for them among the
%   possible levels for B.  To create an explicit level for those elements
%   instead of treating them as undefined, you must use the LEVELS input, and
%   include NaN, the empty string, or an undefined element.
%
%   You may include duplicate labels in LABELS in order to merge multiple
%   values in A into a single level in B.
%
%   Examples:
%      quality1 = ordinal([1 2 3; 3 2 1; 2 1 3],{'low' 'medium' 'high'})
%      quality2 = ordinal([1 2 3; 3 2 1; 2 1 3],{'high' 'medium' 'low'},[3 2 1])
%      size = ordinal(rand(5,2),{'small' 'medium' 'large'},[],[0 1/3 2/3 1])
%
%   See also ORDINAL, NOMINAL, HISTC.

            if nargin > 0
                a = varargin{1};
                if isa(a,'ordinal')
                    if nargin > 2
                        levels = varargin{3};
                        if ~isempty(levels) && isa(levels,'ordinal')
                            if ~isequal(a.labels,levels.labels)
                                error('stats:ordinal:ordinal:LevelsMismatch', ...
                                    'LEVELS must have the same set of ordinal levels as input A.');
                            end
                        end
                    end
                end
            end
            b = b@categorical(varargin{:});
        end % ordinal constructor
    end

    methods(Static = true)
        function a = empty(varargin)
            if nargin == 0
                codes = [];
            else
                codes = zeros(varargin{:});
                if ~isempty(codes)
                        error('stats:ordinal:empty:EmptyMustBeZero', ...
                              'At least one dimension must be zero.');
                end
            end
            a = ordinal(codes);
        end
    end
end

% The following function is required by the compiler because the inferior
% class depends on it.
%#function handle_graphicsrc
