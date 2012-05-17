function disp(hObj)
%DISP Display the siggui object.

% Copyright 1988-2003 The MathWorks, Inc.

if length(hObj) > 1,
    for indx = 1:length(hObj),
        disp(class(hObj(indx)));
    end
    fprintf(1, '\n');
else
    disp(get(hObj))
end
