function y=icdf(obj,p)
%ICDF Inverse cumulative distribution function.
%    Y = ICDF(PD,P) returns an array Y containing the inverse cumulative
%    distribution function (ICDF) for the probability distribution object
%    PD, evaluated at values in P.
%
%    See also PROBDISTUNIVKERNEL, ICDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:09 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDistUnivKernel:icdf:TooFewInputs',...
        'Two input arguments are required.');
end

ksinfo = obj.ksinfo;
yrange = [min(ksinfo.ty), max(ksinfo.ty)];
y = dfswitchyard('statkscompute','icdf',p,true,length(p),obj.BandWidth, ...
                 ksinfo.L,ksinfo.U,ksinfo.weight,[],obj.Kernel,...
                 ksinfo.ty,yrange,ksinfo.foldpoint,ksinfo.maxp);

