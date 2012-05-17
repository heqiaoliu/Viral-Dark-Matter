function hExtInst = getExtInst(this, varargin)
%GETEXTINST Get the extInst.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:09:42 $

hExtInst = getExtension(this.ExtDriver, varargin{:});

% [EOF]
