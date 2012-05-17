function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:35 $

if strcmp(Event,'postlim') && strcmp(View.AxesGrid.YNormalization,'on')
    % Draw normalized data once X limits are finalized

    if isequal(Data.Ts,0)
        if ~isempty(Data.Amplitude)
            Xlims = get(ancestor(View.Curves(1),'axes'),'Xlim');
            YData = normalize(Data,Data.Amplitude,Xlims);
            set(double(View.Curves),'XData',Data.Time,'YData',YData)
        else
            set(double(View.Curves),'XData',[],'YData',[])
        end
    else
        switch View.Style
            case 'stairs'
                if ~isempty(Data.Amplitude)
                    Xlims = get(ancestor(View.Curves(1),'axes'),'Xlim');
                    [T,Y] = stairs(Data.Time,Data.Amplitude);
                    Y = normalize(Data,Y,Xlims);
                    set(double(View.Curves),'XData',T,'YData',Y);
                else
                    set(double(View.Curves),'XData',[],'YData',[])
                end
            case 'stem'
                % REVISIT: Not implemented yet
                ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                    'Stem plot is not currently implemented for this view type.')
        end
    end
end
