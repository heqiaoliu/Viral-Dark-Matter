function disp(h)
%DISP Display RegisterLib object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:10 $

fprintf('Object of class %s\n', class(h));
i=0;
iterator.visitImmediateChildren(h,@localDisp);

    function localDisp(h)
        i=i+1;
        fprintf('Child %d\n', i);
        fprintf('-------------------------------------\n');
        disp(h);
    end
end

% [EOF]
