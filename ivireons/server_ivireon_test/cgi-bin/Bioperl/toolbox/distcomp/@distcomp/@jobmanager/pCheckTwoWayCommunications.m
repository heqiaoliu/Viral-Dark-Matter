function varargout = pCheckTwoWayCommunications(jobmanagers)
; %#ok Undocumented

% Copyright 2005-2010 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.test.TwoWayCommTester;

ok = false( size( jobmanagers ) );
if nargout==1
    testFcn = @(obj)TwoWayCommTester.testTwoWayDataStoreCommunication(obj);
else
    testFcn = @(obj)iTestAndWarn(obj);
end

for i = 1:numel(jobmanagers)
    % Recover the JobManagerProxy object
    proxyObject = jobmanagers(i).ProxyObject;    
    % Conduct the two-way communication test 
    ok(i) = testFcn( proxyObject );
end

if nargout==1
    varargout{1} = ok;
end
end

function ok = iTestAndWarn(obj)
import com.mathworks.toolbox.distcomp.test.TwoWayCommTester;
testResult = TwoWayCommTester.testTwoWayDataStoreCommunicationAndReturnResult(obj);
ok = testResult.isSuccess();
if ~ok && ~isempty(testResult.getErrorMessage())
   warning('distcomp:findresource:LimitedConnectivity', ...
           '%s', char(testResult.getErrorMessage()));
end
end
