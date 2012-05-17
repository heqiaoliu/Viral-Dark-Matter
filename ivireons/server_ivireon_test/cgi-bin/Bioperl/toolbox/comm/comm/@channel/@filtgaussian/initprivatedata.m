function initprivatedata(h)

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/14 15:00:52 $

% First initialize base class private data fields.
h.basefiltgaussian_initprivatedata;

pd = h.PrivateData;

pd.OutputSamplePeriod = 1;
pd.CutoffFrequency = 0;
pd.OversamplingFactor = NaN;
pd.ImpulseResponseFcn{1} = @jakes;
pd.TimeDomain = zeros(size(pd.ImpulseResponse));
pd.NumFrequencies = 1024;

h.PrivateData = pd;