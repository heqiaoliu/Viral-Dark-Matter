function CI = confinterval(this,x,Pxx,W,CL)
%CONFINTERVAL  Confidence Interval for Periodogram and Welch methods.
%   CI = CONFINTERVAL(THIS,X,PXX,W,CL) calculates the confidence
%   interval CI for spectrum estimate PXX based on confidence level CL. THIS is a
%   spectrum object and W is the frequency vector. X is the data used for
%   computing the spectrum estimate PXX.
%
%   Reference: D.G. Manolakis, V.K. Ingle and S.M. Kagon,
%   Statistical and Adaptive Signal Processing,
%   McGraw-Hill, 2000, Chapter 5

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2007/05/23 19:13:55 $

name = this.EstimationMethod;
L = length(x);

switch lower(name)
    case{'periodogram'}       
        win = generate(this.Window);    
        normsq = win'*win;
        k = L/normsq;      
    case{'welch'}        
        SegLen = this.SegmentLength;
        Per = this.OverlapPercent;
        Noverlap = Per*SegLen/100;      
        k = (L-Noverlap)/(SegLen-Noverlap);              
end

k = fix(k);
c = privatechi2conf(CL,k);
CI = Pxx*c;

% [EOF]
