function evil_fbt_listener(methodName,machineId,varargin)

% Copyright 2004-2009 The MathWorks, Inc.

return;% paranoid check. we dont want this on all the time.

try %#ok<UNRCH>
    switch(methodName)
        case {'load','simsetup','presave','close'}
        %exec_order_listener(methodName,machineId,varargin{:});
    end
catch ME
end

function exec_order_listener(methodName,machineId,varargin) %#ok<DEFNU>


switch(methodName)
    case {'load','simsetup','presave'}
        charts = sf('get',machineId,'machine.charts');
        for i=1:length(charts)
           prevVal = sf('get',charts(i),'chart.userSpecifiedStateTransitionExecutionOrder');
           if(prevVal==0) 
               sf('set',charts(i),'chart.userSpecifiedStateTransitionExecutionOrder',1);
           end
        end
end

    
