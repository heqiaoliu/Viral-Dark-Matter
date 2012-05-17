function unrender(varargin)
%UNRENDER Unrender graphical rendering of item.
%
%  This does not destroy the uiitem object;
%  it only removes the underlying graphical rendering.
%  The object may be re-rendered at a later time.
%
%  Sends ChildUnrenderedEvent if the child was unrendered,
%  unless optional flag passed in as FALSE.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:20 $

unrender_widget(varargin{:});

% [EOF]
