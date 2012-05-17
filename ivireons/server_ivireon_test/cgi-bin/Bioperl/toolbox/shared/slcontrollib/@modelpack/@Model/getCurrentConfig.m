function config = getCurrentConfig(this)
% GETCURRENTCONFIG Returns the current configuration set used in the model.
%
% config = this.getCurrentConfig
%
% CONFIG is a configuration set object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:38:04 $

config = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
