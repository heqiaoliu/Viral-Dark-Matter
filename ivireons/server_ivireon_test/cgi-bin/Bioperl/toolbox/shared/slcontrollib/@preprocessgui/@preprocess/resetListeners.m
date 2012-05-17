function resetListeners(this)
%ADDLISTENERS  Adds new listeners to listener set.
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:08 $

if ~isempty(this.Listeners)
    delete(this.Listeners);
    this.Listeners = [];
end
