function varargout = hdf5(functionName, varargin)
%HDF5 A gateway to the HDF5 MEX library.
%   Users should not call this function directly: it is intended to be
%   called only by the @H5 functions.
%

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/05/14 17:11:12 $

% Check the number of arguments
error(nargchk(1,Inf,nargin,'struct'));
if ~isa(functionName, 'char')
    error('MATLAB:H5ML_hdf5:badarg', 'The first parameter must be a string.');
end

% Handle special cases.
[varargin{:}] = preprocess(functionName, varargin{:});

% Call the function
if returnsError(functionName)
    nOut = nargout;
    [err varargout{1:nOut}] = H5ML.HDF5lib(functionName, varargin{:});
    % Throw errors
    if err<0
        error('MATLAB:H5ML_hdf5:library',... 
            'The HDF5 library encountered an error: %s',...
            h5error() );
    end
else
    % There will always be at least one nargout.
    nOut = max(nargout, 1);
    [varargout{1:nOut}] = H5ML.HDF5lib(functionName, varargin{:});
end

% Postprocessing
[varargout{1:nOut}] = postprocess(functionName, varargin, varargout{:});

end

% Print the error from the HDF5 library
function errString = h5error()
    errString = '';
    H5E.walk('H5E_WALK_UPWARD', @errorIterator);

    % Print the specifics of the HDF5 error iterator.
    function output = errorIterator(n, H5err_struct)
        errString = sprintf('\n"%s"', H5err_struct.desc);
        output = 1;
    end
end

% Preprocess the inputs to the HDF5 library MEX-function.
function varargout = preprocess(functionName, varargin)
% Turn H5ML.ids into doubles when calling the library.
for i=1:length(varargin)
    if isa(varargin{i}, 'H5ML.id')
        h5id = varargin{i}.identifier;
        % Invalidate the identifier if we are closing it.
        if strcmp(functionName, varargin{i}.callback)
            varargin{i}.identifier = -1;
        end
        varargin{i} = h5id;
    end
end

switch(functionName)
    case {'H5Aread' 'H5Awrite' 'H5Dread' 'H5Dwrite'}
        % convert the H5ML_DEFAULT parameter, if present
        [varargout{1:nargout}] = varargin{:};
        if ischar(varargin{2}) && strcmp(varargin{2}, 'H5ML_DEFAULT')
            varargout{2} = H5ML.HDF5lib('H5MLget_mem_datatype', varargin{1});
        end
    case 'H5Fopen'
        % Open a file anywhere on the MATLAB path
        [varargout{1:nargout}] = varargin{:};
        foundFile = which(varargin{1});
        if ~isempty(foundFile)
            varargout{1} = foundFile;
        end
    otherwise
        [varargout{1:nargout}] = varargin{:};
end
end

% Preprocess the outputs from the HDF5 library MEX-function.
function varargout = postprocess(functionName, origArgs, varargin)
[varargout{1:nargout}] = varargin{:};

% Wrap the identifiers
if returnsIdent(functionName)
    if(varargin{1} < 0)
        error('MATLAB:H5ML_hdf5:invalidID',...
            'An invalid HDF5 identifier was returned from the HDF5 library: %s',...
            h5error());
    end
    varargout{1} = wrapID(varargin{1});
end

switch(functionName)
    % Trim the dimensions array to the actual number of dimensions
    case 'H5Sget_simple_extent_dims'
        rank = H5S.get_simple_extent_ndims(origArgs{1});
        if nargout > 1
            varargout{2} = varargout{2}(1:rank);
            if nargout > 2
                varargout{3} = varargout{3}(1:rank);
            end
        end
    case 'H5Sget_select_bounds'
        rank = H5S.get_simple_extent_ndims(origArgs{1});
        if nargout > 0
            varargout{1} = varargout{1}(1:rank);
            if nargout > 1
                varargout{2} = varargout{2}(1:rank);
            end
        end
    case 'H5Tget_array_dims1'
        rank = H5T.get_array_ndims(origArgs{1});
        if nargout > 1
            varargout{2} = varargout{2}(1:rank);
            if nargout > 2
                varargout{3} = varargout{3}(1:rank);
            end
        end
end
end

function output = wrapID(id)
% Wrap the IDs in an H5ML.id class so that they will be closed when
% they go out of scope.
if id < 0
    callback = '';
else
    type = H5I.get_type(id);
    if H5ML.compare_values(type,'H5I_FILE')
        callback = 'H5Fclose';
    elseif H5ML.compare_values(type, 'H5I_GROUP')
        callback = 'H5Gclose';
    elseif H5ML.compare_values(type, 'H5I_DATATYPE')
        callback = 'H5Tclose';
    elseif H5ML.compare_values(type, 'H5I_DATASPACE')
        callback = 'H5Sclose';
    elseif H5ML.compare_values(type, 'H5I_DATASET')
        callback = 'H5Dclose';
    elseif H5ML.compare_values(type, 'H5I_ATTR')
        callback = 'H5Aclose';
    elseif H5ML.compare_values(type, 'H5I_GENPROP_LST')
        callback = 'H5Pclose';
    elseif H5ML.compare_values(type, 'H5I_GENPROP_CLS')
        callback = 'H5Pclose_class';
    elseif H5ML.compare_values(type, 'H5I_VFL')
        callback = 'H5Pclose';
    else
        callback = '';
    end
end
output = H5ML.id(id, callback);
end

function bool = returnsError(functionName)
%RETURNSERROR this function will return true if the name specified
%   as functionName returns a value of type herr_t

persistent errorDict;

if isempty(errorDict)
    list = {'H5open' 'H5close' 'H5dont_atexit' 'H5garbage_collect'...
        'H5set_free_list_limits' 'H5get_libversion' 'H5check_version'...
        'H5Awrite' 'H5Aread' 'H5Aclose' 'H5Arename' 'H5Aiterate1' 'H5Adelete'...
        'H5Dclose' 'H5Dget_space_status' 'H5Dread' 'H5Dwrite' 'H5Dextend'...
        'H5Diterate' 'H5Dvlen_reclaim' 'H5Dvlen_get_buf_size' 'H5Dfill'...
        'H5Dset_extent' 'H5Ddebug' 'H5Eset_auto' 'H5Eget_auto1' 'H5Eclear1'...
        'H5Eprint1' 'H5Ewalk1' 'H5Epush1' 'H5Fflush' 'H5Fclose'...
        'H5Fget_vfd_handle' 'H5Fmount' 'H5Funmount' 'H5Fget_filesize'...
        'H5Fget_mdc_config', 'H5Fset_mdc_config', ...
        'H5FDunregister' 'H5FDclose' 'H5FDfree' 'H5FDset_eoa'...
        'H5FDget_vfd_handle' 'H5FDread' 'H5FDwrite' 'H5FDflush' 'H5Gclose'...
        'H5Giterate' 'H5Gget_num_objs' 'H5Gmove2' 'H5Glink2' 'H5Gunlink'...
        'H5Gget_objinfo' 'H5Gget_linkval' 'H5Gset_comment' 'H5Zregister'...
        'H5Zunregister' 'H5Zget_filter_info' 'H5Pregister1' 'H5Pinsert1'...
        'H5Pset' 'H5Pget_size' 'H5Pget_nprops' 'H5Pget' 'H5Pcopy_prop'...
        'H5Premove' 'H5Punregister' 'H5Pclose_class' 'H5Pclose'...
        'H5Pget_version' 'H5Pset_userblock' 'H5Pget_userblock'...
        'H5Pget_mdc_config', 'H5Pset_mdc_config', ...
        'H5Pset_alignment' 'H5Pget_alignment' 'H5Pset_sizes' 'H5Pget_sizes'...
        'H5Pset_sym_k' 'H5Pget_sym_k' 'H5Pset_istore_k' 'H5Pget_istore_k'...
        'H5Pset_layout' 'H5Pset_chunk' 'H5Pset_external' 'H5Pget_external'...
        'H5Pset_driver' 'H5Pset_family_offset' 'H5Pget_family_offset'...
        'H5Pset_multi_type' 'H5Pget_multi_type' 'H5Pset_buffer'...
        'H5Pset_preserve' 'H5Pmodify_filter' 'H5Pset_filter'...
        'H5Pset_deflate' 'H5Pset_szip' 'H5Pset_shuffle' 'H5Pset_fletcher32'...
        'H5Pset_edc_check' 'H5Pset_filter_callback' 'H5Pset_cache'...
        'H5Pget_cache' 'H5Pset_btree_ratios' 'H5Pget_btree_ratios'...
        'H5Pset_fill_value' 'H5Pget_fill_value' 'H5Pfill_value_defined'...
        'H5Pset_alloc_time' 'H5Pget_alloc_time' 'H5Pset_fill_time'...
        'H5Pget_fill_time' 'H5Pset_gc_references' 'H5Pget_gc_references'...
        'H5Pset_fclose_degree' 'H5Pget_fclose_degree'...
        'H5Pset_vlen_mem_manager' 'H5Pget_vlen_mem_manager'...
        'H5Pset_meta_block_size' 'H5Pget_meta_block_size'...
        'H5Pset_sieve_buf_size' 'H5Pget_sieve_buf_size'...
        'H5Pset_hyper_vector_size' 'H5Pget_hyper_vector_size'...
        'H5Pset_small_data_block_size' 'H5Pget_small_data_block_size'...
        'H5Premove_filter' 'H5Rcreate' 'H5Sset_extent_simple' 'H5Sclose'...
        'H5Sset_space' 'H5Sselect_hyperslab' 'H5Sselect_elements'...
        'H5Sset_extent_none' 'H5Sextent_copy' 'H5Sselect_all'...
        'H5Sselect_none' 'H5Soffset_simple' 'H5Sget_select_hyper_blocklist'...
        'H5Sget_select_elem_pointlist' 'H5Sget_select_bounds' 'H5Tclose'...
        'H5Tlock' 'H5Tcommit1' 'H5Tinsert' 'H5Tpack' 'H5Tenum_insert'...
        'H5Tenum_nameof' 'H5Tenum_valueof' 'H5Tset_tag' 'H5Tget_pad'...
        'H5Tget_fields' 'H5Tget_member_value' 'H5Tset_size' 'H5Tset_order'...
        'H5Tset_precision' 'H5Tset_offset' 'H5Tset_pad' 'H5Tset_sign'...
        'H5Tset_fields' 'H5Tset_ebias' 'H5Tset_norm' 'H5Tset_inpad'...
        'H5Tset_cset' 'H5Tset_strpad' 'H5Tregister' 'H5Tunregister'...
        'H5Tconvert' 'H5Tset_overflow' 'H5Pset_fapl_core' 'H5Pget_fapl_core'...
        'H5Pset_fapl_family' 'H5Pget_fapl_family' 'H5Pset_fapl_log'...
        'H5Pset_fapl_multi' 'H5Pget_fapl_multi' 'H5Pset_dxpl_multi'...
        'H5Pget_dxpl_multi' 'H5Pset_fapl_split' 'H5Pset_fapl_sec2'...
        'H5Pset_fapl_stdio' 'H5Pset_fapl_stream' 'H5Pget_fapl_stream' };
    
    for func = list
        errorDict.(func{1}) = true;
    end
end

bool = isfield(errorDict,functionName);

end

function bool = returnsIdent(functionName)
%RETURNSIDENT this function will return true if the name specified
%   as functionName returns a value of type hid_t

persistent identDict;

if isempty(identDict)

    % The HDF5 functions that return identifiers
    list = {'H5Iget_file_id' 'H5Acreate1' 'H5Aopen_name' 'H5Aopen_idx'...
        'H5Aget_space' 'H5Aget_type' 'H5Dcreate1' 'H5Dopen1' 'H5Dget_space'...
        'H5Dget_type' 'H5Dget_create_plist' 'H5Fcreate' 'H5Fopen'...
        'H5Freopen' 'H5Fget_create_plist' 'H5Fget_access_plist'...
        'H5FDregister' 'H5Gcreate1' 'H5Gopen1' 'H5Pcreate_class' 'H5Pcreate'...
        'H5Pget_class' 'H5Pget_class_parent' 'H5Pcopy' 'H5Pget_driver'...
        'H5Rdereference' 'H5Rget_region' 'H5Screate' 'H5Screate_simple'...
        'H5Scopy' 'H5Topen1' 'H5Tcreate' 'H5Tcopy' 'H5Tenum_create'...
        'H5Tvlen_create' 'H5Tarray_create' 'H5Tarray_create1', 'H5Tget_super'...
        'H5Tget_member_type' 'H5Tget_native_type' 'H5FD_core_init'...
        'H5FD_family_init' 'H5FD_log_init' 'H5FD_multi_init'...
        'H5FD_sec2_init' 'H5FD_stdio_init' 'H5FD_stream_init', ...
        'H5MLget_mem_datatype' };

    for func = list
        identDict.(func{1}) = true;
    end
end


bool = isfield(identDict,functionName);
end
