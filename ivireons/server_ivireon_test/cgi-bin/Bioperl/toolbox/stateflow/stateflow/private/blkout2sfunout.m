function sfunOutPort = blkout2sfunout(varargin)

% BLKOUT2SFUNOUT - Maps stateflow ports to simulink ports.


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2007/09/21 19:14:55 $


if ~isa(varargin{1}, 'double')
  error('Stateflow:UnexpectedError','First argument MUST be a Numeric SL Handle');
end

if ~isa(varargin{2}, 'double')
  error('Stateflow:UnexpectedError','Second argument MUST be a numeric Port Number');
end

if (nargin > 2)
    error('Stateflow:UnexpectedError','Too many Input Arguments');
end

if (nargin < 2)
    error('Stateflow:UnexpectedError','Too few Input Arguments');
end


blockH=varargin{1};
portNumber=varargin{2};

chart = sf('Private','block2chart',blockH);


chartData = sf('find',sf('DataOf',chart),'data.scope','OUTPUT_DATA');
chartEvents = sf('find',sf('EventsOf',chart),'event.scope','OUTPUT_EVENT');


allPorts = [chartData,chartEvents];


if(portNumber>length(allPorts))
    blkName=get_param(blockH,'Name');
    error('Stateflow:UnexpectedError','%s',['PortNumber does not exist for block: ',blkName,'.']);
end


portObject = allPorts(portNumber);


if(~isempty(sf('find',portObject,'event.trigger','FUNCTION_CALL_EVENT')))
    sfunOutPort = 1;
elseif(~isempty(sf('get',portObject,'event.id')))
    triggerEvents = sf('find',chartEvents,'~event.trigger','FUNCTION_CALL_EVENT');
    indexInTriggerEvents = find(portObject==triggerEvents);
    sfunOutPort = 1+ length(chartData)+indexInTriggerEvents;
else
    indexInData = find(portObject==chartData);
    sfunOutPort = 1+indexInData;
end
