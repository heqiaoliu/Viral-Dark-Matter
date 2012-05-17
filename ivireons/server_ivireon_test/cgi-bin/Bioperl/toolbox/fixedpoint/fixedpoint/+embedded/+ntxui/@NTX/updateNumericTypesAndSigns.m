function updateNumericTypesAndSigns(ntx,allowReset)
% Update numerictype dialog
%   update only if dialog panel is visible
%   update "numerictype()" only if DTX on
%   warning: icon, tooltip
%
% Update histogram title
%   update only if histogram visible
%   "numerictype()" if DTX, otherwise do same as Signed text
%
% Update Signed text
%   update only if histogram visible
%   Signed/Unsigned text
%   warning: icon, tooltip
%
% Update OptionSigned dialog controls
%   warning: change background color

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:53 $

if nargin<2
    allowReset = true;
end

s = getNumericTypeStrs(ntx);

% Check if numerictype changed
ht = ntx.htTitle;
dp = ntx.dp;
changed = ~strcmpi(get(ht,'string'),s.typeStr);
if changed
    if allowReset
        datatypeChanged(ntx);
    end
    
    % xxx Update all dialogs registered to DialogPanel
    %updateDialogContent(dp);
    
    % Update only specific dialogs
    update(ntx.hResultingTypeDialog);

    % Update histogram title
    str = s.typeStr;
    tip = s.typeTip;
    set(ht,'string',str,'tooltip',tip);
end

% After setting title string, update the "title" position.
% This requires text extent, hence the need to set string first.
ext = get(ht,'extent');
pos_ax = get(ntx.hHistAxis,'pos'); % pixels
pos(1) = pos_ax(1)+pos_ax(3)-ext(3)-10;
pos(2) = pos_ax(2)+pos_ax(4)+4;
pos(3:4) = ext(3:4);
set(ht,'pos',pos);

% Update Signed text on histogram title line
%   update only if histogram visible
%   Signed/Unsigned text
%   warning: icon, tooltip
if s.isWarn
    icon = ntx.WarnIcon;
    tip = s.warnTip;
else
    icon = ntx.BlankIcon;
    tip = '';
end
set(ntx.htSigned, ...
    'string',s.signedStr, ...
    'tooltip',tip, ...
    'cdata',icon);

% OptionSigned dialog controls
%   warning: change background color
%   The po-up control does not render the color on MAC OSX. Use black text
%   instead.
if s.isWarn && ~ismac
    % Show overflow color as uicontrol background
    lightenUp = [0 .1 .1];
    clrp = ntx.ColorOverflowBar+lightenUp; % prompt
    clrw = clrp; % widget
    clrf = 'w';  % white text
else
    % xxx should be dp.hDialogPanel
    clrp = get(dp.hFigPanel,'backgr'); % prompt
    clrw = 'w'; % widget
    clrf = 'k'; % black text
end

setSignedPromptColor(ntx.hBitAllocationDialog,clrp,clrw,clrf);
