% Supported file formats.
%
% NOTE: You can import any of these file formats with the Import Wizard or
%       the IMPORTDATA function, except netCDF, H5, Motion JPEG 2000, and
%       platform-specific video. The IMPORTDATA function cannot read HDF
%       files.
%
% NOTE: '.' indicates that no existing high-level functions export the 
%       given data format.
%
%   Format                                    Import    Export
%   ------                                    --------  --------
%   MAT  - MATLAB workspace                   load      save
%   DAQ  - Data Acquisition Toolbox           daqread   .
%
%  Text formats 
%   any  - White-space delimited numbers      load      save -ascii
%   any  - Delimited numbers                  dlmread   dlmwrite
%   any  - Any above text format, or          textscan  .
%          a mix of strings and numbers
%   XML  - Extended Markup Language           xmlread   xmlwrite
%
%  Spreadsheet formats
%   XLS  - Excel worksheet                    xlsread   xlswrite
%          XLSX, XLSB, XLSM require Excel 2007 for Windows
%
%  Scientific data formats
%   CDF  - Common Data Format                 cdfread   cdfwrite
%                                             cdflib    cdflib
%   FITS - Flexible Image Transport System    fitsread  .
%   HDF  - Hierarchical Data Format v.4       hdfread   .
%   H5   - Hierarchical Data Format v.5       hdf5read  hdf5write
%   NC   - network Common Data Form v.3       netcdf    netcdf
%
%  Video formats (All Platforms)
%   AVI  - Audio Video Interleave             mmreader  avifile
%   MJ2  - Motion JPEG 2000                   mmreader  .
%
%  Video formats (Windows and Mac)
%   MPEG - Motion Picture Experts Group,      mmreader  .
%          phases 1 and 2 (Includes MPG)      
%
%  Video formats (Windows Only)
%   WMV  - Windows Media Video                mmreader  .
%   ASF  - Windows Media Video                mmreader  .
%   ASX  - Windows Media Video                mmreader  .
%   any  - formats supported by DirectShow    mmreader  .
%  
%  Video formats (Mac Only)
%   MOV  - QuickTime Movie                    mmreader  .
%   MP4  - MPEG-4 Video (Includes M4V)        mmreader  .
%   3GP  - 3GPP Mobile Video                  mmreader  .
%   3G2  - 3GPP2 Mobile Video                 mmreader  .
%   DV   - Digital Video Stream               mmreader  .
%   any  - formats supported by QuickTime     mmreader  .
%
%  Video formats (Linux Only)
%   any  - formats supported by GStreamer     mmreader  .
%          plug-ins on your system
%
%  Image formats
%   BMP  - Windows Bitmap                     imread    imwrite
%   CUR  - Windows Cursor resources           imread    .
%   FITS - Flexible Image Transport System    imread	.
%          Includes FTS
%   GIF  - Graphics Interchange Format        imread    imwrite
%   HDF  - Hierarchical Data Format           imread    imwrite
%   ICO  - Icon image                         imread    .
%   JPEG - Joint Photographic Experts Group   imread    imwrite
%          Includes JPG
%   JP2  - JPEG 2000                          imread    imwrite
%          Includes JPF, JPX, J2C, J2K 
%   PBM  - Portable Bitmap                    imread    imwrite
%   PCX  - Paintbrush                         imread    imwrite
%   PGM  - Portable Graymap                   imread    imwrite
%   PNG  - Portable Network Graphics          imread    imwrite
%   PNM  - Portable Any Map                   imread    imwrite
%   PPM  - Portable Pixmap                    imread    imwrite
%   RAS  - Sun Raster                         imread    imwrite
%   TIFF - Tagged Image File Format           imread    imwrite
%          Includes TIF
%   XWD  - X Window Dump                      imread    imwrite
% 
%  Audio formats
%   AU   - NeXT/Sun sound                     auread    auwrite
%   SND  - NeXT/Sun sound                     auread    auwrite
%   WAV  - Microsoft Wave sound               wavread   wavwrite
%
%   See also UIIMPORT, FSCANF, FREAD, FPRINTF, FWRITE, HDF, HDF5, Tiff, IMFORMATS.
 
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/11/16 22:26:36 $ 
