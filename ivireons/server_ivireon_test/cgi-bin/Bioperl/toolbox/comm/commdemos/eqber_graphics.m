function varargout = eqber_graphics(plotType, varargin)
% EQBER_GRAPHICS - Generate and update plots for the eqber demo.
%   [hBER, hLegend, legendString, hLinSpec, hDfeSpec, hErrs, ...
%       hText1, hText2, hFit, hEstPlot] = ...
%       eqber_graphics('init', chnl, EbNo, idealBER, nBits)
%   generates handles to be used later in the simulation run.
%   Inputs:
%      chnl         - channel impulse response
%      EbNo         - vector of Eb/No values
%      idealBER     - ideal BPSK BER values corresponding to the EbNo vector
%      nBits        - number of bits in a data block
%   Outputs:
%      hBER         - handle to a line in the BER plot
%      hLegend      - vector of handles corresponding to visible legend entries 
%                     in the BER plot
%      legendString - cell array of legend strings for the BER plot
%      hLinSpec     - line handle for the spectrum plot of the linearly 
%                     equalized signal
%      hDfeSpec     - line handle for the spectrum plot of the DFE equalized
%                     signal
%      hErrs        - line handle to a bar plot showing burst error performance
%      hText1       - first text handle for the burst error plot
%      hText2       - second text handle for the burst error plot
%      hFit         - line handle for fitted BER curves
%      hEstPlot     - line handle for the channel estimate plot
%
%
%   hSpecPlot = eqber_graphics('sigspec', eqType, hSpecPlot, nBits, PreD)
%   updates the spectrum plots for adaptively equalized signals.
%   Inputs:
%      eqType       - 'linear', 'dfe', or 'mlse'
%      hSpecPlot    - line handle for the spectrum plot
%      nBits        - number of bits in a data block
%      PreD         - equalized, predetected signal
%   Outputs:
%      hSpecPlot - line handle for the spectrum plot
%
%
%   [hErrs, hText1, hText2] = eqber_graphics('bursterrors', eqType, ...
%      mlseType, firstErrPlot, refMsg, testMsg, nBits, hErrs, hText1, hText2)
%      updates the burst error performance plots.
%   Inputs:
%      eqType       - 'linear', 'dfe', or 'mlse'
%      mlseType     - 'ideal' or 'imperfect'
%      firstErrPlot - flag indicating whether the current plot is the first 
%                     burst error performance plot for the current equalizer
%      refMsg       - transmitted signal, used to find bit errors
%      testMsg      - received signal, used to find bit errors
%      nBits        - number of bits in a data block
%      hErrs        - line handle to a bar plot showing burst error performance
%      hText1       - first text handle for the burst error plot
%      hText2       - second text handle for the burst error plot
%   Outputs:
%      hErrs        - line handle to a bar plot showing burst error performance
%      hText1       - first text handle for the burst error plot
%      hText2       - second text handle for the burst error plot
%
%
%   [hBER, hLegend, legendString] = eqber_graphics('simber', eqType, ...
%      mlseType, firstBlk, EbNoIdx, EbNo, BER, hBER, hLegend, legendString)
%      updates the BER plot.
%   Inputs:
%      eqType       - 'linear', 'dfe', or 'mlse'
%      mlseType     - 'ideal' or 'imperfect'
%      firstBlk     - flag indicating whether the current data block is the
%                     first one being processed for the current equalizer type
%      EbNoIdx      - index over the range of EbNo
%      EbNo         - vector of Eb/No values
%      hBER         - line handle to the current line in the BER plot
%      hLegend      - vector of handles corresponding to visible legend entries 
%                     in the BER plot
%      legendString - cell array of legend strings for the BER plot
%   Outputs:
%      hBER         - line handle to the current line in the BER plot
%      hLegend      - vector of handles corresponding to visible legend entries 
%                     in the BER plot
%      legendString - cell array of legend strings for the BER plot
%
%
%   hFit = eqber_graphics('fitber', eqType, mlseType, hFit, EbNoIdx, EbNo, BER)
%   updates the curve fit to the simulated BER data.
%   Inputs:
%      eqType       - 'linear', 'dfe', or 'mlse'
%      mlseType     - 'ideal' or 'imperfect'
%      hFit         - line handle to the current BER curve fit
%      EbNoIdx      - index over the range of EbNo
%      EbNo         - vector of Eb/No values
%      BER          - vector of BER values corresponding to the Eb/No values
%   Outputs:
%      hFit         - line handle to the current BER curve fit
%
%
%   hEstPlot = eqber_graphics('chnlest', chnlEst, chnlLen, excessEst, ...
%   nBits, firstEstPlot, hEstPlot) updates the channel estimate plot for the
%   MLSE algorithm.
%   Inputs:
%      chnlEst      - impulse response of estimated channel
%      chnlLen      - length of estimated channel impulse response
%      excessEst    - the difference between the length of the estimated channel
%                     impulse response and the actual channel impulse response
%      nBits        - number of bits in a data block
%      firstEstPlot - flag indicating whether the current channel estimate plot 
%                     is the first one
%      hEstPlot     - line handle to the channel estimate plot
%   Outputs:
%      hEstPlot     - line handle to the channel estimate plot

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.12.8 $  $Date: 2010/05/20 01:58:27 $

% ------------------------------------------------------------------------------

switch plotType
    case 'init'
        [chnl, EbNo, idealBER, nBits] = deal(varargin{:});
        
        % Plot the unequalized channel
        hFig = plot_uneqchnl(chnl);
        
        % Plot the ideal BPSK BER curve
        [hBER, hLegend, legendString] = plot_idealber(EbNo, idealBER);
        
        % Initialize a figure to display the linearly equalized signal spectrum
        [hLinSpec, hLinFig] = plot_sigspec('init', 'linear', nBits);
        
        % Initialize a figure to display the DFE equalized signal spectrum
        [hDfeSpec, hDfeFig] = plot_sigspec('init', 'dfe', nBits);
        
        % Initialize a figure to display the burst error performance of the
        % linear equalizer, DFE equalizer, MLSE equalizer with an ideal channel
        % estimate, and an MLSE equalizer with an imperfect channel estimate
        [hErrs, hText1, hText2] = plot_bursterrors('init', [], [], []);
        
        % Initialize a dummy line handle for BER curve fitting
        set(0, 'CurrentFigure', get(get(hBER, 'Parent'), 'Parent'));
        hFit = semilogy(0, 1);
        
        % Initialize a figure to display the frequency response of the imperfect
        % channel estimate
        hEstPlot = plot_chnlest('init', nBits);
        
        varargout = {hBER, hLegend, legendString, hLinSpec, hDfeSpec, hErrs, ...
                     hText1, hText2, hFit, hEstPlot, hFig, hLinFig, hDfeFig};
        
    case 'sigspec'
        [hSpecPlot, hFig] = plot_sigspec('update', varargin{:}); 
        varargout = {hSpecPlot, hFig};
        
    case 'bursterrors'
        [hErrs, hText1, hText2] = plot_bursterrors('update', varargin{:});
        varargout = {hErrs, hText1, hText2};
        
    case 'simber'
        [hBER, hLegend, legendString] = plot_simber(varargin{:});
        varargout = {hBER, hLegend, legendString};
        
    case 'fitber'
        hFit = plot_fitber(varargin{:});
        varargout = {hFit};
        
    case 'chnlest'
        hEstPlot = plot_chnlest('update', varargin{:});
        varargout = {hEstPlot};
end

% ------------------------------------------------------------------------------

function hFig = plot_uneqchnl(chnl)
% PLOT_UNEQCHNL - Plot the frequency response of the unequalized channel
%   Inputs:
%      chnl - channel impulse response
%   Outputs:
%      hFig - figure handle

% Generate a normalized frequency vector from -pi to pi
FFTlen   = 2048;
freq = (-FFTlen/2 : (FFTlen/2)-1)' * (2*pi/FFTlen);

% Generate the normalized frequency response
chnlLen  = length(chnl);
FFTchnl = [chnl; zeros(FFTlen - chnlLen, 1)];
magFFT = abs(fft(FFTchnl));
hFig = figure;
hAxes = axes('parent', hFig);
plot(hAxes, freq, 20*log10(fftshift(magFFT/max(magFFT))));

axis([-3.14 3.14 -40 10]);
pos = figposition([0 45 33 33]);  % for multiple screen resolutions
set(hFig, 'Position', pos);
title(hAxes, 'Unequalized Channel Frequency Response');
xlabel(hAxes, 'Normalized Frequency (rad/s)');
ylabel(hAxes, 'Normalized Magnitude Squared (dB)');
drawnow;

% ------------------------------------------------------------------------------

function [hBER, hLegend, legendString] = plot_idealber(EbNo, idealBER)
% PLOT_IDEALBER - Plot the BER for ideal BPSK
%   Inputs:
%      EbNo         - vector of Eb/No values
%      idealBER     - ideal BER values corresponding to the EbNo values
%   Outputs:
%      hBER         - line handle to the current line in the BER plot
%      hLegend      - vector of handles corresponding to visible legend entries 
%                     in the BER plot
%      legendString - cell array of legend strings for the BER plot

hFig = figure; 
pos = figposition([33.3 45 36 36]);
set(hFig, 'Position', pos);  % for multiple screen resolutions
hAxes = axes('parent', hFig);
set(hAxes, 'YScale'    , 'log', ...
           'XLim'      , [0 16], ...
           'YLim'      , [1e-6 1], ...
           'XTick'     , 0:2:16, ...
           'XGrid'     , 'on', ...
           'YGrid'     , 'on', ...
           'YMinorGrid', 'off');

title(hAxes, 'Equalizer BER Comparison');
xlabel(hAxes, 'Eb/No (dB)');
ylabel(hAxes, 'BER');

hold(hAxes, 'on'); hBER = semilogy(hAxes, EbNo, idealBER);
legendString = 'Ideal BPSK      ';
hLegend = hBER;
legend(hLegend, legendString, 'Location', 'SouthWest');
drawnow;

% ------------------------------------------------------------------------------

function [h, hFig] = plot_sigspec(plotType, eqType, varargin)
% PLOT_SIGSPEC - Initialize or update a plot of an equalized signal spectrum
%   Inputs:
%      plotType - 'init' or 'update' 
%      eqType   - 'linear' or 'dfe'
%      h        - line handle to the signal spectrum plot
%      nBits    - number of bits in a data block
%      PreD     - equalized, predetected signal
%   Outputs:
%      h        - line handle to the signal spectrum plot
%      hFig     - figure handle        

% On initialization, set up all the figure properties and make the figure
% invisible.  On update, simply make the figure visible and reset the values of
% the plotted data.
switch plotType
    case 'init'
        % Generate a frequency vector
        nBits = varargin{1};
        freq = (-nBits/2 : 4 : (nBits/2)-1)' * (2*pi/nBits);
        
        hFig = figure; hAxes = axes('parent', hFig);
        h = plot(hAxes, freq, freq);  % initialize with dummy data
        set(hFig, 'Visible', 'off');
        axis([-3.14 3.14 -40 10]);
        xlabel(hAxes, 'Normalized Frequency (rad/s)');
        ylabel(hAxes, 'Normalized Power Spectrum (dB)');
        
        if (strcmpi(eqType, 'linear'))
            pos  = figposition([0 5 33 33]);
            figTitle = 'Linearly Equalized Signal Power Spectrum';
            color    = [0 0 0];
        elseif (strcmpi(eqType, 'dfe'))
            pos  = figposition([33.3 5 33 33]);
            figTitle = 'Decision Feedback Equalized Signal Power Spectrum';
            color    = [1 0 0];
        end
        title(hAxes, figTitle);
        set(hFig, 'Position', pos);  % for multiple screen resolutions
        set(h, 'Color', color);
       
    case 'update'
        [h, ~, PreD] = deal(varargin{:});

        % Compute data to be plotted
        HEq = fftshift(10*log10(pwelch(PreD)));
        HEq = HEq - max(HEq);
        
        % Get appropriate figure handle and update data
        hFig = ancestor(h, 'figure');
        set(0, 'CurrentFigure', hFig);
        set(hFig, 'Visible', 'on');
        set(h, 'YData', HEq);
        drawnow;
end

% ------------------------------------------------------------------------------

function [hErrs, hText1, hText2] = plot_bursterrors(plotType, varargin)
% PLOT_BURSTERRORS - Plot burst error performance for multiple equalizers.
%   Inputs:
%      plotType     - 'init' or 'update'
%      eqType       - 'linear', 'dfe', or 'mlse'
%      mlseType     - 'ideal' or 'imperfect'
%      firstErrPlot - flag indicating whether the current plot is the first 
%                     burst error performance plot for the current equalizer
%      refMsg       - transmitted signal, used to find bit errors
%      testMsg      - received signal, used to find bit errors
%      nBits        - number of bits in a data block
%      hErrs        - line handle to a bar plot showing burst error performance
%      hText1       - first text handle for the burst error plot
%      hText2       - second text handle for the burst error plot
%   Outputs:
%      hErrs        - line handle to a bar plot showing burst error performance
%      hText1       - first text handle for the burst error plot
%      hText2       - second text handle for the burst error plot
                               
switch plotType
    case 'init'        
        % On initialization, set up all the figure properties.  On update,
        % simply update the plotted data.
        hFig = figure; hAxes = axes('parent', hFig); 
        hErrs = bar(hAxes, 1, 1);   % initialize with dummy data
        hText1 = text(1.7, 1.15, '1');  % initialize with dummy data
        hText2 = text(0.5, 1.05, '2');  % initialize with dummy data
        set(hFig, 'Visible', 'off');
        
    case 'update'        
        [eqType, mlseType, firstErrPlot, refMsg, testMsg, ~, ...
            hErrs, hText1, hText2] = deal(varargin{:});

        if (firstErrPlot)
            % Set parameters based on equalizer settings
            if (strcmpi(eqType, 'linear'))
                errTitle   = 'Burst Error Performance - Linear Equalizer';
                color      = 'k';
            elseif (strcmpi(eqType, 'dfe'))
                errTitle   = 'Burst Error Performance - DFE';
                color      = 'r';
            elseif (strcmpi(eqType, 'mlse'))
                if (strcmpi(mlseType, 'ideal'))
                    errTitle = 'Burst Error Performance - Ideal MLSE';
                    color    = 'g';
                elseif (strcmpi(mlseType, 'imperfect'))
                    errTitle = 'Burst Error Performance - Imperfect MLSE';
                    color    = 'm';
                end
            end
        end
        
        % Find the distribution of intervals between errors for this block of
        % data. Categorize into intervals of 1, 2, 3, 4, 5, and greater than 5.
        % For all error intervals greater than 5, clip the value to 6.
        errs       = double(xor(refMsg, testMsg));  % actual bit errors
        errIntDist = diff(find(errs==1));           % intervals between errors
        errIntDist((errIntDist>5)) = 6;     % Clip all vals>5 to a val of 6
        numErrs    = sum(errs);                 % number of errors in this block

        % Find the number of error intervals from 1 to 6
        errIntPct = zeros(6,1);
        for i = 1:6
            errIntPct(i) = length(errIntDist(errIntDist==i));
        end
        
        if (~isempty(errIntDist))  % for all data blocks with errors
            errIntPct = errIntPct / length(errIntDist);  % normalize so that
                                                         % the elements sum to 1
            
            % Find the average interval between errors for randomly distributed
            % errors, and reformat for plotting purposes
            avgInt = length(errs) / numErrs;  
            avgInt = num2str(avgInt);
            avgInt = avgInt(1:min(4,length(avgInt)));
            if (strcmpi(avgInt(end), '.'))
                avgInt(end) = ''; 
            end
            
            if firstErrPlot
                figToClose = ancestor(hErrs, 'figure');
                close(figToClose(ishghandle(figToClose)))  % close last fig
                hFig = figure; hAxes = axes('parent', hFig); 
                hErrs = bar(hAxes, errIntPct, color);  % new bar plot
                errPos  = figposition([69 45 30 36]);
                set(hFig, 'Position', errPos);
                xlabel(hAxes, 'Interval between Consecutive Errors (bits)');
                ylabel(hAxes, 'Fraction of Occurrences');
                set(hAxes, 'XTickLabel', reshape(' 1 2 3 4 5>5',2,6)');
                axis([0 7 0 1.2]);
                title(hAxes, errTitle);
                hText1 = text(1.2, 1.15, ...
                    [num2str(numErrs) ' errors in this data block']);
                hText2 = text(0.5, 1.05, ...
                    ['Avg random error interval = ' avgInt ' bits']);
                set(hText1, 'FontWeight', 'bold');
                set(hText2, 'FontWeight', 'bold');
            else
                set(hErrs,  'YData',  errIntPct);
                set(hText1, 'String', ...
                    [num2str(numErrs) ' errors in this data block']);
                set(hText2, 'String', ...
                    ['Avg random error interval = ' avgInt ' bits']);
            end
        end
        drawnow;
end

% ------------------------------------------------------------------------------

function [hBER, hLegend, legendString] = plot_simber(varargin)
% PLOT_SIMBER - Plot the BER performance for the current equalizer
%   Inputs:
%      eqType       - 'linear', 'dfe', or 'mlse'
%      mlseType     - 'ideal' or 'imperfect'
%      firstBlk     - flag indicating whether the current data block is the
%                     first one being processed for the current equalizer type
%      EbNoIdx      - index over the range of EbNo
%      EbNo         - vector of Eb/No values
%      hBER         - line handle to the current line in the BER plot
%      hLegend      - vector of handles corresponding to visible legend entries 
%                     in the BER plot
%      legendString - cell array of legend strings for the BER plot
%   Outputs:
%      hBER         - line handle to the current line in the BER plot
%      hLegend      - vector of handles corresponding to visible legend entries 
%                     in the BER plot
%      legendString - cell array of legend strings for the BER plot

[eqType, mlseType, firstBlk, EbNoIdx, EbNo, BER, hBER, hLegend, ...
    legendString] = deal(varargin{:});

if (firstBlk && EbNoIdx==1)
    % Set parameters based on equalizer setting
    if (strcmpi(eqType, 'linear'))
        legendLine = 'Linear Equalizer';
        color      = [0 0 0];
    elseif (strcmpi(eqType, 'dfe'))
        legendLine = 'DFE             ';
        color      = [1 0 0];
    elseif (strcmpi(eqType, 'mlse'))
        if (strcmpi(mlseType, 'ideal'))
            legendLine = 'Ideal MLSE      ';
            color      = [0 0.8 0];
        else
            legendLine = 'Imperfect MLSE  ';
            color      = [1 0 1];
        end
    end

    % Set current figure to the BER figure and begin to plot a new curve.
    % Update the legend for this new case.  Do not include handles to curve fits
    % in the vector of legend handles.
    hAxes = ancestor(hBER, 'axes');
    hBER = semilogy(hAxes, EbNo(1), BER(1), '*');
    set(hBER, 'Color', color);
    hLegend = [hLegend hBER];
    legendString = [legendString; legendLine];
    legend(hLegend, legendString, 'Location', 'SouthWest');
else
    % Simply update the plotted data
    set(0, 'CurrentFigure', ancestor(hBER, 'figure'));
    set(hBER, 'XData', EbNo(1:EbNoIdx), ...
              'YData', BER(1:EbNoIdx));
end
drawnow;

% ------------------------------------------------------------------------------

function hFit = plot_fitber(varargin)
% PLOT_FITBER - Plot a curve fit to the current BER points.
%   Inputs:
%      eqType       - 'linear', 'dfe', or 'mlse'
%      mlseType     - 'ideal' or 'imperfect'
%      hFit         - line handle to the current BER curve fit
%      EbNoIdx      - index over the range of EbNo
%      EbNo         - vector of Eb/No values
%      BER          - vector of BER values corresponding to the Eb/No values
%   Outputs:
%      hFit         - line handle to the current BER curve fit

[eqType, mlseType, hFit, EbNoIdx, EbNo, BER] = deal(varargin{:});

if (EbNoIdx == 4)  % first plot
    % Set parameters based on equalizer setting
    if (strcmpi(eqType, 'linear'))
        color = [0 0 0];
    elseif (strcmpi(eqType, 'dfe'))
        color = [1 0 0];
    elseif (strcmpi(eqType, 'mlse'))
        if (strcmpi(mlseType, 'ideal'))
            color   = [0 0.5 0];
        elseif (strcmpi(mlseType, 'imperfect'))
            color   = [1 0 1];
        end
    end

    fitEbNo = EbNo(1):0.1:EbNo(EbNoIdx);  % vector of Eb/No values over
                                          % which to plot
    fitBER = berfit(EbNo(1:EbNoIdx), BER(1:EbNoIdx), fitEbNo, [], 'exp+const');
    hAxes = ancestor(hFit, 'axes');
    hFit = semilogy(hAxes, fitEbNo, fitBER);
    set(hFit, 'Color', color);
    
elseif (EbNoIdx > 4)
    fitEbNo = EbNo(1):0.1:EbNo(EbNoIdx);
    warnState = warning('off', 'comm:berfit:fitIsComplex');
    fitBER = berfit(EbNo(1:EbNoIdx), BER(1:EbNoIdx), fitEbNo, [], 'exp+const');
    if ( isempty(fitBER) )
        fitBER = berfit(EbNo(1:EbNoIdx), BER(1:EbNoIdx), fitEbNo, [], 'doubleExp+const');
    end;
    warning(warnState);
    set(hFit, 'XData', fitEbNo, 'YData', fitBER);
end
drawnow;

% ------------------------------------------------------------------------------

function hEstPlot = plot_chnlest(plotType, varargin)
% PLOT_CHNLEST - Plot a channel estimate for the current block of data.
%   Inputs:
%      plotType     - 'init' or 'update'
%      chnlEst      - impulse response of estimated channel
%      chnlLen      - length of estimated channel impulse response
%      excessEst    - the difference between the length of the estimated channel
%                     impulse response and the actual channel impulse response
%      nBits        - number of bits in a data block
%      firstEstPlot - flag indicating whether the current channel estimate plot 
%                     is the first one
%      hEstPlot     - line handle to the channel estimate plot
%   Outputs:
%      hEstPlot     - line handle to the channel estimate plot

[chnlEst, chnlLen, excessEst, nBits, firstEstPlot, hEstPlot] = ...
    deal(varargin{:});

% For the first plot, set up all the figure properties and make the figure
% invisible.  Thereafter, simply make the figure visible and update the plotted
% data.
switch plotType
    case 'init'
        freq = (-nBits/2 : 4 : (nBits/2)-1)' * (2*pi/nBits);
        hFig = figure; hAxes = axes('parent', hFig); 
        hEstPlot = plot(hAxes, freq, freq); % plot dummy data
        pos = figposition([66.6 5 33 33]);
        set(hFig, 'Position', pos);  % for multiple screen resolutions
        axis([-3.14 3.14 -40 10]);
        title(hAxes, 'Estimated Channel Frequency Response');
        xlabel(hAxes, 'Normalized Frequency (rad/s)');
        ylabel(hAxes, 'Normalized Magnitude Squared (dB)');
        set(hEstPlot, 'Color', [1 0 1]);
        set(hFig, 'Visible', 'off');
        
    case 'update'
        % Process the time domain channel estimate to determine the frequency
        % response.  Ensure that the data is complex, for the pwelch function.
        chnlPlot = [chnlEst(1:chnlLen+excessEst); ...
            zeros(nBits-(chnlLen+excessEst),1)];
        if (isreal(chnlPlot))
            chnlPlot(1) = real(chnlPlot(1)) + 1i*eps;
        end
        HEstPlot = fftshift(10*log10(pwelch(chnlPlot)));
        HEstPlot = HEstPlot - max(HEstPlot);
        set(hEstPlot, 'YData', HEstPlot);
        if (firstEstPlot)
            set(ancestor(hEstPlot, 'figure'), 'Visible', 'on');
        end
        drawnow;
end