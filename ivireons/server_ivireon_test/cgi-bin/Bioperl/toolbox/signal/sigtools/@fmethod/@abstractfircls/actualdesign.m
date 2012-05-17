function varargout = actualdesign(this, hspecs)
%ACTUALDESIGN   Perform the actual design.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:17 $

args = designargs(this, hspecs);

varargout{1:nargout} = {fircls(args{:})};
% [EOF]
