function addRecentSource(this)
%ADDRECENTSOURCE Add current source to the "recent sources" list.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/14 04:07:45 $

hApp = get(this, 'Application');

if isSerializable(hApp.DataSource)
    % Retain source in recent sources list
    
    % Name to display/compare in menu list:
    %  Could prefix using type (workspace, file, simulink, etc)
    %    -> this.DataSource.dataSource.type;
    itemName = hApp.DataSource.Name;
    
    % command-line args to reinstantiate connection
    itemData = hApp.source;

    % Store serialization
    this.RecentSources.setMostRecent( {itemName, itemData} );
end

% [EOF]
