function [status opdata_out]  = H5Lvisit_by_name(loc_id,group_name,index_type,order,iterFunc,opdata_in,lapl_id)
%H5L.visit_by_name  Recursively iterate through links in group.
%   [status opdata_out] = H5L.visit_by_name(loc_id,group_name,index_type,order,iterFunc,opdata_in,lapl_id) 
%   recursively iterates though all links in and below a group to 
%   perform a common function whose function handle is iterFunc. The 
%   starting point of the iteration is specified by the pairing of a 
%   location id and a relative group name.  A link access property list, 
%   lapl_id, may affect the outcome depending upon the type of link 
%   being traversed.
%
%   index_type and order establish the iteration.  index_type specifies
%   the index to be used. If the links have not been indexed by the index
%   type, they will first be sorted by that index then the iteration will
%   begin. If the links have been so indexed, the sorting step will be
%   unnecessary, so the iteration may begin more quickly. Valid values
%   include the following:
%
%      'H5_INDEX_NAME'      Alpha-numeric index on name 
%      'H5_INDEX_CRT_ORDER' Index on creation order   
%
%   Note that the index type passed in index_type is a best effort
%   setting. If the application passes in a value indicating iteration
%   in creation order and a group is encountered that was not tracked in
%   creation order, that group will be iterated over in alpha-numeric
%   order by name, or name order. (Name order is the native order used
%   by the HDF5 Library and is always available.)
%
%   order specifies the order in which objects are to be inspected along
%   the index specified in index_type. Valid values include the following:
%
%      'H5_ITER_INC'    Increasing order 
%      'H5_ITER_DEC'    Decreasing order 
%      'H5_ITER_NATIVE' Fastest available order   
%
%   The callback function iterFunc must have the following signature: 
%
%      function [status opdata_out] = iterFunc(group_id,name,opdata_in)
%
%   opdata_in is a user-defined value or structure and is passed to the 
%   first step of the iteration in the iterFunc opdata_in parameter. The 
%   opdata_out of an iteration step forms the opdata_in for the next 
%   iteration step. The final opdata_out at the end of the iteration is
%   then returned to the caller as opdata_out.
%
%   status value returned by iterFunc is interpreted as follows:
%
%      zero     - Continues with the iteration or returns zero status value
%                 to the caller if all members have been processed.   
%      positive - Stops the iteration and returns the positive status value
%                 to the caller.
%      negative - Stops the iteration and throws an error indicating
%                 failure.
%
%   See also H5L.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:15 $

if ~isa(iterFunc, 'function_handle')
    error('MATLAB:H5L:visit_by_name:badInputFunction', ...
          'Specified iterFunc argument is not a function handle');
end
f = functions(iterFunc);
if isempty(f.file)
    error('MATLAB:H5L:visit_by_name:badInputFunction', ...
          'Specified iterFunc argument is not a valid function');
end
[id, lid, opd_in] = H5ML.unwrap_ids(loc_id, lapl_id, opdata_in);
[status opdata_out] = H5ML.hdf5lib2('H5Lvisit_by_name', id,group_name,index_type,order,iterFunc,opd_in,lid);            
