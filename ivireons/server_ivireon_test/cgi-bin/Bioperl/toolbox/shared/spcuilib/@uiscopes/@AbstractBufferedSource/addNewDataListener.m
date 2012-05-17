function l = addNewDataListener(this, callbackFunction)
%ADDNEWDATALISTENER Add a listener to the 'NewData' event.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:33 $

l = handle.listener(this, 'NewData', @(h,ev) callbackFunction(this));
%lclCallback(this, callbackFunction));

% -------------------------------------------------------------------------
% function lclCallback(this, callbackFunction

% [EOF]
