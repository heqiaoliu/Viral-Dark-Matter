function adjustview(View,Data,Event,NormalRefresh)
% Adjusts view prior to and after picking the axes limits. 

%  Author(s): P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:30 $
if strcmp(Event,'postlim') && strcmp(View.AxesGrid.YNormalization,'on')
    % Draw normalized data once X limits are finalized
    if isempty(Data.Amplitude)
        set(double(View.Curves),'XData',[],'YData',[])
    else
        Nu = size(Data.Amplitude,2);
        Xlims = get(ancestor(View.Curves(1),'axes'),'Xlim');

        if isequal(Data.Ts,0)
            YData = normalize(Data,Data.Amplitude,Xlims);
        else
            switch View.Style
                case 'stairs'
                    [T,Y] = stairs(Data.Time,Data.Amplitude);
                    YData = normalize(Data,Y,Xlims);
                case 'stem'
                     % REVISIT: Not implemented yet
                     ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                         'Stem plot is not currently implemented for this view type.')
            end
        end
        for ct=1:Nu
            set(double(View.Curves(ct)),'XData',Data.Time,'YData',YData(:,ct))
        end
    end
end
