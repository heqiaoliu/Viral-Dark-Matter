function config = getCurrentConfig(this)
% GETCURRENTCONFIG Returns the current configuration set used in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:38:56 $

% Get configuration set.
model  = get_param( this.Name, 'Object' );
config = model.getActiveConfigSet;
