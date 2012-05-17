function funTsStr = util_double2str(funTs)

%   Copyright 2008-2010 The MathWorks, Inc.

    % In simulink sample times are set with 17 digit accuracy. When we
    % generate the str for the sample time, we should have that many. 
    funTsStr = sprintf('%.17g',funTs);
end