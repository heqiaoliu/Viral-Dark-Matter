function position = getpixelposition(h,recursive)
% GETPIXELPOSITION Get the position of an HG object in pixel units.
%   GETPIXELPOSITION(HANDLE) gets the position of the object specified by
%   HANDLE in pixel units.
%
%   GETPIXELPOSITION(HANDLE, RECURSIVE) gets the position as above. If
%   RECURSIVE is true, the returned position is relative to the parent
%   figure of HANDLE.
%
%   POSITION = GETPIXELPOSITION(...) returns the pixel position in POSITION.
%
%   Example:
%       f = figure;
%       p = uipanel('Position', [.2 .2 .6 .6]);
%       h1 = uicontrol(p, 'Units', 'normalized', 'Position', [.1 .1 .5 .2]);
%       % Get pixel position w.r.t the parent uipanel
%       pos1 = getpixelposition(h1)
%       % Get pixel position w.r.t the parent figure using the recursive flag
%       pos2 = getpixelposition(h1, true)
%
%   See also SETPIXELPOSITION, UICONTROL, UIPANEL

% Copyright 1984-2006 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/08/01 12:23:31 $
  
% Verify that getpixelposition is given between 1 and 2 arguments
error(nargchk(1, 2, nargin, 'struct')) 

% Verify that "h" is a handle
if ~ishghandle(h)
    error('MATLAB:getpixelposition:InvalidHandle', 'Input argument "h" must be a HANDLE')
end

if nargin < 2
  recursive = false;
end

parent = get(h,'Parent');

% Use hgconvertunits to get the position in pixels (avoids recursion
% due to unit changes trigering resize events which re-call
% getpixelposition)
position = hgconvertunits(ancestor(h,'figure'),get(h,'Position'),get(h,'Units'),...
          'Pixels',parent);      

if recursive && ~ishghandle(h,'figure') && ~ishghandle(parent,'figure')
 parentPos = getpixelposition(parent, recursive); 
 position = position + [parentPos(1) parentPos(2) 0 0];
end
  

