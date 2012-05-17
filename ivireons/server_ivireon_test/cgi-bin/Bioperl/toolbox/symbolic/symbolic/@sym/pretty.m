function pretty(X)
%PRETTY Pretty print a symbolic expression.
%   PRETTY(S) prints the symbolic expression S in a format that 
%   resembles type-set mathematics.
%
%   See also SYM/SUBEXPR, SYM/LATEX, SYM/CCODE.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
if isa(X.s,'maplesym')
    pretty(X.s);
else
    mupadmex('on',7); % enable pretty-printing 
    cw = get(0,'CommandWindowSize');
    width = max(cw(1),40);
    if isscalar(X)
        mupadmex('symobj::pretty',X.s,int2str(width));
    else
        for k=1:7
            res = evalc('mupadmex(''symobj::pretty'',X.s,int2str(width));');
            first = find(res==char(10),1)+1;
            if ~strncmp(res(first:end),'array(',6) &&  ...
                    ~strncmp(res(first:end),'  array(',8)
                break;
            end
            width = 2*width;
        end
        fprintf(1,'%s',res);
    end
    mupadmex('off',7); % disable pretty-printing
end
