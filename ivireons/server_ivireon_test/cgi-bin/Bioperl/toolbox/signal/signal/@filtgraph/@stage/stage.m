function Stg = stage(NList, PrevIPorts, PrevOPorts, ...
    NextIPorts,NextOPorts, mainparams, params, nStgs)
%STG Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:50 $

error(nargchk(0,8,nargin,'struct'));

Stg = filtgraph.stage;

if nargin > 0
    Stg.nodeList = NList;
end

if nargin > 1
    Stg.prevInputPorts = PrevIPorts;
end

if nargin > 2
    Stg.prevOutputPorts = PrevOPorts;
end

if nargin > 3
    Stg.nextInputPorts = NextIPorts;
end

if nargin > 4
    Stg.nextOutputPorts = NextOPorts;
end

if nargin > 5
    if length(mainparams)> length(Stg.nodeList)
        error(generatemsgid('InternalError'),'Parameter list overflow.');
    end

    if length(mainparams)< length(Stg.nodeList)
        error(generatemsgid('InternalError'),'Parameter list underflow.');
    end

    for I = 1:length(mainparams)
        if mainparams(I).index > length(Stg.nodeList)
            error(generatemsgid('InternalError'),'Parameter list overindexed.');
        end
    end

    Stg.mainParamList = mainparams;
end

if nargin > 6
    if length(params)> length(Stg.nodeList)
        error(generatemsgid('InternalError'),'Parameter list overflow.');
    end

    for I = 1:length(params)
        if params(I).index > length(Stg.nodeList)
            error(generatemsgid('InternalError'),'Parameter list overindexed.');
        end
    end

    Stg.qparamList = params;
end

if nargin > 7
    Stg.numStages = nStgs;
end

Stg.numNodes = length(Stg.nodeList);
