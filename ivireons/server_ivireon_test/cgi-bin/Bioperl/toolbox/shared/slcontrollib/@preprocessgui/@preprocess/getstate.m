function [names,position] = getstate(h)
%GETDATA  Adds new listeners to listener set.
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2006/06/20 20:29:02 $

% Return names and current to position to java GUI
names = get(h.Datasets,{'Name'});
position = h.Position;

% If necessary close the existing graphical editor
% if ~isempty(h.Window) && ishandle(h.Window)
%    delete(h.Window);
%    h.Window = [];
% end

% TO DO: Need to reset the UDD object to agree with the 
% empty (reset) state of the java panels