%NETCDF Summary of MATLAB NETCDF capabilities.
%   MATLAB provides low-level access to netCDF files via direct access to 
%   more than 40 functions in the netCDF library.  To use these MATLAB 
%   functions, you must be familiar with the netCDF C interface.  The 
%   "NetCDF C Interface Guide" for version 4.0.1 may be consulted at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_4_0_1/>.
%
%   In most cases, the syntax of the MATLAB function is similar to the 
%   syntax of the netCDF library function.  The functions are implemented 
%   as a package called "netcdf".  To use these functions, one needs to 
%   prefix the function name with package name "netcdf", i.e. 
%
%      ncid = netcdf.open ( ncfile, mode );
%
%   The following table lists all the netCDF library functions supported by 
%   the netCDF package.
%
%      File Functions
%      --------------
%      abort            - Revert recent netCDF file definitions.
%      close            - Close netCDF file.
%      create           - Create new netCDF file.
%      endDef           - End netCDF file define mode.
%      inq              - Return information about netCDF file.
%      inqFormat        - Return netCDF file format.
%      inqLibVers       - Return netCDF library version information.
%      open             - Open netCDF file.
%      reDef            - Set netCDF file into define mode.
%      setDefaultFormat - Change default netCDF file format.
%      setFill          - Set netCDF fill mode.
%      sync             - Synchronize netCDF dataset to disk.  
%      
%      Dimension Functions
%      -------------------
%      defDim           - Create netCDF dimension.
%      inqDim           - Return netCDF dimension name and length.
%      inqDimID         - Return dimension ID.
%      inqUnlimDims     - Return unlimited dimensions visible in group.
%      renameDim        - Change name of netCDF dimension.
%      
%      Group Functions
%      ---------------
%      defGrp           - Create group.
%      inqNcid          - Return ID of named group.
%      inqGrps          - Return IDs of child groups.
%      inqVarIDs        - Return all variable IDs for group.
%      inqDimIDs        - Return all dimension IDs visible from group.
%      inqGrpName       - Return relative name of group.
%      inqGrpNameFull   - Return complete name of group.
%      inqGrpParent     - Find ID of parent group.
%
%      Variable Functions
%      ------------------
%      defVar           - Create netCDF variable.
%      defVarChunking   - Set chunking layout.
%      defVarDeflate    - Set variable compression.
%      defVarFill       - Set fill parameters for variable.
%      defVarFletcher32 - Set checksum mode.
%      getVar           - Return data from netCDF variable.
%      inqVar           - Return information about variable.
%      inqVarChunking   - Return chunking layout for variable.
%      inqVarDeflate    - Return variable compression information.
%      inqVarFill       - Return fill value setting for variable.
%      inqVarFletcher32 - Return checksum settings.
%      inqVarID         - Return ID associated with variable name.
%      putVar           - Write data to netCDF variable.
%      renameVar        - Change name of netCDF variable.
%      
%      Attribute Functions
%      -------------------
%      copyAtt          - Copy attribute to new location.
%      delAtt           - Delete netCDF attribute.
%      getAtt           - Return netCDF attribute.
%      inqAtt           - Return information about netCDF attribute.
%      inqAttID         - Return ID of netCDF attribute.
%      inqAttName       - Return name of netCDF attribute.
%      putAtt           - Write netCDF attribute.
%      renameAtt        - Change name of attribute.
%
% 
%   The following functions have no equivalents in the netCDF library.
%
%      getConstantNames - Return list of constants known to netCDF library.
%      getConstant      - Return numeric value of named constant
% 
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
 
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/15 15:25:00 $
