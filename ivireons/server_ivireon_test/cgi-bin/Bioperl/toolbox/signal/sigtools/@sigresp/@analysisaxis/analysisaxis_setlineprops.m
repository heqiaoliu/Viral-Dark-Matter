function analysisaxis_setlineprops(this)
%ANALYSISAXIS_SETLINEPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:35:45 $

hl = getline(this);

set(hl, ...
    'ButtonDownFcn', @setdatamarkers, ...
    'Visible', this.Visible, ...
    'Tag', getlinetag(this));

% Suppress Data Brushing g418177
for indx = 1:length(hl)
    set(hggetbehavior(hl(indx), 'Brush'), 'Enable', false);
end

% [EOF]
