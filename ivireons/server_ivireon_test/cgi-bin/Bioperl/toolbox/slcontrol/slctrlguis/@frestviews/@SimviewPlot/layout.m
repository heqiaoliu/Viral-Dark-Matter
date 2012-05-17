function layout(this)
%  LAYOUT lays out the SimviewPlot placing the individual components
%  depending on their visibility specified in the options.
%


% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2009/10/16 06:46:18 $

FigPos = get(this.Figure,'Position');

FigW = FigPos(3);
FigH = FigPos(4);

% Spacing values in pixels
tgap = 35;
bgap = 50;
lgap = 66;
rgap = 20;

Pix2Norm = [FigW FigH FigW FigH];

activeFigPos = [lgap,bgap,FigW-(lgap+rgap) FigH-(tgap+bgap)];
activeFigW = activeFigPos(3);
activeFigH = activeFigPos(4);

% Place title in the top gap
set(this.TitleBar.Handle,'Position',[lgap FigH-tgap activeFigW tgap]./Pix2Norm);

% Define gaps between components in pixels
vertgap = 60; % Vertical space between summary and time (or FFT)
horzgap = 80; % Horizontal space between time and FFT

summaryH = 0.22*activeFigH; % Vertical height of summary panel;

istimevisible = strcmp(this.TimePlot.AxesGrid.Visible,'on');
isfftvisible = strcmp(this.SpectrumPlot.AxesGrid.Visible,'on');
issumvisible = ~isempty(this.Summary) && strcmp(this.SummaryPlot.SummaryBode.AxesGrid.Visible,'on');

if ~istimevisible && ~isfftvisible && ~issumvisible
    % If none is visible, just return
    return
    
elseif istimevisible && isfftvisible && issumvisible
    % Everything visible
    summarypos = [activeFigPos(1), activeFigPos(2),...
        activeFigW, summaryH];
    timepos = [activeFigPos(1), activeFigPos(2)+summaryH+vertgap,...
        activeFigW/2-horzgap/2, activeFigH-summaryH-vertgap];
    fftpos = [activeFigPos(1)+activeFigW/2+horzgap/2, activeFigPos(2)+summaryH+vertgap,...
        activeFigW/2-horzgap/2, activeFigH-summaryH-vertgap];
    this.SummaryPlot.SummaryBode.AxesGrid.Position = summarypos./Pix2Norm;
    this.TimePlot.AxesGrid.Position = timepos./Pix2Norm;
    this.SpectrumPlot.AxesGrid.Position = fftpos./Pix2Norm;
elseif istimevisible && isfftvisible && ~issumvisible
    % Time and spectrum, No summary
    timepos = [activeFigPos(1), activeFigPos(2),...
        activeFigW/2-horzgap/2, activeFigH];
    fftpos = [activeFigPos(1)+activeFigW/2+horzgap/2, activeFigPos(2),...
        activeFigW/2-horzgap/2, activeFigH];
    this.TimePlot.AxesGrid.Position = timepos./Pix2Norm;
    this.SpectrumPlot.AxesGrid.Position = fftpos./Pix2Norm;
elseif istimevisible && ~isfftvisible && ~issumvisible
    % Time only
    this.TimePlot.AxesGrid.Position = activeFigPos./Pix2Norm;
elseif ~istimevisible && isfftvisible && ~issumvisible
    % Spectrum only
    this.SpectrumPlot.AxesGrid.Position = activeFigPos./Pix2Norm;
elseif istimevisible && ~isfftvisible && issumvisible
    % Time and summary
    summarypos = [activeFigPos(1), activeFigPos(2),...
        activeFigW, summaryH];
    timepos = [activeFigPos(1), activeFigPos(2)+summaryH+vertgap,...
        activeFigW, activeFigH-summaryH-vertgap];
    this.SummaryPlot.SummaryBode.AxesGrid.Position = summarypos./Pix2Norm;
    this.TimePlot.AxesGrid.Position = timepos./Pix2Norm;
elseif ~istimevisible && isfftvisible && issumvisible
    % Spectrum and summary
    summarypos = [activeFigPos(1), activeFigPos(2),...
        activeFigW, summaryH];
    fftpos = [activeFigPos(1), activeFigPos(2)+summaryH+vertgap,...
        activeFigW, activeFigH-summaryH-vertgap];
    this.SummaryPlot.SummaryBode.AxesGrid.Position = summarypos./Pix2Norm;
    this.SpectrumPlot.AxesGrid.Position = fftpos./Pix2Norm;
elseif ~istimevisible && ~isfftvisible && issumvisible
    % Summary only - keep it at the bottom
    summarypos = [activeFigPos(1), activeFigPos(2),...
        activeFigW, summaryH];
    this.SummaryPlot.SummaryBode.AxesGrid.Position = summarypos./Pix2Norm;
end


    



