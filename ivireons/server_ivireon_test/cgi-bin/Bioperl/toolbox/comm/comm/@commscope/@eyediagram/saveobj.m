function s = saveobj(this)
%SAVEOBJ Save the object THIS

%   @commscope\@eyediagram

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 01:58:24 $

% Get the class fields
s = get(this);

% Get private fields that need to be saved
s.PrivVerHistRe = this.PrivVerHistRe;
s.PrivVerHistIm = this.PrivVerHistIm;
s.PrivHorHistRe = this.PrivHorHistRe;
s.PrivHorHistIm = this.PrivHorHistIm;
s.PrivLastNTraces = this.PrivLastNTraces;
s.PrivPlotFunction = this.PrivPlotFunction;

s.PrivLastValidSampleIdxIm = this.PrivLastValidSampleIdxIm;
s.PrivLastValidSampleIm = this.PrivLastValidSampleIm;
s.PrivLastValidSampleIdxRe = this.PrivLastValidSampleIdxRe;
s.PrivLastValidSampleRe = this.PrivLastValidSampleRe;
s.PrivNumHorHist = this.PrivNumHorHist;
s.PrivNumReceivedSamples = this.PrivNumReceivedSamples;

% Get the objects class
s.class = class(this);

%-------------------------------------------------------------------------------
% [EOF]
