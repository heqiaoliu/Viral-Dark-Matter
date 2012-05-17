function validcenterfrequencies = getvalidcenterfrequencies(this)
%GETVALIDCENTERFREQUENCIES   Get the validcenterfrequencies.

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:31 $

b = this.privBandsPerOctave; % BandsPerOctave
G = 10^(3/10);
x = -1000:1350;
if rem(b,2)
    % b odd
    validcenterfrequencies = 1000*(G.^((x-30)/b));
else
    validcenterfrequencies = 1000*(G.^((2*x-59)/(2*b)));
end
validcenterfrequencies(validcenterfrequencies>20000)=[]; % Upper limit 20 kHz
validcenterfrequencies(validcenterfrequencies<20)=[];    % Lower limit 20 Hz

% [EOF]
