function this = SLConnectMgr
%SLCONNECTMGR Construct a SLCONNECTMGR object

%   Author(s): J. Yu
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:43:22 $

this = slmgr.SLConnectMgr;
this.hSignalSelectMgr = slmgr.SignalSelectMgr;
this.hSignalData = slmgr.SignalData;


% [EOF]
