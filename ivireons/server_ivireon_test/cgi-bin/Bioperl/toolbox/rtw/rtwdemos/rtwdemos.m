function rtwdemos()
% RTWDEMOS - Launch Real-Time Workshop Demos
    
% Copyright 1994-2007 The MathWorks, Inc.

    try
        demo('Simulink','Real-Time Workshop')
    catch
        error(lasterr)
    end
    