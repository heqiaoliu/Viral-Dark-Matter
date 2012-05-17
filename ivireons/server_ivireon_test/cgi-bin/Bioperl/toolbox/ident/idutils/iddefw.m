function [w,idx] = iddefw(sys,type)
%IDDEFW Sets default frequency vectors
%
%   W = IDDEFW(SYS,TYPE)
%
%   SYS: any IDMODEL or LTI Model
%   W: Suitable frequency vector for this model.
%   If TYPE == 'Nyquist' the freqeuncies are suited for Nyquist plots
%   while TYPE == 'BODE' gives frequencies for Bode plots.

%	Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.2.4.5 $  $Date: 2009/10/16 04:56:38 $

if nargin<2
    type = 'n';%Nyquist
end
type = lower(type(1));
idx = [];
T = pvget(sys,'Ts');
try
    [z,p] = zpkdata(sys);
catch
    z = []; p = [];
end
inpd = pvget(sys,'InputDelay');

try
    w = freqpick(z,p,T,inpd,1,'d');
catch
    if T>0
        w = (1:128)/128*pi/T;
    else
        try
            es = pvget(sys,'EstimationInfo');
            Ts = es.DataTs;
        catch
            Ts = [];
        end
        if isempty(Ts)
            Ts = 1;
        end        
        w = logspace(log10(pi/abs(Ts)/100),log10(10*pi/abs(Ts)),128);
    end
end

try
    if type=='b'
        sys1 = pvset(sys,'InputDelay',zeros(size(inpd)));
        was = ctrlMsgUtils.SuspendWarnings('Ident:dataprocess:freqAboveNyquist');
        h = permute(freqresp(sys1,w),[3 1 2]);
        delete(was)
        FocusInfo = freqfocus(w,h,z,p,T);
        [~,idx] = roundfocus('freq',FocusInfo.Range(3,:),w,[],[]);
        %end
        % if type=='b'
        if ~isempty(idx)
            w = w(idx);
        end
    end
end
