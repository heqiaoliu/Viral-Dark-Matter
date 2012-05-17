function draw(this, Data,NormalRefresh)
%DRAW  Draws time response curves for @SpectrumView.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): Erman Korkut 16-Mar-2009
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:12 $

% Time:      Ns x 1
% Amplitude: Ns x 1

% Input and output sizes
[Ny, Nu] = size(this.Curves);

% Get the frequency
F = Data.Frequency(:);
stemx = LocalGenerateXDataForStem(F);

for ct = 1:Ny*Nu
   H = Data.Magnitude(:,ct);
   if strcmp(this.Style,'stem')
       stemy = LocalGenerateYDataForStem(abs(H));
       set(double(this.Curves(ct)), 'XData', stemx(:)', 'YData', stemy(:)');
   else
       set(double(this.Curves(ct)), 'XData', F(:)', 'YData', H(:)');       
   end
end
end
function xdata = LocalGenerateXDataForStem(X)
xdata = [1;1;1]*(X(:)'); xdata = xdata(:);
% Place the NaNs every third element for linebreaks
xdata(3:3:end) = NaN;
end
function ydata = LocalGenerateYDataForStem(Y)
ydata = [0;1;1]*(Y(:)'); ydata = ydata(:);
% Place the NaNs every third element for linebreaks
ydata(3:3:end) = NaN;
end

