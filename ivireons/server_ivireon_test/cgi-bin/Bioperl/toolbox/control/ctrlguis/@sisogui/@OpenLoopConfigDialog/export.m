function export(this)
%export Exports the loop configuration to loopdata

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:53 $

L = this.FeedbackLoops;

updateFlag = false;

for ct = 1:length(L)
    if ~isequal(this.LoopConfig(ct), L(ct).LoopConfig);
        setLoopConfig(L(ct),this.LoopData,this.LoopConfig(ct));
        updateFlag = true;
    end
end

if updateFlag
    % Notify peers configuraton has changed so dependencies can be updated
    this.LoopData.send('Configchanged')
    % Notify peers of data change
    this.LoopData.dataevent('all')
end

