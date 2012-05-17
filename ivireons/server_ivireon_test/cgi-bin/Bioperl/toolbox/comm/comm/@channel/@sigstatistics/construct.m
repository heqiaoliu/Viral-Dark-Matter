function construct(h, varargin);
%CONSTRUCT  Construct signal statistics object.
%
%  Inputs:
%    h    - Signal statistics object
%    Ts   - Sample period
%    NB   - Signal buffer size
%    NC   - Number of channels
%    NF   - Number of frequencies for power spectrum

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:19 $

error(nargchk(1, 5, nargin,'struct'));

h.buffer_initprivatedata;

h.Autocorrelation = channel.sigresponse;
h.PowerSpectrum = channel.sigresponse;

% Set parameters if specified.
p = {'SamplePeriod'
     'BufferSize'
     'NumChannels'
     'NumFrequencies'};
set(h, p(1:length(varargin)), varargin);

h.initialize;

h.Constructed = true;



