function y = getcolumn(x,n,expr,varargin)
%GETCOLUMN Get a column of data
%   Y = GETCOLUMN(X,N) returns column N of X.

%   Y = GETCOLUMN(X,N,'expression') returns an expression that
%   evaluates to column N of X. If X is a variable in the base
%   workspace then GETCOLUMN returns 'X(:,N)' and otherwise it returns
%   'getcolumn(X,N)'. If N is a vector then it returns a cell array of 
%   strings vectorized over N.

%   Y = GETCOLUMN(X,N,'expression',ws) where ws is either 'base' or
%   'caller' is the same as Y = GETCOLUMN(X,N,'expression') except that
%   expression evaluation is performed in the specified workspace.

%   Copyright 1984-2008 The MathWorks, Inc.

error(nargchk(2,4,nargin,'struct'));
if nargin == 2
    y = x(:,n);
else
    % Remove spaces from front and back
    x = strtrim(x);

    % The default braces are parentheses
    exprLeft = '(';
    exprRight = ')';
    
    % The default output expression is getcolumn(x,n)
    exprBefore = ['getcolumn' exprLeft x ','];
    exprCol = n;

    % Parse x in reverse for a word followed by optional fields followed by
    % optional arguments enclosed by () or {}.
    fliplrx = fliplr(x);
    [start,stop,token] = regexp(fliplrx,'^(\).*?\(|\}.*?\{)?(.*[\.\(\{])?(\w*)$');
    if ~isempty(token)

        % Record the endpoints of the subexpressions
        endHead = length(x) + 1 - token{1}(3,1);
        endField = length(x) + 1 - token{1}(2,1);
        
        % Record the subexpressions
        exprHead = x(1:endHead);
        exprField = x(endHead+1:endField);
        exprTail = x(endField+1:end);

        % Remove spaces from front and back
        exprHead = strtrim(exprHead);
        exprField = strtrim(exprField);
        exprTail = strtrim(exprTail);
        
        % Check whether exprHead exists in the base workspace.
        try
            if nargin==3 
                exprHeadVarExists = evalin('base',['exist(''' exprHead ''',''var'')']);
            else
                exprHeadVarExists = evalin(varargin{1},['exist(''' exprHead ''',''var'')']);
            end
        catch %#ok<CTCH>
            exprHeadVarExists = 0;
        end
        if (exprHeadVarExists == 1)
            if isempty(exprTail) || isequal(exprTail,'()')
                exprBefore = [exprHead exprField '(:,'];
            elseif ~isequal(exprTail,'{}')
                
                % exprTail is a non-empty string enclosed by () or {}
                % Extract the string and continue.
                exprArgs = exprTail(2:end-1);

                % Remove spaces from front and back
                exprArgs = strtrim(exprArgs);

                % Parse exprArgs into 3 subexpressions that represent
                % arg1, arg2, and subsequent varargs.  arg2 and subsequent
                % varargs, if non-empty, begin with a comma.
                [start,stop,token] = regexp(exprArgs,'^(.*?)(\,.*?)?(\,.*)?$');
                if ~isempty(token)

                    % Record the endpoints of the subexpressions
                    endArg1 = token{1}(1,2);
                    endArg2 = token{1}(2,2);

                    % Record the subexpressions
                    exprArg1 = exprArgs(1:endArg1);
                    exprArg2 = exprArgs(endArg1+1:endArg2);
                    exprArgVar = exprArgs(endArg2+1:end);

                    % Remove spaces from front and back
                    exprArg1 = strtrim(exprArg1);
                    exprArg2 = strtrim(exprArg2);
                    exprArgVar = strtrim(exprArgVar);

                    % Check arguments and eval the second (column) argument.
                    % Otherwise, revert to the default getcolumn(x,n)
                    if ~isempty(exprArg1) && length(exprArg2) > 1 && ...
                            isempty(exprArgVar)
                        try
                            isEvalOK = true;
                            evalArg2 = eval(exprArg2(2:end));
                            exprCol = evalArg2(n);
                        catch %#ok<CTCH>
                            isEvalOK = false;
                            exprCol = n;
                        end
                        if isEvalOK
                            % Check whether exprTail is enclosed by () or {}.
                            if isequal(exprTail(1),'{')
                                exprLeft = '{';
                                exprRight = '}';
                            end
                            exprBefore = [exprHead exprField exprLeft exprArg1 ','];
                        end
                    end
                end
            end
        end
    end
    if length(n) == 1
        y = [exprBefore num2str(exprCol) exprRight];
    else
        y = cell(1,length(n));
        for k=1:length(n)
            y{k} = [exprBefore num2str(exprCol(k)) exprRight];
        end
    end
end
