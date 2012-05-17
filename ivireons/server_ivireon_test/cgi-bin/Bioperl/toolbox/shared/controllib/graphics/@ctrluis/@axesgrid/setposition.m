function setposition(this,varargin)
%SETPOSITION   Sets axes group position.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:07 $

% Grid position: delegate to @plotarray object
% Scaled Resize (for printing)

% Only adjust label positions during print resize
if strcmp(this.PrintLayoutManager,'off')
    this.Axes.setposition(this.Position);
    % Background axes
    set(this.BackgroundAxes,'Position',this.Position)
    % Adjust label position
end
labelpos(this);
messagepanepos(this)