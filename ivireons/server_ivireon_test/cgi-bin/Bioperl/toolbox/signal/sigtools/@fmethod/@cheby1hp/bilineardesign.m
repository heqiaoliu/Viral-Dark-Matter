function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:52:30 $

% Call the lowpass method
[s,g] = thisbilineardesign(h,has,c);

% Change sign of a1 and b1
s(:,2) = -s(:,2);
s(:,5) = -s(:,5);

% [EOF]
