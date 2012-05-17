function disconnectData(this)
%disconnectData Closes just the data stream,
% leaving buttons/widgets as-is.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/06/13 15:28:54 $

% Pass message to data source
disconnectData(this.DataHandler);
this.Application.screenMsg('');
this.Application.screenMsg(false);

% [EOF]
