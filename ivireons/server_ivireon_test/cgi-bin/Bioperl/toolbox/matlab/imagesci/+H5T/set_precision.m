function H5Tset_precision(type_id, prec)
%H5T.set_precision  Set precision of atomic datatype.
%   H5T.set_precision(type_id, prec) sets the precision of an atomic datatype.
%   type_id is a datatype identifier. prec specifies the number of bits of
%   precision for the datatype.
%
%   See also H5T.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:52 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tset_precision',id, prec); 
