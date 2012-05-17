function parse_this(parseObjectId,targetName,showNags)
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.4 $  $Date: 2005/06/24 11:30:45 $
if(nargin<2)
    targetName = 'sfun';
end
if(nargin<3)
    showNags = 'yes';
end
if(~isempty(sf('get',parseObjectId,'machine.id')))
    machineId = parseObjectId;
    chartId = [];
elseif(~isempty(sf('get',parseObjectId,'chart.id')))
    machineId = sf('get',parseObjectId,'chart.machine');
    chartId = parseObjectId;
end
autobuild_kernel(machineId,targetName,'parse','yes',showNags,chartId);


