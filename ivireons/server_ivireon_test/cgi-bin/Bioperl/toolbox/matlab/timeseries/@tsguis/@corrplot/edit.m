function edit(this,h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Initialize prop editor
h.initialize(this);

%% Add panels
h.axespanel(this,'Y');
this.lagpanel(h);