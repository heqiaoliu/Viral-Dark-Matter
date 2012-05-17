function draw(this, Data,NormalRefresh)
%DRAW  Draws time response curves for @SineView.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): Erman Korkut 17-Mar-2009
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:04 $

% Time:      Ns x 1
% Amplitude: Ns x 1

% Input and output sizes
[Ny, Nu] = size(this.Curves);

% Redraw the curves
if strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(this.Curves),'XData',[],'YData',[])
else
    for ct = 1:Ny*Nu
        [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
        set(double(this.Curves(ct)), 'XData', T, 'YData', Y);
        % Set the steady state curve
        [TSS,YSS] = stairs(Data.Time(this.SSIndex:end),Data.Amplitude(this.SSIndex:end,ct));
        set(double(this.SSCurves(ct)), 'XData', TSS, 'YData', YSS);        
    end
end