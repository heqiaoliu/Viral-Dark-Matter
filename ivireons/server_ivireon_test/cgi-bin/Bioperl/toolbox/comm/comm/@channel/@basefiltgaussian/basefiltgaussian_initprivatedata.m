function basefiltgaussian_initprivatedata(h);

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:18:53 $

% First initialize base class private data fields.
h.basesigproc_initprivatedata;

pd = h.PrivateData;

pd.NumChannels = 1;
pd.ImpulseResponse = [0];
pd.LastOutputs = [0];
pd.State = [0];
pd.WGNState = 0;

h.PrivateData = pd;
