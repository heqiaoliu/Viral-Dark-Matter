function [fit,Tz] = findtau(tau,m0,Ts,zt,zflag)
%FINDTAU Auxiliary function to IDPROC/INIVAL
%

% Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2009/10/16 04:56:34 $

was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF'); %#ok<NASGU>
m0 = pvset(m0,'InputDelay',tau);
yh0 = sim(m0,zt(:,[],:));
yyh0= pvget(yh0,'OutputData');
yyh0=cat(1,yyh0{:});
yy = pvget(zt,'OutputData');
yy = cat(1,yy{:});
if zflag
    kk = pvget(m0,'b');
    acp = pvget(m0,'f');
    m1 = idpoly(1,kk*[1 1],1,1,acp,'ts',0,'udel',tau,'una',pvget(zt,'InputName'));
    yh1 = sim(m1,zt(:,[],:));
    yyh1 = pvget(yh1,'OutputData');
    yyh1 = cat(1,yyh1{:});%yh1.y;
    y1 = yyh1-yyh0;
    Tz = real(((yy-yyh0)'*y1)/(y1'*y1));
    fit = norm(yy-yyh0-Tz*y1);
else
    fit = norm(yy-yyh0);
end


