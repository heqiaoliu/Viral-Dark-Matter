function hDataHandler = getDataHandler(this, hVisual)
%GETDATAHANDLER Get the dataHandler.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/27 19:54:31 $

if nargin < 2
    hDataHandler = this.DataHandler;
    return;
end

DataHandler = this.getDataHandlerClass(hVisual);

% If we are switching datahandler classes, and we do not have a ScopeCLI,
% make a new one.  If we are using the same datahandler class pass nothing,
% this will cause the WorkspaceExpression to be used.
if ~isempty(this.DataHandler) && ~isa(this.DataHandler, DataHandler) && isempty(this.ScopeCLI)
    this.ScopeCLI = uiscopes.ScopeCLI({this.DataHandler.UserData}, {this.Name});
    this.ScopeCLI.parseCmdLineArgs;
end

% create an instance of data handler
if ~isempty(DataHandler)
    hDataHandler = feval(DataHandler, this, this.ScopeCLI);
else
    hDataHandler = [];
end

% [EOF]
