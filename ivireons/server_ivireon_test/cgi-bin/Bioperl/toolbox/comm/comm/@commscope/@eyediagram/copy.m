function h = copy(this)
%COPY   Create a copy of the eye diagram object
%   H = COPY(REF_OBJ) creates a new eye diagram scope object H and copies the
%   properties of object H from properties of REF_OBJ.  
%
%   EXAMPLES:
%
%     % Create an eye diagram scope object
%     h = commscope.eyediagram('MinimumAmplitude', -3, 'MaximumAmplitude', 3);
%     disp(h); % display object properties
%
%     h1 = copy(h) % note the absence of semicolon
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/ANALYZE,
%   COMMSCOPE.EYEDIAGRAM/CLOSE, COMMSCOPE.EYEDIAGRAM/DISP,
%   COMMSCOPE.EYEDIAGRAM/EXPORTDATA, COMMSCOPE.EYEDIAGRAM/PLOT,
%   COMMSCOPE.EYEDIAGRAM/RESET, COMMSCOPE.EYEDIAGRAM/UPDATE.

%   @commscope/@eyediagram
%
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 01:58:21 $

% Define fields that should not be copied.  Listeners should not be copied, 
% instead they should be created for each new object.
excludedFields = {'PrivListeners'};

% Copy the object
h = scopeCopy(this, excludedFields);

% Due to resets, we need to copy the data again
% Set private fields that need to be copied
h.PrivSampsProcessed = this.SamplesProcessed;
h.PrivNumReceivedSamples = this.PrivNumReceivedSamples;
h.PrivVerHistRe = this.PrivVerHistRe;
h.PrivVerHistIm = this.PrivVerHistIm;
h.PrivHorHistRe = this.PrivHorHistRe;
h.PrivHorHistIm = this.PrivHorHistIm;
h.PrivLastNTraces = this.PrivLastNTraces;
h.PrivPlotFunction = this.PrivPlotFunction;

h.PrivLastValidSampleIdxIm = this.PrivLastValidSampleIdxIm;
h.PrivLastValidSampleIm = this.PrivLastValidSampleIm;
h.PrivLastValidSampleIdxRe = this.PrivLastValidSampleIdxRe;
h.PrivLastValidSampleRe = this.PrivLastValidSampleRe;
h.PrivLastSampleIndex = this.PrivLastSampleIndex;
h.PrivNumHorHist = this.PrivNumHorHist;

% Reassign measurements since it was reset due to property updates
h.Measurements = copy(this.Measurements);


%-------------------------------------------------------------------------------
% [EOF]
