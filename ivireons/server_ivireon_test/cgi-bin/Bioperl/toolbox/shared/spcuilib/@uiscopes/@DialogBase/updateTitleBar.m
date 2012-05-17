function updateTitleBar(this,eventData,hScope)  %#ok
%UpdateTitleBar Update the titlebar name cache.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/03/09 19:34:52 $

this.TitlePrefix = this.getTitleString;
% Update dialog, if open:
show(this, false); % update-only (suppress dialog creation)

% [EOF]
