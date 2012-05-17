% Callback for uitabledemo
% $Revision: 1.1.10.1 $Date: 2008/02/29 12:45:35 $
% Copyright 2008 The MathWorks, Inc.

function AgeVerificationCallback(o, e)
    if (e.Indices(2) == 2 && ...
        (e.NewData < 0 || e.NewData > 120))
        tableData = get(o, 'data');
        tableData{e.Indices(1), e.Indices(2)} = e.PreviousData;
        set(o, 'data', tableData);
        error('Age value must be between 0 and 120.')
    end
