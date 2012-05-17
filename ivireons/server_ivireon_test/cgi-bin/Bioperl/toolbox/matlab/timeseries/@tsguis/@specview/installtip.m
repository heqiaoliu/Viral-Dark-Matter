function installtip(this,gobjects,tipfcn,info)
%INSTALLTIP  Installs line tip on specified G-objects.

%   Author(s):  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:00:42 $

%% Overloaded to use the timeseries line select switchyard

if isempty(tipfcn)
    for ct = 1:length(gobjects)
        hb = hggetbehavior(gobjects(ct),'DataCursor');
        set(hb,'UpdateFcn',[]);
        %% Create a new datatip on a click
        set(hb,'CreateNewDatatip',true);
    end
else
    for ct = 1:length(gobjects)
        hb = hggetbehavior(gobjects(ct),'DataCursor');
        set(hb,'UpdateFcn',{tipfcn info});
        %% Create a new datatip on a click
        set(hb,'CreateNewDatatip',true);
        % Activate mode when user clicks on response line
        set(gobjects(ct),'ButtonDownFcn',{@tsLineButtonDown info.Carrier.Parent});
    end
end


