function initialize(this,Model)
% Initializes simulation options from a given model.

%   $Revision: 1.1.6.3 $ $Date: 2004/08/01 00:10:10 $
%   Copyright 1986-2004 The MathWorks, Inc.

hMdl = get_param(Model,'Object');
this.ConvertConfig(hMdl.getActiveConfigSet)

