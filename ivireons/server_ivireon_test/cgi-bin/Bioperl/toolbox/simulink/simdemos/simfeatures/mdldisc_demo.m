function mdldisc_demo(demofilename)
% MDLDISC_DEMO The Simulink Model Discretizer demo.
%
%   MDLDISC_DEMO is used solely by the Simulink Model Discretizer demos.  
%   It provides an interface from which you can run a demo as well as view
%   information about it.
%
%   This function is not intended for use other than by Simulink Model
%   Discretizer demos. You also need Control toolbox license to run this
%   demo.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ %Date%

if hasControlToolbox
    addpath ([matlabroot '/toolbox/simulink/simdemos/simfeatures/html']);
    web(['file:///' which(demofilename)]);
    rmpath ([matlabroot '/toolbox/simulink/simdemos/simfeatures/html']);
end


% end function mdldisc_demo

%===============================================================================
% hasControlToolbox
% Check if Control Toolbox is available
%===============================================================================
%
function ret = hasControlToolbox

try
    tf(1, [1 1]);
    ret = 1;
catch %#ok<CTCH>
    ret = 0;
end

%end function hasControlToolbox

%[EOF] mdldisc_demo
