function varargout = HDF5lib(functionName, varargin)
%HDF5lib A gateway to the HDF5 MEX library.  
%   This function is deprecated and should not be used.
%

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/01/19 02:55:32 $

warning ( 'MATLAB:H5ML:HDF5lib:deprecated', ...
          'This function is deprecated and may be removed in a future version of MATLAB.');




% We have to keep track of the fact that HDF5lib sometimes returned 1 more
% output value than the user would have asked for through the MATLAB program.
% harness. 
localNargOut = nargout;
if returnsError(functionName)
	localNargOut = localNargOut - 1;
end


if localNargOut > 0
	localVarargout = cell(1,localNargOut);
else
	localVarargout = cell(0);
end

% Reroute to the newer mex-file and set the error status appropriatedly.
err = 0;
try
	if localNargOut == 0
		H5ML.hdf5lib2(functionName,varargin{:});
	else
		[localVarargout{:}] = H5ML.hdf5lib2(functionName,varargin{:});
	end
catch ME %#ok<NASGU>
	err = -1;
end


if nargout == 0
	return
else
	varargout = cell(1,nargout);

	if returnsError(functionName)
		varargout{1} = err;
		[varargout{2:end}] = localVarargout{1:nargout-1};
	else
		[varargout{:}] = localVarargout{:};
	end

end


return




%--------------------------------------------------------------------------
function bool = returnsError(functionName)
%RETURNSERROR this function will return true if the name specified
%   as functionName returns a value of type herr_t

persistent errorDict;

if isempty(errorDict)
    list = {'H5open' 'H5close' 'H5dont_atexit' 'H5garbage_collect'...
        'H5set_free_list_limits' 'H5get_libversion' 'H5check_version'...
        'H5Awrite' 'H5Aread' 'H5Aclose' 'H5Arename' ...
		'H5Aiterate1' 'H5Aiterate' ...
		'H5Adelete'...
        'H5Dclose' 'H5Dget_space_status' 'H5Dread' 'H5Dwrite' 'H5Dextend'...
        'H5Diterate' 'H5Dvlen_reclaim' 'H5Dvlen_get_buf_size' 'H5Dfill'...
        'H5Dset_extent' 'H5Ddebug' 'H5Eset_auto' ...
		'H5Eget_auto1' 'H5Eget_auto' ...
		'H5Eclear1' 'H5Eclear' ...
        'H5Eprint' 'H5Eprint1' 'H5Ewalk' 'H5Ewalk1' 'H5Epush' 'H5Epush1' ...
		'H5Fflush' 'H5Fclose'...
        'H5Fget_vfd_handle' 'H5Fmount' 'H5Funmount' 'H5Fget_filesize'...
        'H5Fget_mdc_config' 'H5Fset_mdc_config' ...
        'H5FDunregister' 'H5FDclose' 'H5FDfree' 'H5FDset_eoa'...
        'H5FDget_vfd_handle' 'H5FDread' 'H5FDwrite' 'H5FDflush' 'H5Gclose'...
        'H5Giterate' 'H5Gget_num_objs' 'H5Gmove2' 'H5Glink2' 'H5Gunlink'...
        'H5Gget_objinfo' 'H5Gget_linkval' 'H5Gset_comment' 'H5Zregister'...
        'H5Zunregister' 'H5Zget_filter_info' ...
		'H5Pregister' 'H5Pregister1' 'H5Pinsert' 'H5Pinsert1'...
        'H5Pset' 'H5Pget_size' 'H5Pget_nprops' 'H5Pget' 'H5Pcopy_prop'...
        'H5Premove' 'H5Punregister' 'H5Pclose_class' 'H5Pclose'...
        'H5Pget_version' 'H5Pset_userblock' 'H5Pget_userblock'...
        'H5Pget_mdc_config' 'H5Pset_mdc_config' ...
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
        'H5Tlock' 'H5Tcommit' 'H5Tcommit1' ...
		'H5Tinsert' 'H5Tpack' 'H5Tenum_insert'...
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

return