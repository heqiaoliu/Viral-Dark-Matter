function metadata = dicom_prep_GeneralStudy(metadata)
%DICOM_PREP_DICOM_PREP_GENERALSTUDY  Fill values for General Study module.
%
%   See PS 3.3 Sec. C.7.2.1

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:31:23 $

name = dicom_name_lookup('0020', '000D');
if (~isfield(metadata, name))
    metadata.(name) = dicomuid;
end
