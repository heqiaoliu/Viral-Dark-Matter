function b = actualdesign(this, hs)
%ACTUALDESIGN   Design a least squares filter.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:01:12 $

args = designargs(this, hs);

b = {firls(args{:})};

% [EOF]
