function checkinwin(fileName, reload)
%CHECKINWIN Checkin dialog.
%   CHECKINWIN(FILENAME, RELOAD) opens the checkin dialog
%   and makes it visible.
%
%   See also CHECKOUTWIN, CHECKIN, and CHECKOUT.
%

% Copyright 1998-2004 The MathWorks, Inc.
% $Revision: 1.5.4.2 $  $Date: 2005/06/21 19:41:40 $

com.mathworks.mlwidgets.mlservices.scc.CheckInDlg(fileName, reload);

