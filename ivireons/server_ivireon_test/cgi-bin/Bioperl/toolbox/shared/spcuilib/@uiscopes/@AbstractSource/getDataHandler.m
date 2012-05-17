function hDataHandler = getDataHandler(this, hVisual)
%GETDATAHANDLER Get the dataHandler.
%   OUT = GETDATAHANDLER(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/18 02:14:42 $

if nargin < 2
    hDataHandler = this.DataHandler;
    return;
end

DataHandler = this.getDataHandlerClass(hVisual);

% if ~isempty(this.DataHandler)
%     % delete the existing object then create new one
%     clear this.DataHandler;
%     this.DataHandler = []; 
% end

% create an instance of data handler
if ~isempty(DataHandler)
    hDataHandler = feval(DataHandler, this, this.ScopeCLI);
else
    hDataHandler = [];
end

% [EOF]
