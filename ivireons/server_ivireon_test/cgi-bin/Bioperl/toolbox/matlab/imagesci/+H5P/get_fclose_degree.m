function degree = get_fclose_degree(fapl_id)
%H5P.get_fclose_degree  Return file close degree.
%   degree = H5P.get_fclose_degree(fapl_id) returns the current setting of the
%   file close degree property fc_degree in the file access property list 
%   specified by fapl_id. Possible return values are: H5F_CLOSE_DEFAULT,
%   H5F_CLOSE_WEAK, H5F_CLOSE_SEMI, or H5F_CLOSE_STRONG.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       degree = H5P.get_fclose_degree(fapl);
%       switch(degree)
%           case H5ML.get_constant_value('H5F_CLOSE_DEFAULT')
%               fprintf('file close degree is default\n');
%           case H5ML.get_constant_value('H5F_CLOSE_WEAK')
%               fprintf('file close degree is weak\n');
%           case H5ML.get_constant_value('H5F_CLOSE_SEMI')
%               fprintf('close degree is semi\n');
%           case H5ML.get_constant_value('H5F_CLOSE_STRONG')
%               fprintf('close degree is strong\n');
%       end
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_fclose_degree.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:05 $

id = H5ML.unwrap_ids(fapl_id);
degree = H5ML.hdf5lib2('H5Pget_fclose_degree', id);            
