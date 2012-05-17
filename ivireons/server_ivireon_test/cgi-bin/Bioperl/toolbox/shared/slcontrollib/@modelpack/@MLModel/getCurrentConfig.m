function config = getCurrentConfig(this)
% GETCURRENTCONFIG Returns the current configuration set used in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:52:53 $

config = get(this, 'ConfigSet');
