function logi = isparallelfilterable(this)
%ISPARALLELFILTERABLE   

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:24 $

logi = true;
for n = 1:length(this.Stage),
    logi = logi && isparallelfilterable(this.Stage(n));
end

% [EOF]
