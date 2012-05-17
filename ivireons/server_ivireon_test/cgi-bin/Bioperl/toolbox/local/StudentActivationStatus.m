function StudentActivationStatus

%   Copyright 2005-2007 The MathWorks, Inc. 

if isstudent 
    feature('launch_activation', 'forcecheck');
else
    disp('This function is only available in Student Version.');
end

