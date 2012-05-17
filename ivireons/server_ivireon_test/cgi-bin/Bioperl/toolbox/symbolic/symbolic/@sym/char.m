function M = char(A,d)
%CHAR   Convert scalar or array sym to string.
%   CHAR(A) returns a string representation of the symbolic object A
%   in MuPAD syntax.

%   CHAR(A,2) has the form 'matrix([[...],[...]])'.
%   CHAR(A,d) for d >= 3 has the form
%      'array([1..m,1..n,1..p],[(1,1,1)=xxx,...,(m,n,p)=xxx])'
%   CHAR(A) uses d = ndims(A).

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
if isa(A.s,'maplesym')
    M = char(A.s);
    return;
end

% return the value of the reference as a string
if nargin == 2
    if d == 1
        A = privsubsref(A,':');
        M = mupadmex('symobj::char', A.s, 0);
        M = strrep(M,'[[','[');
        M = strrep(M,']]',']');
        M = strrep(M,'], [',',');
    else
        if d == 2
            nd = ndims(A);
            if nd > 2
                warning('symbolic:char:reshapendarray', ...
                    ['Reshaping the %d-dimensional symbolic ', ...
                    'matrix input into a 2-dimensional\nsymbolic matrix ', ...
                    'for use with the matrix([[...],[...]]) form, ', ...
                    'preserving the\nnumber of columns.'], nd);
                A = reshape(A, [], size(A, 2));
            end
        end
        M = mupadmex('symobj::char', A.s, 0);
    end
else
    M = mupadmex('symobj::char', A.s, 0);
end
M = strrep(M,'_Var','');
if strncmp(M,'"',1)
    M = M(2:end-1);  % remove quotes
end
