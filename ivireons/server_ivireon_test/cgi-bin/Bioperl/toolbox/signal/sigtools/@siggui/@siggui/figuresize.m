function size = figuresize(hBase, units)
%FIGURESIZE Return the figure size.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2009/01/05 18:01:05 $ 

error(nargchk(1,2,nargin,'struct'));

if nargin == 1, units = 'pixels'; end

hFig = get(hBase, 'FigureHandle');

if ~ishghandle(hFig),
    error(generatemsgid('InvalidParam'),'Object does not contain a valid figure handle.');
end

origUnits = get(hFig,'Units');
set(hFig,'Units',units);
pos = get(hFig,'Position');
set(hFig,'Units',origUnits);

size = pos(3:4);

% [EOF]
