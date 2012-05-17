function initprivatedata(h);

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:25 $

% First initialize base class private data fields.
h.basesigproc_initprivatedata;

pd = h.PrivateData;

pd.InputSamplePeriod = 1;
pd.PathDelays = [0];
pd.TapIndices = [0];
pd.AutoComputeTapIndices = 1;
pd.AlphaTol = 0.0;
pd.State = [complex(0)];

h.PrivateData = pd;
