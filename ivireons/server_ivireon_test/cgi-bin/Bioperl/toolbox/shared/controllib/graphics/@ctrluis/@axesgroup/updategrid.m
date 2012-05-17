function updategrid(this,varargin)
%UPDATEGRID  Redraws custom grid.

%   Author: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:46 $

% RE: Callback for LimitChanged event
if ~isempty(this.GridFcn) && strcmp(this.Grid,'on')
    
    % Clear existing grid
    cleargrid(this)

    % Evaluate GridFcn to redraw custom grid
    GridHandles = feval(this.GridFcn{:});
    this.GridLines = handle(GridHandles(:));
    
end