function [varargout] = subsref(a,s)
%SUBSREF Subscripted reference for a categorical array.
%     B = SUBSREF(A,S) is called for the syntax A(I).  S is a structure array
%     with the fields:
%         type -- string containing '()' specifying the subscript type.
%                 Only parenthesis subscripting is allowed.
%         subs -- Cell array or string containing the actual subscripts.
%
%   See also CATEGORICAL, CATEGORICAL/SUBSASGN.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:26 $

switch s(1).type
case '()'
    % Make sure nothing follows the () subscript
    if ~isscalar(s)
        error('stats:categorical:subsasgn:InvalidSubscripting', ...
              '()-indexing must appear last in an index expression.');
    end
    b = a;
    b.codes = a.codes(s.subs{:});
    varargout{1} = b;
case '{}'
    error('stats:categorical:subsref:CellReferenceNotAllowed', ...
          'Cell contents reference from a non-cell array object.')
case '.'
    error('stats:categorical:subsref:FieldReferenceNotAllowed', ...
          'Attempt to reference field of non-structure array.')
end
