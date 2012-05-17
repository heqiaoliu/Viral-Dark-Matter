function r = realmin(cls)
%Embedded MATLAB Library function.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if nargin == 1
    if eml_ambiguous_types && ~ischar(cls)
        % There is another realmin in lib/fixedpoint/@embedded/@fi, and 
        % that one accepts non-character inputs as well. During size
        % propagation, this function can accidentally called instead,
        % so bail out gracefully.
        r = eml_not_const(0);
        return;
    end

    eml_assert(ischar(cls), 'Input must be a string class name.');
    if strcmp(cls,'single')
        r = eml_const(single(2^-126));
        return
    end
    eml_assert(strcmp(cls,'double'), ...
        'Input must be ''single'' or ''double''.');
end
r = eml_const(2^-1022);