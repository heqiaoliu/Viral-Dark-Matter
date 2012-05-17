function draw(this, Data,NormalRefresh)
%DRAW  Draws time response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:36 $

%  Time:      Ns x 1
%	Amplitude: Ns x 1

% Redraw the curves
if isempty(Data.Time) || strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(this.Curves,'XData',[],'YData',[])
else
    % Map data to curves
    if isequal(Data.Ts,0)
        % Continuous case
        set(double(this.Curves), 'XData', Data.Time,'YData', Data.Amplitude);
    else
        % Discrete Case
        switch this.Style
            case 'stairs'
                [T,Y] = stairs(Data.Time,Data.Amplitude);
                set(double(this.Curves), 'XData', T, 'YData', Y);
            case 'stem'
                % REVISIT: Not implemented yet
                ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                    'Stem plot is not currently implemented for this view type.')
        end
    end
end

for ct = 1:numel(this.Curves)
    hasbehavior(this.Curves(ct),'legend',false);
end