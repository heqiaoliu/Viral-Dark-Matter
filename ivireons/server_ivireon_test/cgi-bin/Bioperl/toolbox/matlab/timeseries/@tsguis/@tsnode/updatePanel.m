function updatePanel(this,varargin)
%% tsnode panel update

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2005/06/27 23:03:34 $

%% Send a timeserieschange event 
% Potential listeners are views only.
% note: the pedigree up the tree shall be updated explicitly using the
% updatePanel method. It does not listen to this event.
if isempty(this.getRoot)
    %protection against a node bein deleted (disconnected)
    return
end
this.getRoot.send('timeserieschange');

%explicitly update the immediate parent node
this.up.updatePanel(varargin{:});

