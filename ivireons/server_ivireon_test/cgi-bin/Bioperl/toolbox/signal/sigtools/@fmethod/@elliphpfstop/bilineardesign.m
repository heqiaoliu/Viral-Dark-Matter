function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:55:45 $


% Call lowpass design
[s,g] = mybilineardesign(h,has,c);

% Change required signs
s(:,[2,5]) = -s(:,[2,5]);

% [EOF]
