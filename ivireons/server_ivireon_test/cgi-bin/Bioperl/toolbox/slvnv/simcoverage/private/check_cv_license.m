function status = check_cv_license
%CHECK_CV_LICENSE Check if the coverage tool is licensed

% Bill Aldrich
% Copyright 1990-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/12/28 04:48:12 $
try
    status = ~isempty(which('cvsim')) && cv('License','basic');
catch MEx %#ok<NASGU>
    status = 0;
end




