function str = reg2Str(R)
% obtain string expression for an array of regressors R

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:31 $

str = cell(length(R),1);
for k = 1:length(R)
    thisstr = R(k).Display;
    if isempty(thisstr)
        thisstr = func2str(R(k).Function);
    end
    str{k} = thisstr;
end
