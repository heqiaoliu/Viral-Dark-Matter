function output = get_member_class(type_id, membno)
%H5T.get_member_class  Return datatype class for compound datatype member.
%   output = H5T.get_member_class(type_id, membno) returns the datatype class
%   of the compound datatype member specified by membno. type_id is the 
%   datatype identifier of a compound object.
%
%   Example:
%      fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%      dset_id = H5D.open(fid,'/g3/compound');
%      type_id = H5D.get_type(dset_id);
%      member_name = H5T.get_member_name(type_id,0);
%      member_class = H5T.get_member_class(type_id,0);
%
%   See also H5T, H5T.get_member_name.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:20 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_member_class',id, membno); 
