function [Tf,Ts] = iddeft(sys,T2)
%IDDEFT Sets default time scales.
%
%   [Tf,Ts] = IDDEFT(SYS);
%
%   SYS: Any Idmodel or LTI model.
%   Tf: A suitable final time for impulse and step responses.
%   Ts: A suitable sampling time if SYS is continuous time
%   [Tf,Ts] = IDDEFT(SYS,T) takes a final simulation time T into
%   account when selecting Ts.

%	Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.2.4.5 $  $Date: 2006/09/30 00:20:13 $

maxptsd = 50000;
maxptsc = 5000;
minptsc = 50;
if nargin<2
    T2 = [];
end

Ts1 = pvget(sys,'Ts');
[a,b,c,d,k] = ssdata(sys);
ndel = max(pvget(sys,'InputDelay'));
if isempty(ndel), ndel = 0; end
if isempty(b), b=k; d=eye(size(b,2)); end
if Ts1
    np = dtimscale(a,zeros(size(a,1),0),c,d,b,Ts1);
    np = min(np,maxptsd);
    np = max(np,2*ndel); % To be sure that the delay shows
    Tf = np*Ts1;
else
    [dum,Tf] = timscale(a,zeros(size(a,1),0),c,b,[]);
    Tf = max(Tf,2*ndel);
end

if nargout > 1
    if Ts1
        Ts = Ts1;
    else
        Ts = timscale(a,[],c,b,T2);
        Ts = max(Ts,Tf/maxptsc);
        Ts = min(Ts,Tf/minptsc);
    end
end
