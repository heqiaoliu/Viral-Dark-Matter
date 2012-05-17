function initVectorVisual(this, varargin)
%INITVECTORVISUAL Initialize the vector visual object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:09 $

initVisual(this, varargin{:});

this.DataSourceChangedListener = handle.listener(this.Application, ...
    'DataSourceChanged', @(h, ev) onDataSourceChanged(this));

if ~isempty(this.Application.DataSource)
    onDataSourceChanged(this);
end

% [EOF]
