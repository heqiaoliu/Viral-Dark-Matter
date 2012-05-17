function datamod = nyqcut(data)
%NYQCUT Cuts way data above the Nyquist frequency

%   L. Ljung 03-06-05
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2008/10/02 18:47:25 $

fre = data.Frequency;
if strcmpi(data.Units,'hz')
    picorr = 2*pi;
else
    picorr = 1;
end
if data.Ts > 0 && any(fre>pi/picorr/data.Ts+1e4*eps)
    ctrlMsgUtils.warning('Ident:dataprocess:freqAboveNyquist')
    datamod = fselect(data,find(fre<=pi/picorr/data.Ts+1e4*eps));
else
    datamod = data;
end
