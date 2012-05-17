function draw(this, Data,NormalRefresh)
% Draws input data.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:31 $

%  Time:      Ns x 1
%	Amplitude: Ns x Nu 

% Redraw the curves
if isempty(Data.Time) || strcmp(this.AxesGrid.YNormalization,'on')
    % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
    set(this.Curves,'XData',[],'YData',[])
else
    % Map data to curves
    Nu = size(Data.Amplitude,2);
    if isequal(Data.Ts,0)
        for ct=1:Nu
            set(double(this.Curves(ct)), 'XData', Data.Time,'YData', Data.Amplitude(:,ct));
            hasbehavior(this.Curves(ct),'legend',false);
        end
    else
        switch this.Style
            case 'stairs'
                for ct=1:Nu
                    [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
                    set(double(this.Curves(ct)), 'XData', T, 'YData', Y);
                    hasbehavior(this.Curves(ct),'legend',false);
                end
            case 'stem'
                % REVISIT: Not implemented yet
                ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                    'Stem plot is not currently implemented for this view type.')
        end
    end
end
