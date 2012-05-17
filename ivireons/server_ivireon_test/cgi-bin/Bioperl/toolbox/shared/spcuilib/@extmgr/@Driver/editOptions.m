function editOptions(this, varargin)
%EDITOPTIONS Edit the options.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/29 16:08:09 $

hd = editConfigSet(this, false);

hd.options(varargin{:});

% [EOF]
