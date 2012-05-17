function addDataHandler(hRegDb, source, visual, constructor)
%ADDDATAHANDLER Add a data handler for a source/visual link.
%   ADDDATAHANDLER(EXT, SOURCE, VISUAL, CON) Adds a data handler to the
%   RegisterDb object EXT for the SOURCE and VISUAL combination specified
%   by the constructor CON.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/11 16:22:31 $

% Get the application data for the specified source's DataHandlers field.
appData = hRegDb.getAppData('Sources', source, 'DataHandlers');

% Convert the visual name to a valid variable/field name so we can use the
% video name as a field in a structure.
visual = genvarname(visual);

% Add the constructor to the DataHandler list.  This will allow us to have
% multiple DataHandlers for a given source/visual pair.
if isempty(appData) || ~isfield(appData, visual)
    appData.(visual) = {constructor};
else
    appData.(visual){end+1} = constructor;
end

% Save away the DataHandlers application data.
hRegDb.setAppData('Sources', source, 'DataHandlers', appData);

% [EOF]
