function slsincoslut(subsys, breakPoints, precision)
% 
% This is a private mask helper file for sine and cosine blocks in 
% Simulink table lookup library.
%
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2008/12/01 07:47:33 $

fixPtData = floor(breakPoints*(2^precision));
diff = fixPtData(2:end) - fixPtData(1:end-1);
if all(diff==diff(1))
    searchMethod = 'Evenly spaced points';
else
    searchMethod = 'Binary search';
end
set_param([subsys '/Look-Up Table'], 'IndexSearchMethod', searchMethod);
