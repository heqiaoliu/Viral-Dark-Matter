function CI = confinterval(this,x,Pxx,W,CL)
%CONFINTERVAL  Confidence Interval for MTM method.
%   CI = CONFINTERVAL(THIS,X,PXX,W,CL) calculates the confidence
%   interval CI for spectrum estimate PXX based on confidence level CL. THIS is a
%   spectrum object and W is the frequency vector. X is the data used for
%   computing the spectrum estimate PXX.
%
%
%   References: 
%     [1] Thomson, D.J."Spectrum estimation and harmonic analysis."
%         In Proceedings of the IEEE. Vol. 10 (1982). Pgs 1055-1096.
%     [2] Percival, D.B. and Walden, A.T., "Spectral Analysis For Physical
%         Applications", Cambridge University Press, 1993, pp. 368-370. 


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2007/05/23 19:14:00 $

name = this.SpecifyDataWindowAs;
N = length(x);
switch lower(name)
    case{'timebw'}
        NW = this.TimeBW;
        k = min(round(2*NW),N);
        k = max(k-1,1);              
    case{'dpss'}
        k = length(this.Concentrations);
end

c = privatechi2conf(CL,k);
CI = Pxx*c;


% [EOF]
