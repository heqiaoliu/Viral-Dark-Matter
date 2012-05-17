function [z,kzz] = zfcheck(z,m)
%ZFCHECK Removes zero frequency from Frequency Domain Data if model
%contains an integration
%
%   Internal function
%   z data, m model, kzz removed freqnumbers (cell array)

%	L. Ljung 03-08-10
%	Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.1.4.3 $  $Date: 2008/10/02 18:52:17 $

zfflag = 0;
kzz = cell(1,size(z,'Ne'));
if strcmp(pvget(z,'Domain'),'Frequency')
    fre = pvget(z,'SamplingInstants');
    for kexp = 1:length(fre)
        if any(fre{kexp}==0)
            zfflag = 1;
        end
    end
end
if zfflag
    was = warning('off'); [lw,lwid] = lastwarn;
    fr = freqresp(m,0);
    warning(was), lastwarn(lw,lwid)
    if any(~isfinite(fr))
        ctrlMsgUtils.warning('Ident:analysis:zeroFrequencyRemoved1')
        [z,kzz] = rmzero(z);
    end
end