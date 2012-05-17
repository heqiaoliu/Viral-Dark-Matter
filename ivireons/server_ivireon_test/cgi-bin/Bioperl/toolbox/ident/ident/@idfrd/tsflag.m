function flag = tsflag(mod,sg)
%TSFLAG  Flags if a time series model is an extracted noise
%   description
%
%   FLAG = TSFLAG(MOD,SG)
%
%   FLAG = 'TimeSeries' if the model MOD is a pure time series
%   description
%   FLAG = 'NoiseModel', if the model has been extracted from a
%   dynamican model as a noise model.
%
%   SG = 'set' or 'get'. If SG=='set' FLAG is the returned model.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2008/10/02 18:47:32 $

ni = nargin;
if ni ==1
    sg = 'get';
end
%sg = lower(sg);
ut = mod.Utility;
if strcmpi(sg,'set')
    ut.tsflag = 'NoiseModel';
    mod.Utility = ut;
    flag = mod;
else
    try
        flag = ut.tsflag;
    catch
        flag = 'TimeSeries';
    end
end

