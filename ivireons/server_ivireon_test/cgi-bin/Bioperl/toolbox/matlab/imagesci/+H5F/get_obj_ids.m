function [num_obj_ids, obj_id_list] = get_obj_ids(file_id, types, max_objs)
%H5F.get_obj_ids  Return list of open HDF5 file objects.
%   [num_obj_ids obj_id_list] = H5F.get_obj_ids(file_id, types, max_objs) 
%   returns a list of all open identifiers for HDF5 objects of the type 
%   specified by types in the file specified by file_id. max_objs specifies
%   the maximum number of object identifiers to return. num_obj_ids is the 
%   total number of objects in the list.  types may be given as one of the 
%   following strings:
%
%       'H5F_OBJ_FILE'     
%       'H5F_OBJ_DATASET'  
%       'H5F_OBJ_GROUP'    
%       'H5F_OBJ_DATATYPE' 
%       'H5F_OBJ_ATTR'     
%       'H5F_OBJ_ALL'      
%       'H5F_OBJ_LOCAL'    
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid1 = H5G.open(fid,'/g1');
%       gid2 = H5G.open(fid,'/g2');
%       gid3 = H5G.open(fid,'/g3');
%       gid4 = H5G.open(fid,'/g4');
%       [num_obj_ids,objs] = H5F.get_obj_ids(fid,'H5F_OBJ_GROUP',3);
%       H5G.close(gid1);
%       H5G.close(gid2);
%       H5G.close(gid3);
%       H5G.close(gid4);
%       H5F.close(fid);
%
%   See also H5F, H5F.get_obj_count.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5.2.1 $ $Date: 2010/07/23 15:40:03 $

id = H5ML.unwrap_ids(file_id);
[num_obj_ids, raw_obj_id_list] = H5ML.hdf5lib2('H5Fget_obj_ids', id, types, max_objs);            
for j = 1:numel(raw_obj_id_list);
    type = H5I.get_type(raw_obj_id_list(j));
    switch(type)
        case H5ML.get_constant_value('H5I_FILE')
            obj_id_list(j) = H5ML.id(raw_obj_id_list(j),'H5Fclose');
        case H5ML.get_constant_value('H5I_DATASET')
            obj_id_list(j) = H5ML.id(raw_obj_id_list(j),'H5Dclose');
        case H5ML.get_constant_value('H5I_GROUP')
            obj_id_list(j) = H5ML.id(raw_obj_id_list(j),'H5Gclose');
        case H5ML.get_constant_value('H5I_DATATYPE')
            obj_id_list(j) = H5ML.id(raw_obj_id_list(j),'H5Tclose');
        case H5ML.get_constant_value('H5I_ATTR')
            obj_id_list(j) = H5ML.id(raw_obj_id_list(j),'H5Aclose');
        otherwise
            error('MATLAB:H5Fget_obj_ids:unrecognizedType', ...
                  'Unrecognized object type: %d.', type);
    end

    % Increase the reference count, otherwise we risk closing all IDs when
    % the calling function goes out of scope.
    H5I.inc_ref(obj_id_list(j));

end

