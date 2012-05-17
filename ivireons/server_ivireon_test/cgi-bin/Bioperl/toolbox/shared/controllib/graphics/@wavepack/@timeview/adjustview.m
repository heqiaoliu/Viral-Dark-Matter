function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:34 $

if strcmp(Event,'postlim') && strcmp(View.AxesGrid.YNormalization,'on')
    % Draw normalized data once X limits are finalized
    if isequal(Data.Ts,0)
        for ct=1:numel(View.Curves)
            Xlims = get(ancestor(View.Curves(ct),'axes'),'Xlim');
            YData = normalize(Data,Data.Amplitude(:,ct),Xlims,ct);
            if ~isempty(Data.Amplitude)
                set(double(View.Curves(ct)),'XData',Data.Time,'YData',YData)
            else
                set(double(View.Curves(ct)),'XData',[],'YData',[])
            end
        end
    else
        switch View.Style
            case 'stairs'
                for ct=1:numel(View.Curves)
                    Xlims = get(ancestor(View.Curves(ct),'axes'),'Xlim');
                    [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
                    Y = normalize(Data,Y,Xlims,ct);
                    if ~isempty(Data.Amplitude)
                        set(double(View.Curves(ct)),'XData',T,'YData',Y);
                    else
                        set(double(View.Curves(ct)),'XData',[],'YData',[])
                    end
                end
            case 'stem'
                % REVISIT: Not implemented yet
                ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                    'Stem plot is not currently implemented for this view type.')
        end
    end
end

