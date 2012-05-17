function basesigproc_initprivatedata(h);

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:05 $

pd = h.PrivateData;

pd.ObjectLocked = 0;
pd.EnableProbe = 0;
pd.ProbeFcn = @probe;
pd.NumSampOutput = 0;
pd.UseCMEX = 1;

h.PrivateData = pd;
