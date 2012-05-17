function val = pGetState(obj, val)
; %#ok Undocumented
%PGETSTATE private function to get paused state from java object
%
%  VAL = PGETSTATE(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision $    $Date: 2008/06/24 17:01:28 $ 

persistent Values Strings
if isempty(Values)
    types = findtype('distcomp.jobmanagerexecutionstate');
    Values = types.Values;
    Strings = types.Strings;
end

try
    state = obj.ProxyObject.getState;
    val = Strings{state == Values};
catch err
    [isJavaError, exceptionType] = isJavaException(err);
    if isJavaError
        switch exceptionType
            case 'java.rmi.RemoteException'
                val = Strings{-2 == Values};  % unavailable
            case 'java.rmi.NoSuchObjectException'
                val = Strings{-2 == Values}; % unavaialble                
        end
    end
end
