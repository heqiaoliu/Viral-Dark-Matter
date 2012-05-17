function updateNotifications(this,Views)
%updateNotifications  updates the notifications for he SISO Tool LTI
%Viewer.

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/05/23 07:53:30 $

if nargin == 1
    Views = this.Views;
end

Views = Views(ishandle(Views));

Plant = this.Parent.Loopdata.P.getP;
hasDelay = false;
hasFRD = false;
if isa(Plant,'ltipack.frddata')
    hasFRD = true;
elseif hasdelay(Plant)
    hasDelay = true;
end

for ct = 1:length(Views)
    if strcmpi(Views(ct).Visible,'on')
        if isa(Views(ct),'resppack.timeplot')
            if hasFRD
                Views(ct).AxesGrid.showMessagePane(true,localTimePlotFRDMessage(this))
            else
                Views(ct).AxesGrid.showMessagePane(false);
            end
        elseif  isa(Views(ct),'resppack.mpzplot')
            if hasFRD
                Views(ct).AxesGrid.showMessagePane(true,localPZPlotFRDMessage(this))
            elseif hasDelay && isequal(Plant.Ts,0)
                Views(ct).AxesGrid.showMessagePane(true,localPZPlotTimeDelayMessage(this))
            else
                Views(ct).AxesGrid.showMessagePane(false);
            end
        end
    end
end
end



function MessageTextPane = localTimePlotFRDMessage(this)

Msg = ctrlMsgUtils.message('Control:compDesignTask:strNotificationTimePlotFRD');
MessageTextPane = ctrluis.PopupPanel.createMessageTextPane(Msg,get(0,'DefaultTextFontName'),11);

end

function MessageTextPane = localPZPlotFRDMessage(this)

Msg = ctrlMsgUtils.message('Control:compDesignTask:strNotificationPoleZeroFRD');
MessageTextPane = ctrluis.PopupPanel.createMessageTextPane(Msg,get(0,'DefaultTextFontName'),11);

end

function MessageTextPane = localPZPlotTimeDelayMessage(this)

Msg = ctrlMsgUtils.message('Control:compDesignTask:strNotificationPoleZeroTimeDelay');
MessageTextPane = ctrluis.PopupPanel.createMessageTextPane(Msg,get(0,'DefaultTextFontName'),11);
h = handle(MessageTextPane, 'callbackproperties');
h.HyperlinkUpdateCallback = {@localPrefCallback, this};

end



function localPrefCallback(es,ed,this) %#ok<INUSL>

if strcmp(ed.getEventType.toString, 'ACTIVATED')
    % Determine Hyperlink Description
    Description = char(ed.getDescription);
    switch Description
        case 'Pref'
            % Open Preference Editor to the Options tab.
            this.Parent.Preference.edit;
            this.Parent.Preference.selecttab('TimeDelays');
    end
end
end