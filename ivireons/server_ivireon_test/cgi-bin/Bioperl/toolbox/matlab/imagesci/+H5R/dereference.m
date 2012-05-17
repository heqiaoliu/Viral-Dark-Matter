function output = dereference(dataset, ref_type, ref)
%H5R.dereference  Open object specified by reference.
%   output = H5R.dereference(dataset, ref_type, ref) returns an identifier
%   to the object specified by ref in the dataset specified by dataset.
%
%   Example:  
%       plist = 'H5P_DEFAULT';
%       space = 'H5S_ALL';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist);
%       dset_id = H5D.open(fid,'/g3/reference');
%       ref_data = H5D.read(dset_id,'H5T_STD_REF_OBJ',space,space,plist);
%       deref_dset_id = H5R.dereference(dset_id,'H5R_OBJECT',ref_data(:,1));
%       H5D.close(dset_id);
%       H5D.close(deref_dset_id);
%       H5F.close(fid);
%
%   See also H5R, H5I.get_name.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:40:15 $

[id] = H5ML.unwrap_ids(dataset);
output = H5ML.hdf5lib2('H5Rdereference', id, ref_type, ref);
type = H5I.get_type(output);
if H5ML.compare_values(type,'H5I_FILE')
    callback = 'H5Fclose';
elseif H5ML.compare_values(type, 'H5I_GROUP')
    callback = 'H5Gclose';
elseif H5ML.compare_values(type, 'H5I_DATASET')
    callback = 'H5Dclose';
elseif H5ML.compare_values(type, 'H5I_ATTR')
    callback = 'H5Aclose';
elseif H5ML.compare_values(type, 'H5I_DATATYPE')
    callback = 'H5Tclose';
elseif H5ML.compare_values(type, 'H5I_DATASPACE')
    callback = 'H5Sclose';
elseif H5ML.compare_values(type, 'H5I_GENPROP_LST')
    callback = 'H5Pclose';
elseif H5ML.compare_values(type, 'H5I_GENPROP_CLS')
    callback = 'H5Pclose_class';
elseif H5ML.compare_values(type, 'H5I_VFL')
    callback = 'H5Pclose';
else
    callback = '';
end
output = H5ML.id(output, callback);
end
