function y = eml_li_find(x)
% Embedded MATLAB Library Function.
% Used internally to implement logical indexing.
% Copyright 2009 The MathWorks, Inc.
%#eml
    eml_prefer_const(x);
    n = cast(numel(x), eml_index_class);
    if eml_is_const(x)
        k = eml_const(compute_nones(x, n));
    else 
        k = compute_nones(x, n);
    end

    assert(k <= n); % Helps range analysis figure out the size of y.
    if eml_is_const(size(x,1)) && size(x,1) == 1 && ndims(x) == 2
        % x is a row vector, output is a row vector.
        y = eml.nullcopy(zeros(1, k, eml_index_class));
    else 
        % x is something else, output is a column vector.
        y = eml.nullcopy(zeros(k, 1, eml_index_class));
    end;
    if eml_is_const(k) && (k == 0)
        return;
    end
    j = cast(1, eml_index_class);
    for i = 1:n
        if x(i) 
            y(j) = i;
            j = eml_index_plus(j, 1);
        end;
    end;
end

function k = compute_nones(x, n)
    eml_prefer_const(x);
    eml_prefer_const(n);
    k = cast(0, eml_index_class);

    for i = 1:n
        if x(i) 
            k = eml_index_plus(k, 1);
        end;
    end;
end