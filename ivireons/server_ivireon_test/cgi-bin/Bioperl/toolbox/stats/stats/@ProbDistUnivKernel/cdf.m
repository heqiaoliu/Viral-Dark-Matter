function y=cdf(obj,x)
%CDF Cumulative distribution function.
%    Y = CDF(PD,X) returns an array Y containing the cumulative
%    distribution function (CDF) for the probability distribution
%    PD, evaluated at values in X.
%
%    See also PROBDISTUNIVKERNEL, CDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:07 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDistUnivKernel:cdf:TooFewInputs',...
        'Two input arguments are required.');
end

ksinfo = obj.ksinfo;
y = dfswitchyard('statkscompute','cdf',x,true,length(x),obj.BandWidth, ...
                 ksinfo.L,ksinfo.U,ksinfo.weight,[],obj.Kernel,...
                 ksinfo.ty,[],ksinfo.foldpoint,ksinfo.maxp);
