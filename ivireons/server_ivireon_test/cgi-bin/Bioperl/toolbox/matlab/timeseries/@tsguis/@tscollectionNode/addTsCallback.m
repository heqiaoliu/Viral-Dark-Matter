function addTsCallback(this,ts,Name)
%callback to addts actions from right-click popup menu option on the node
%or the "add members" button from the tscollectionNode panel.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/07/18 18:44:18 $

if nargin<3
    Name = ts.Name;
end

try
    % Record the addts transaction
    T = tsguis.nodetransaction;
    recorder = tsguis.recorder;
    T.ObjectsCell = {ts};
    T.Action = 'added';
    T.ParentNodeHandle = this;

    % Now update the dataobject to add a new member to the
    % collection
    try
        addts(this.Tscollection,ts,ts.name);
    catch me
        if strcmp(me.identifier,'tscollection:addts:badtime')
            errordlg(xlate('The time vector of the time series you are adding must match the tscollection time vector.'),...
                'modal')
        end
        return
    end

    % Record the transaction
    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Add new time series member to tscollection'));
        T.addbuffer([this.Tscollection.Name, ' = addts( ',this.Tscollection.Name,', ',Name,', ''',ts.Name,''');'],this.Tscollection);
    end

    % Store transaction
    T.commit;
    recorder.pushundo(T);

catch me
    errordlg({xlate('Failed to add new time series member to the collection. The error was:'),me.message},...
        'Time Series Tools','modal')
end