function moveToFront(hThis)
% Moves a scribe object to the top of the child order.

%   Copyright 2006-2008 The MathWorks, Inc.

hPar = get(hThis,'Parent');
hChil = findall(hPar,'-depth',1);
hChil(hChil == double(hThis)) = [];
% Also make sure the pins follow:
for i = 1:length(hThis.Pin)
    hChil(hChil == double(hThis.Pin(i))) = [];
end
% Combining the lines below seems to generate a SegV...
hObjs = [double(hThis.Pin(:));double(hThis)];
hObjs = [hObjs;hChil(2:end)];
set(hPar,'Children',hObjs);