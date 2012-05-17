function args = commandLineArgs(this)
%COMMANDLINEARGS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/18 02:14:25 $

signals = get(this, 'Signals');

args = cell(length(signals), 2);
for indx = 1:length(signals)
    args{indx, 1} = [signals(indx).Block.Parent '/' signals(indx).Block.Name];
    args{indx, 2} = signals(indx).PortIndex;
end

args = {args};


% [EOF]
