function super_syncGUIvals(h,arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       h - handle to this object   
%       arrayh - array of handles to frames

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:12:04 $

error(nargchk(2,2,nargin,'struct'));

% Call the base method
base_syncGUIvals(h,arrayh);

% Get handle to frame
hf = find(arrayh,'Tag','siggui.filterorder');

% Store specs in object
set(h,'order',evaluatevars(get(hf,'order')));

