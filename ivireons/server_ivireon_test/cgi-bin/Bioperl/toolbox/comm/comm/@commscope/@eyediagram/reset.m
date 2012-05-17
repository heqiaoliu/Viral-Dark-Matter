function reset(this)
%RESET  Reset the eye diagram object.
%   RESET(H) resets the eye diagram scope object H. Resetting H clears all the
%   collected data.  
%
%   EXAMPLES:
%
%     % Create an eye diagram scope object
%     h = commscope.eyediagram('RefreshPlot', 'off');
%     % Prepare a noisy sinusoidal as input
%     x = awgn(0.5*sin(2*pi*(0:1/100:10))+j*0.5*cos(2*pi*(0:1/100:10)), 20);
%     update(h, x);             % update the eyediagram
%     h.SamplesProcessed        % Check the number of processed samples
%     reset(h);                 % reset the object
%     h.SamplesProcessed        % Check the number of processed samples
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/ANALYZE,
%   COMMSCOPE.EYEDIAGRAM/CLOSE, COMMSCOPE.EYEDIAGRAM/COPY,
%   COMMSCOPE.EYEDIAGRAM/DISP, COMMSCOPE.EYEDIAGRAM/EXPORTDATA,
%   COMMSCOPE.EYEDIAGRAM/PLOT, COMMSCOPE.EYEDIAGRAM/UPDATE.

%   @commscope/@eyediagram
%
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 01:58:23 $

this.PrivSampsProcessed = 0;
this.PrivNumReceivedSamples = 0;
this.PrivLastNTraces = zeros(this.NumberOfStoredTraces*this.PrivPeriod, 1);

% Reset measurements first to reset setup properly
if ~isempty(this.Measurements)
    this.Measurements.reset;
end

% Rest the histograms last since we use information effected by the contained
% methods 
this.resetHistograms;

%-------------------------------------------------------------------------------
% [EOF]
