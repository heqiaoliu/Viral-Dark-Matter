function draw(this, Data,NormalRefresh)
%DRAW  Draws time response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): John Glass, Bora Eryilmaz
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:35 $

% Time:      Ns x 1
% Amplitude: Ns x Ny x Nu

% Input and output sizes
[Ny, Nu] = size(this.Curves);

% Redraw the curves
if strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(this.Curves),'XData',[],'YData',[])
else
    % Map data to curves
    if isequal(Data.Ts,0)
        % Plot data as a line
        for ct = 1:Ny*Nu
            set(double(this.Curves(ct)), 'XData', Data.Time, ...
                'YData', Data.Amplitude(:,ct));
        end
    else
        % Discrete time system use style to determine stem or stair plot
        switch this.Style
            case 'stairs'
                for ct = 1:Ny*Nu
                    [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
                    set(double(this.Curves(ct)), 'XData', T, 'YData', Y);
                end
            case 'stem'
                % REVISIT: Not implemented yet
                ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                    'Stem plot is not currently implemented for this view type.')
        end
    end
end