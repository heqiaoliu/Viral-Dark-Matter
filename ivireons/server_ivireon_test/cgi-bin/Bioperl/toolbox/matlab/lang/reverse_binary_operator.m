function g = reverse_binary_operator(f)
    g = @reverse_op;
    function z = reverse_op(x, y)
        z = f(y,x);
    end
end

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision $ $Date: 2007/06/29 14:26:57 $
