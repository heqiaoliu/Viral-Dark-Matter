function errStr = forceModelWritable(model)
%Sldv.forceModelWritable - Makes the models file writable or returns error string

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:41:35 $

    errStr = '';
    mdlfile = get_param(model,'filename');
    status = fileattrib(mdlfile,'+w');
    if ~status
        errStr = sprintf('Unable to update mdl file ''%s''',mdlfile);
    end
end
