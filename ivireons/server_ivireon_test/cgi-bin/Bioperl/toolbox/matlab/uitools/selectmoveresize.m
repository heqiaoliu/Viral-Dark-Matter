%SELECTMOVERESIZE Interactively select, move, resize, or copy objects.
%   SELECTMOVERESIZE as a button down function will handle selecting,
%   moving, resizing, and copying of Axes and Uicontrol graphics objects.
%
%   A = SELECTMOVERESIZE returns a structure array containing the following
%   fields:
%      Type - a string containing the action type, which can be Select,
%      Move, Resize, or Copy.
%      Handles - A list of the selected handles or for a Copy an Nx2 matrix
%      containing the original handles in the first column and the new
%      handles in the second column.
%
%   Example:
%   This sets the button down function of the current axes to SELECTMOVERESIZE:
%       ax = axes;
%       set(ax,'ButtonDownFcn','selectmoveresize');
%
%   See also PAN, ROTATE, ROTATE3D, ZOOM.

%   Copyright 1984-2006 The MathWorks, Inc. $Revision: 1.11.4.5 $  $Date:
%   2005/05/23 01:10:05 $ Built-in function.

