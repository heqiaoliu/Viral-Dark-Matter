function this = idguievent(eventSrc, propertyName)
% DATAEVENT  Subclass of EVENTDATA to handle data change events in Ident
% GUI or Optim info events sent by minimizers.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:50:42 $

% Create class instance
if isa(eventSrc, 'nlutilspack.messenger')
  this = nlutilspack.idguievent(eventSrc, 'identguichange');
elseif isa(eventSrc, 'nlutilspack.optimmessenger')
    this = nlutilspack.idguievent(eventSrc, 'optiminfo');
else
  ctrlMsgUtils.error('Ident:idguis:idguievent1')
end

% Assign data
this.propertyName = propertyName;
%this.oldValue     = oldValue;
%this.newValue     = newValue;
