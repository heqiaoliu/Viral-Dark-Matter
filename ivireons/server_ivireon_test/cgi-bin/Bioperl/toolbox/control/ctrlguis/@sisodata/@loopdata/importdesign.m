function importdesign(this,Design)
% Applies configuration settings

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 16:59:00 $

% Applies new configuration
this.setconfig(Design)    % triggers config. rendering

% Import data
this.importdata(Design)

% Update list of available loop views
% RE: will trigger Viewer update if set of loop models changes
this.LoopView = Design.getLoopView;

% Set nominal value
this.Plant.setNominalModelIndex(Design.NominalModelIndex);


% Notify external clients of configuration change
% RE: 1) Must be done after data import so that all names are uptodate
%        (this event is responsible for updating system names on system 
%        view and editors)
%     2) This event must be issued prior to LoopDataChanged to update
%        editor dependency list and hide irrelevant editors
this.send('ConfigChanged')  

% Notify peers of data change
this.dataevent('all')
