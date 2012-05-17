function setBAWLBits(dlg,val)
% Set Bit Allocation Word Length bits

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:33 $

if nargin<2
    % Get from widget
    str = get(dlg.hBAWLBits,'string');
    val = sscanf(str,'%f');
end
if (val~=fix(val)) || val<2
    % Invalid value; replace old value into edit box
    val = dlg.BAWLBits;
    errordlg(DAStudio.message('FixedPoint:fiEmbedded:WordLengthInvalidValue'),...
            'Word Length','modal');
end
dlg.BAWLBits = val; % record value
str = sprintf('%d',val); % replace string (removes spaces, etc)
set(dlg.hBAWLBits,'string',str);
