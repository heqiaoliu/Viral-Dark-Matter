function buffer_initprivatedata(h);

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:11 $

pd = h.PrivateData;
pd.BufferSize = 1;
pd.NumChannels = 1;
h.PrivateData = pd;
