function y=pdf(obj,x)
%PDF Probability density function.
%    Y = PDF(PD,X) returns an array Y containing the probability density
%    function (PDF) for the probability distribution PD, evaluated at
%    values in X.
%
%    See also PROBDISTUNIVKERNEL, PDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:12 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDistUnivKernel:pdf:TooFewInputs',...
        'Two input arguments are required.');
end

ksinfo = obj.ksinfo;
y = dfswitchyard('statkscompute','pdf',x,true,length(x),obj.BandWidth, ...
                 ksinfo.L,ksinfo.U,ksinfo.weight,[],obj.Kernel,...
                 ksinfo.ty,[],ksinfo.foldpoint,ksinfo.maxp);

