function [varargout] = subsref(obj,s)
%SUBSREF Subscripted reference for a NaiveBayes object.
%   B = SUBSREF(OBJ,S) is called for the syntax OBJ(S) when OBJ is a
%   NaiveBayes object. S is a structure array with the fields:
%       type -- string containing '()', '{}', or '.' specifying the
%               subscript type.
%       subs -- Cell array or string containing the actual subscripts.
%
%   See also NAIVEBAYES.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:55 $

switch s(1).type
    case '()'
        error('stats:NaiveBayes:subsref:ArraySubscript', ...
            'The %s class does not support () indexing.', class(obj));
        
    case '.'
        methodsProp=[methods(obj);properties(obj)];
        if ~any(strcmp(s(1).subs, methodsProp))
            error('stats:NaiveBayes:subsref:AccessPrivate', ...
                'No appropriate method or public field %s for class %s.',s(1).subs, class(obj));
        elseif   strcmp(s(1).subs,'fit')
            error('stats:NaiveBayes:subsref:InstCallStatic', ...
                'Static method ''%s'' must be called by using the class name ''%s''. ',s(1).subs,class(obj));
        end
        if isequal(s(1).subs,'display') %% nargout==0
            display(obj,inputname(1));
        else
            [varargout{1:nargout}] = builtin('subsref',obj,s);
        end
    otherwise
        [varargout{1:nargout}] = builtin('subsref',obj,s);
end
