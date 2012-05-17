function enable(this)
%ENABLE   Enable this object.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:44:16 $

% If the GUI is already rendered, call setupVisual directly.
hGUI = this.Application.getGUI;
if isRendered(hGUI)
    setup(this, hGUI.hVisParent);
    
    % If we are already rendered and we have a current active datasource,
    % that datasource may already have data for us.  Make sure that we 
    % update the visual with that data
    hSource = this.Application.DataSource;
    if ~isempty(hSource) && ~isDataEmpty(hSource) && ...
            strcmp(hSource.ErrorStatus, 'success')
        update(this);
        postUpdate(this);
    end
else
    % Create a listener to react to the GUI rendering so that we can call
    % setup when the visualization area is rendered.  If we are already
    % rendered, we do not need to create a listener because we call setup
    % directly.  We do not need to support unrendering and rerendering of
    % the application.
    this.RenderedListener = handle.listener(this.Application, ...
        'Rendered', @(hApp, ev) setup(this, hGUI.hVisParent));
end

% [EOF]
