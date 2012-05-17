function [varargout] = subsref(a,s)
%SUBSREF Subscripted reference for a parametric probability distribution.
%   B = SUBSREF(A,S) is called for the syntax A.PROP where A is a
%   parametric probability distribution and PROP is a property name (such
%   as a parameter name).   S is a structure array with the fields:
%       type -- string containing '.' specifying the subscript type.
%       subs -- Cell array or string containing the parameter name.
%
%   B = A.PROP or A.(PROPNAME) returns the value of the specified
%   property for the distribution A.  PROP is a property name literal,
%   or PROPNAME is a character variable containing a property name.
%
%   B = A(I,J) and B = A{I,J} are not allowed.
%
%   See also ProbDist, ProbDistUnivParam.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:28 $

switch s(1).type
case '()'
    error('stats:ProbDistUnivParam:subsref:NotAllowed', ...
              'Parenthesis indexing is not allowed.');

case '{}'
    error('stats:ProbDistUnivParam:subsref:NotAllowed', ...
              'Cell array indexing is not allowed.');
        
case '.'
    % A reference to a property name or parameter name.  Could be any sort
    % of subscript following that.
    pname = s(1).subs;

    if ischar(pname) && size(pname,1) == 1
        i = strmatch(pname,a.ParamNames,'exact');
        if isscalar(i)
            % Parameter name
            b = a.Params(i);
        elseif ~isempty(strmatch(pname,properties(a),'exact'))
            % Other property name
            b = a.(pname);
        elseif ~isempty(strmatch(pname,methods(a),'exact'))
            % Method call via dot subscripting
            if isscalar(s)
                args = {};
            elseif numel(s)>2 || ~isequal(s(2).type,'()')
                error('stats:ProbDistUnivParam:subsref:BadSubscript', ...
                    'Invalid subscripting for ProbDistUnivParam object.');
            else   % numel(s)==2
                args = s(2).subs;
            end
            [varargout{1:nargout}] = feval(s(1).subs,a,args{:});
            return
        else
            error('stats:ProbDistUnivParam:subsref:BadSubscript', ...
                  'Invalid method or property name:  %s.', pname);
        end
    else
        error('stats:ProbDistUnivParam:subsref:IllegalSubscript', ...
              'Property names must be strings.');
    end

    if ~isscalar(s)
        % Handle cascaded subscripting
        [varargout{1:nargout}] = subsref(b,s(2:end));
    else
        % No cascaded subscripting
        varargout{1} = b;
    end
end
