% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2006/03/10 01:56:14 $

function rtwdemorequiredsp(model) 

    errmsg = 'You must install the Signal Processing Blockset to view this demonstration.';
    if isempty(ver('dspblks'))
        errordlg(errmsg)
    else 
        eval(model)
    end


