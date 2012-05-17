function cvdata = subsasgn( cvdata, property, value)


%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 22:59:49 $

error('SLVNV:simcoverage:subsasgn:CvdataReadOnly','Properties of cvdata objects are read only.');