function failure = handleEstimDataChangedEvent(this,newData)
% handle the event of estimation data change in the main GUI

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:53:43 $

failure = false;

%messenger = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton
nlarxmodel = this.NlarxPanel.NlarxModel;
%nlhwmodel = this.NlhwPanel.NlhwModel;
[ny,nu] = size(nlarxmodel);

if (~isequal(size(newData,'ny'),ny) || ~isequal(size(newData,'nu'),nu) || ...
        ~isa(newData,'iddata') || ~strcmpi(newData.Domain,'time'))
    % Incompatible data. Close nlgui.
    failure = true;
    return;
elseif (isequal(newData.uname,nlarxmodel.uname) && ...
        isequal(newData.yname,nlarxmodel.yname))
    % no update required
    return;
end

this.NlarxPanel.updateForNewData(newData);
this.NlhwPanel.updateForNewData(newData);

% no need to reset init model combo because we are not checking for I/O
% name matches (strict = false).
