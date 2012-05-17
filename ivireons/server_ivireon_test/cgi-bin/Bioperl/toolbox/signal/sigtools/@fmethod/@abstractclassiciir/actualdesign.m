function coeffs = actualdesign(this,hs)
%ACTUALDESIGN   Design the filter and return the coefficients.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:00:36 $

% Compute analog filter specs object
has = analogspecs(this,hs);

% Compute 'c' parameter 
c = cparam(hs);

% Design digital filter from analog response object using bilinear
% transformation
[s,g] = bilineardesign(this,has,c);

coeffs = {s,g};

% [EOF]
