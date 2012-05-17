function Ts = utComputeLinearizationTs(this,Tsx,Tsy,Tsinit)
% UTCOMPUTELINEARIZATIONTS  Compute the sample time of a linearization.
 
% Author(s): John W. Glass 11-Sep-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:51 $

% Default is least common multiple of all sample times.  Compute the unique
% sample times.  If there are no states also assume that the sample time
% is zero so the d2d conversions are not performed.
Ts_all = [Tsx;Tsy];
Tuq = unique(Ts_all(Ts_all >= 0));
Tuq(isinf(Tuq)) = [];
Ts = LocalComputeTs(Tuq,Tsinit);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalComputeTs
%  Compute the sample time of the linearization
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Ts = LocalComputeTs(Tuq,Tsinit)

if (Tsinit == -1)
    if max(Tuq) == 0
        Ts = 0;
    else
        Ts = local_vlcm(Tuq);
        if isempty(Ts)
            Ts = -1;
        end
    end
else
    Ts = Tsinit;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  local_vlcm
%  Find least common multiple of several sample times
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = local_vlcm(x)

% Protect against a few edge cases, remove zeros before computing LCM
x(~x) = [];
x(isinf(x)) = [];
if isempty(x), M = []; return; end;

[a,b]=rat(x);
v = b(1);
for k = 2:length(b), v=lcm(v,b(k)); end
d = v;

y = round(d*x);         % integers
v = y(1);
for k = 2:length(y), v=lcm(v,y(k)); end
M = v/d;
