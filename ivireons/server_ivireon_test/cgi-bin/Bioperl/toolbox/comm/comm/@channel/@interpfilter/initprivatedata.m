function initprivatedata(h);

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:46 $

% First initialize base class private data fields.
h.basesigproc_initprivatedata;

pd = h.PrivateData;

pd.PolyphaseInterpFactor = [2];
pd.LinearInterpFactor = [1];
pd.SubfilterLength = [8];
pd.MaxSubfilterLength = [8];
pd.NumChannels = [1];
pd.FilterBank = [1];
pd.FilterInputState = [1];
pd.FilterPhase = [1];
pd.LastFilterOutputs = [0 0];
pd.LinearInterpIndex = [1];

h.PrivateData = pd;
