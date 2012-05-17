function plot(this, varargin)
%PLOT   Display the eye diagram figure
%
%   The PLOT method has three usage cases:
%
%   - PLOT(H) plots the eye diagram for the eye diagram object H with the
%   current COLORMAP or the default LINESPEC.
%   - PLOT(H, CMAP) when used with the PLOTYPE set to '2D Color' or '3D Color'
%   plots the eye diagram for the eye diagram object H and sets the COLORMAP to
%   CMAP. 
%   - PLOT(H, LINESPEC) when used with the PLOTTYPE set to '2D Line' plots the
%   eye diagram for the eye diagram object H using LINESPEC as the line
%   specification.  See <a href="matlab:help plot">help for plot</a> for valid LINESPECs.
%
%   EXAMPLES:
%
%     % Create an eye diagram scope object
%     h = commscope.eyediagram;
%     % Prepare a noisy sinusoid as input
%     x = awgn(0.5*sin(2*pi*(0:1/100:10))+j*0.5*cos(2*pi*(0:1/100:10)), 20);
%     % Update the eye diagram
%     update(h, x);
%     % Display the eye diagram figure
%     plot(h)
%
%     % Display the eye diagram figure with jet colormap
%     plot(h, jet(64))
%
%     % Display 2D Line eye diagram with red dashed lines
%     h.PlotType = '2D Line';
%     plot(h, 'r--')
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/ANALYZE,
%   COMMSCOPE.EYEDIAGRAM/CLOSE, COMMSCOPE.EYEDIAGRAM/COPY,
%   COMMSCOPE.EYEDIAGRAM/DISP, COMMSCOPE.EYEDIAGRAM/EXPORTDATA,
%   COMMSCOPE.EYEDIAGRAM/RESET, COMMSCOPE.EYEDIAGRAM/UPDATE.

%   @commscope/@eyediagram
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/05/31 23:15:08 $

% Get the data
if ( strcmp(this.PrivPlotType, '2D Line') )
    if isempty(this.PrivLastNTraces)
        error([this.getErrorId ':PlotNoDataStored'], ['No traces '...
        'were stored for line plot.  The number of input data samples '...
        'must be at least the length of one trace, which is '...
        'SamplesPerSymbol*SymbolsPerTrace samples.']);
    else
        numTraces = this.NumberOfStoredTraces;
        numStoredTraces = length(this.PrivLastNTraces)/this.PrivPeriod;
        if ( numTraces > numStoredTraces )
            numTraces = numStoredTraces;
        end
        dataRe = real(this.PrivLastNTraces(1:this.PrivPeriod*numTraces));
        dataIm = imag(this.PrivLastNTraces(1:this.PrivPeriod*numTraces));

        if ( nargin == 2 )
            if ( ~ischar(varargin{1}) )
                error([this.getErrorId ':PlotLineSpecWrongUsage'], ['LINESPEC '...
                    'must be a string. Type "help %s.plot" for proper usage.'], ...
                    class(this));
            end
        elseif ( nargin > 2 )
            error([this.getErrorId ':PlotWrongUsage'], ['Too many input '...
                'arguments. Type "help %s.plot" for proper usage.'], class(this));
        end
    end
else
    % Get the PDF
    [dataRe dataIm] = this.calcPDF;

    if ( nargin == 2 )
        % Prepare for baseclass processing
        varargin = {'ColorMap', varargin{1}};
        % Also update stored colormap
        this.PrivColorMap = varargin{2};
    elseif ( nargin > 2 )
        error([this.getErrorId ':PlotWrongUsage'], ['Too many input '...
            'arguments. Type "help %s.plot" for proper usage.'], class(this));
    end
end

% Apply time offset
offset = this.PrivPlotTimeOffset;
if ( strcmp(this.PrivPlotType, '2D Line') )
    % First linearize the stored traces, add NaN to the beginning or the end to
    % apply time offset, and reshape to obtain traces
    M = this.PrivPeriod;
    N = numStoredTraces;
    if ( offset > 0 )
        dataDummyRe = [NaN(offset, 1); dataRe(1:end-offset)];
        dataDummyIm = [NaN(offset, 1); dataIm(1:end-offset)];
    else
        dataDummyRe = [dataRe(1-offset:end); NaN(-offset, 1)];
        dataDummyIm = [dataIm(1-offset:end); NaN(-offset, 1)];
    end
    dataRe = reshape(dataDummyRe, M, N);
    dataIm = reshape(dataDummyIm, M, N);
else
    dataRe = circshift(dataRe, [0 offset]);
    dataIm = circshift(dataIm, [0 offset]);
end

% Plot
if this.PrivOperationMode
    plotSignal(this, dataRe+j*dataIm, varargin{:});
else
    plotSignal(this, dataRe, varargin{:});
end

% Make sure that figure next plot is new
set(this.PrivScopeHandle, 'NextPlot', 'new');

%-------------------------------------------------------------------------------
% [EOF]
