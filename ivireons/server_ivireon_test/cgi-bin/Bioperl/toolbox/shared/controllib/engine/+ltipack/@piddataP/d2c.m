function PIDc = d2c(PIDd,options)
%D2C  Conversion of discrete time PID to continuous time.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:27 $

method = options.Method(1);
try
    if any(strncmp(method,{'m','t'},1))
        % Use @zpkdata algorithm
        PIDc = pid(d2c(zpk(PIDd),options));
    else
        PIDc = pid(d2c(ss(PIDd),options));
    end
catch ME
    throw(ME)
end
