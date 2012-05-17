function olddata = preserialize(this)
%PRESERIALIZE Prepare object for serialization

% Copyright 2003-2004 The MathWorks, Inc.

olddata = get(this,'ButtonDownFcn');
set(this,'ButtonDownFcn','');

% remove data containing function handles that won't load
delete(get(this,'UIContextMenu'));

% store handles in appdata since loading axes subclass doesn't
% restore the titles and labels
setappdata(double(this),'CBTitle',get(this,'Title'));
setappdata(double(this),'CBXLabel',get(this,'XLabel'));
setappdata(double(this),'CBYLabel',get(this,'YLabel'));
