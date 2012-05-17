function [uni,Ts,inters] = dunique(data)
%DUNIQUE Tests Sampling interval and intersample behavior.
%    
%   [UNI,Ts,INTERS] = DUNIQUE(DATA)
%
%   DATA : The data as an IDDATA objetc
%   UNI:   Returned as 1 if all experiments in IDDATA have the same
%          sampling interval and the same intersample behaviour.
%          0 otherwise.
%   Ts:    If UNI ==1 Ts is the common sampling interval.
%          The data.Ts otherwise.
%   INTERS: If UNI ==1, INTERS is the common intersample behaviour.
%           Data.InterSample otherwise.
%
%   Note: This version assumes all inputs have the same intersample
%   behavior in each experiment.

%	L. Ljung 10-1-2005
%	Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.1.6.2 $  $Date: 2008/10/02 18:46:44 $


Tsc = pvget(data,'Ts');
Tst = unique(cat(1,Tsc{:}));
Intersc = pvget(data,'InterSample');
if ~isempty(Intersc)
    Intersc = Intersc(1,:); % Just checking the first input
end
interst = unique(Intersc);
if length(Tst)==1 && (length(interst)==1 || isempty(interst))
    Ts = Tst;
    uni = 1;
    if isempty(interst)
        inters = 'zoh'; % Time series case
    else
        inters = interst{1};
    end
else
    uni = 0;
    Ts = Tsc;
    inters = Intersc;
end
 