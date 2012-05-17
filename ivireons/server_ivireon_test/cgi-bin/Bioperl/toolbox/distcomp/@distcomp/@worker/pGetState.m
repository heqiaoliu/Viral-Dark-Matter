function val = pGetState(obj, val)
; %#ok Undocumented
%PGETSTATE private function to get running state from java object
%
%  VAL = PGETSTATE(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/06/24 17:01:59 $ 

persistent Values Strings
if isempty(Values)
    types = findtype('distcomp.workerexecutionstate');
    Values = types.Values;
    Strings = types.Strings;
end

proxyWorker = obj.ProxyObject;

try
    % just test and see if the worker is responding
    state = proxyWorker.getState;
    
    % if a remote exception isn't thrown, then it is responding
    val = Strings{state == Values}; % running
catch err
    [isJavaError, exceptionType] = isJavaException(err);
    if isJavaError
        switch exceptionType
            case 'java.rmi.RemoteException'
                val = Strings{-2 == Values}; % unavailable
            case 'java.rmi.NoSuchObjectException'
                val = Strings{-2 == Values}; % unavaialble                
        end
    end
end
