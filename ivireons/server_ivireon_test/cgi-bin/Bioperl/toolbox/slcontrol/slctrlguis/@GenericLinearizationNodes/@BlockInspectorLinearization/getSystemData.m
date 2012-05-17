function sys = getSystemData(this)
% Method to store the blocks linearization indices

%   Author(s): John Glass
%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2009/03/31 00:22:48 $

if ~any(this.SampleTimes) || isempty(this.SampleTimes)
    sys = ss(this.A,this.B,this.C,this.D);
else
    sys = ss(this.A,this.B,this.C,this.D,this.SampleTimes(1));
end