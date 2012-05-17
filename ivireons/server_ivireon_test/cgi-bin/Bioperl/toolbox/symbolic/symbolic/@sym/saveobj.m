function y = saveobj(x)
%SAVEOBJ    Save symbolic object
%   Y = SAVEOBJ(X) converts symbolic object X into a form that can be
%   saved to disk safely.
    
%   Copyright 2008-2010 The MathWorks, Inc.
    
    if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
    y = sym(x);
    % SpecialCase: catch special identifiers like D and O by directly
    % calling MuPAD instead of using sym/char.
    M = mupadmex('symobj::char', x.s, 0);
    if strncmp(M,'"',1)
       M = M(2:end-1);  % remove quotes
    end
    y.s = M;
