function info = fitsinfo(filename)
%FITSINFO  Information about FITS file
%
%   INFO = FITSINFO(FILENAME) returns a structure whose fields contain
%   information about the contents a FITS (Flexible Image Transport System)
%   file.  FILENAME is a string that specifies the name of the FITS file.
%
%   The INFO structure will contain the following fields:
%
%      Filename      A string containing the name of the file 
%      
%      FileSize      An integer indicating the size of the file in bytes
%      
%      FileModDate   A string containing the modification date of the file
%
%      Contents      A cell array containing a list of extensions in the
%                    file in the order that they occur
%      
%      PrimaryData   A structure containing information about the primary
%                    data in the FITS file
%
%   The PrimaryData structure will contain the following fields:
%
%      DataType      Precision of the data 
%      
%      Size          Array containing sizes of each dimension
%
%      DataSize      Size in bytes of primary data 
%
%      MissingDataValue  Value used to represent undefined data
%
%      Intercept     Value used along with Slope to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         Value used along with Intercept to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        Number of bytes from beginning of file to location of
%                    first data value
%
%      Keywords      A number-of-keywords x 3 cell array which contain all 
%                    the Keywords, Values and Comments of the header in each
%                    column.
%
%
%   A FITS file may have any number of extensions.  One or more of the
%   following fields may also be present in the INFO structure:
%   
%      AsciiTable  An array of structures containing information
%                  about the Ascii Table extensions in this file
%         
%      BinaryTable An array of structures containing information
%                  about any Binary Table extensions in this file
%         
%      Image       An array of structures containing information
%                  about any Image extensions in this file
%       
%      Unknown     An array of structures containing information
%                  about any non standard extensions in this file.
%
%   The AsciiTable structure will contain the following fields:
%
%      Rows         The number of rows in the table
%        
%      RowSize      The number of characters in each row
%      
%      NFields      The number of fields in each row
%      
%      FieldFormat  A 1 x NFields cell containing formats in which each 
%                   field is encoded.  The formats are FORTRAN-77 format codes.
%
%      FieldPrecision A 1 x NFields cell containing precision of the data in
%                     each field
%
%      FieldWidth   A 1 x NFields array containing the number of characters
%                   in each field
%
%      FieldPos     A 1 x NFields array of numbers representing the
%                   starting column for each field
%
%      DataSize     Size in bytes of the data in the ASCII Table
%
%      MissingDataValue  A 1 x NFields array of numbers used to represent
%                        undefined data in each field
%
%      Intercept    A 1 x NFields array of numbers used along with Slope to
%                   calculate actual data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Slope        A 1 x NFields array of numbers used with Intercept to
%                   calculate true data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Offset       Number of bytes from beginning of file to location of
%                   first data value in the table
%		    
%      Keywords     A number-of-keywords x 3 cell array containing all the
%                   Keywords, Values and Comments in the ASCII table header
%          
%   The BinaryTable structure will contain the following fields:
%
%      Rows        The number of rows in the table
%                  
%      RowSize     The number of bytes in each row
%                  
%      NFields     The number of fields in each row
%
%      FieldFormat  A 1 x NFields cell containing the data type of the data
%                   in each field. The data type is represented by a
%                   FITS binary table format code.
%
%      FieldPrecision A 1 x NFields cell containing precision of the data in
%                     each field
%
%      FieldSize    A 1 x NFields array containing the number of values in
%                   the Nth field
%                            
%      DataSize     Size in bytes of data in the Binary Table.  Value
%                   includes any data past the main table
%
%      MissingDataValue  An 1 x NFields array of numbers used to represent
%                        undefined data in each field
%
%      Intercept    A 1 x NFields array of numbers used along with Slope to
%                   calculate actual data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Slope        A 1 x NFields array of numbers used with Intercept to
%                   calculate true data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Offset       Number of bytes from beginning of file to location of
%                   first data value
%
%      ExtensionSize    The size in bytes of any data past the main table
%
%      ExtensionOffset  The number of bytes from the beginning of the file to
%                       the location of the data past the main table
%      
%      Keywords      A number-of-keywords x 3 cell array containing all the
%                    Keywords, Values and Comments in the Binary table header
%
%   The Image structure will contain the following fields:
%   
%      DataType      Precision of the data 
%      
%      Size          Array containing sizes of each dimension
%
%      DataSize      Size in bytes of data in the Image extension
%
%      MissingDataValue  Value used to represent undefined data
%
%      Intercept     Value used along with Slope to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         Value used along with Intercept to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        Number of bytes from beginning of file to location of
%                    first data value
%
%      Keywords      A number-of-keywords x 3 cell array containing all the
%                    Keywords, Values and Comments in the Image header
%
%   The Unknown structure will contain the following fields:
%
%      DataType      Precision of the data 
%
%      Size          Array containing sizes of each dimension
%
%      DataSize      Size in bytes of data in the extension
%      
%      Intercept     Value used along with Slope to calculate true data
%                    values from the  array data values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         Value used along with Intercept to calculate true data
%                    values from the array data values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      MissingDataValue  Value used to represent undefined data
%
%      Offset        Number of bytes from beginning of file to location of
%                    first data value
%
%      Keywords      A number-of-keywords x 3 cell array containing all the
%                    Keywords, Values and Comments in the extension header
%
%   Example:
%
%      info = fitsinfo('tst0012.fits');
%
%   See also FITSREAD.

%   Copyright 2001-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/11/09 16:27:08 $

checkInputs(nargin);

fid = openFile(filename);

info = buildDefaultInfo;
info = getFileSystemInfo(info, fid);

% Read primary header.
% All FITS files are required to have a primary header.
info.PrimaryData = readheaderunit(fid, info.FileSize);
info.Contents{1} = 'Primary';

if (~isStandardFile(info))

    msg1 = sprintf('File %s is not a standard FITS file.', filename);
    msg2 = sprintf('FITSINFO will attempt to determine the contents.');
    
    warning('MATLAB:fitsinfo:nonstandardFile', '%s\n%s', msg1, msg2);
    
end
    
% Skip the primary data

if (hasExtensions(info))

    success = skipHduData(fid, computeDataSize(info.PrimaryData));
    
    if (success)
      
        info = readExtensions(fid, info);
        
    end
    
end

%Close file
fclose(fid);



function info = readheaderunit(fid, fileSize)
%Read a header unit from a FITS file. File curser is placed at the end of
%the header (an integral number of 2880 bytes).
%
% INFO header information
% HEADERTYPE Type of data this is describing

%Read first card image to determine the type of header unit.
[keyword, value, comment] = readCardImage(fid);

try
  
  headerType = getHeaderType(keyword, value);
  
catch myException
  
  fclose(fid);
  rethrow(myException)
  
end
  
info = createBlankHeaderInfo(headerType);
info(1).Keywords = {keyword, value, comment};

keywordNum = 1;
endFound = false;
while ((~atEOF(fid, fileSize)) && (~endFound))

    keywordNum = keywordNum + 1;
    
    [keyword, value, comment] = readCardImage(fid);

    switch headerType
    case 'primary'
        
        info = updateInfoForPrimary(info, keyword, value);
        
    case 'ascii'
        
        info = updateInfoForTable(info, keyword, value);
        
    case 'binary'
        
        info = updateInfoForBintable(info, keyword, value);
        
    case 'image'
        
        info = updateInfoForImage(info, keyword, value);
        
    otherwise
        
        info = updateInfoForGeneric(info, keyword, value);
        
    end
  
    info.Keywords(keywordNum,:) = {keyword, value, comment};

    if (strcmpi(keyword, 'end'))
        endFound = true;
    end
    
end

if (atEOF(fid,fileSize) && ~endFound)
    
    msg = sprintf('%s\n%s\n%s', ...
           'End of file found before the end of the header was reached.', ...
           'File may be an invalid FITS file or corrupt.', ...
           'Output structure may not contain complete file information.');
    warning('MATLAB:fitsinfo:earlyEOF', msg) 
    
end

info.DataSize = getDataSize(info, headerType);

%Move file position to integral number of 2880 bytes
status = moveToNextHDU(fid);

info.Offset = ftell(fid);
if status == -1
  warning('MATLAB:fitsinfo:seekFailed', 'Seek failed because of incorrect header information.\nFile may be an invalid FITS file or corrupt.\nOutput structure may not contain complete file information.');
end
%End READHEADERUNIT

function [keyword,value,comment] = readCardImage(fid)
[card, readcount] = fread(fid,80,'uchar=>char');
card = card';
if readcount ~= 80
  fclose(fid);
  error('MATLAB:fitsinfo:cardbytes', 'FITS card image was not 80 bytes. FITS file may be invalid or corrupt.');
end

try
  [keyword,value,comment] = parsecard(card);
catch
  fclose(fid);
  error('MATLAB:fitsinfo:cardFormat', 'Unexpected FITS card image format. FITS file may be invalid or corrupt.');
end
%End READCARDIMAGE



function [keyword, value, comment] = parsecard(card)
%Extract the keyword, value and comment from a FITS card image

% See section 5 and appendix A of the FITS spec for details on card images.

keyword = getKeyword(card);
[value, comment]   = getValueAndComment(card);



function info = updateInfoForPrimary(info, keyword, value)

switch lower(keyword)
 case 'bitpix'
  info(1).DataType =  bitdepth2precision(value);
 case 'naxis'
  info(1).Intercept = 0;
  info(1).Slope = 1;
 case 'extend'
 case 'bzero'
  info(1).Intercept = value;
 case 'bscale'
  info(1).Slope = value;
 case 'blank'
  info(1).MissingDataValue = value;
 case 'end'
 otherwise
  %Take care of NAXISN keywords
  if findstr('naxis',lower(keyword))
    dim = sscanf(keyword(6:end),'%f');
    info(1).Size(dim) = value;
    if length(info(1).Size)==1
      info(1).Size(2) = 1;
    end
  end    
end    
%END UPDATEINFOFORPRIMARY

function info = updateInfoForTable(info, keyword, value)

switch lower(keyword)
 case 'end'
 case 'naxis1'
  info.RowSize = value;
 case 'naxis2'
  info.Rows = value;
 case 'tfields'
  info.NFields = value;
  info.Slope = ones(1,value);
  info.Intercept = zeros(1,value);
  info.MissingDataValue = cell(1,value);
 otherwise
  %Take care of indexed keywords
  if findstr('tform',lower(keyword))
    % Format is a FORTRAN F-77 code. The code is a characer followed by w.d,
    % the width(w) and implicit decimal place (d).
    % Valid format values in ascii table extensions
    %
    %  A - Character
    %  I - Decimal integer
    %  F - Single precision real 
    %  E - Single precision real, exponential notation
    %  D - Double precision real, exponential notation
    idx = sscanf(keyword(6:end),'%s');
    switch(sscanf(value,' %c',1))
     case 'A'
      format = 'Char';
     case 'I'
      format = 'Integer';
     case {'E','F'}
      format = 'Single';
     case 'D'
      format = 'Double';
     otherwise
      format = 'Unknown';
    end
    
    idxNum = sscanf(idx, '%f');
    
    info.FieldFormat{idxNum} = value;
    info.FieldPrecision{idxNum} = format;
    width = sscanf(value,' %*c%f');
    info.FieldWidth(idxNum) = width;
  elseif findstr('tbcol',lower(keyword))
    idx = sscanf(keyword(6:end),'%s');
    info.FieldPos(sscanf(idx, '%f')) = value;
  elseif findstr('tscal',lower(keyword));
    tscale_idx = sscanf(keyword(6:end),'%i');
    info.Slope(tscale_idx) = value;
  elseif findstr('tzero',lower(keyword));
    tzero_idx = sscanf(keyword(6:end),'%i');
    info.Intercept(tzero_idx) = value;
  elseif findstr('tnull',lower(keyword));
    tnull_idx = sscanf(keyword(6:end),'%i');
    info.MissingDataValue{tnull_idx} = value;
  end
end    
%END UPDATEINFOFORTABLE

function info = updateInfoForBintable(info, keyword, value)

switch lower(keyword)
 case 'end'
 case 'naxis1'
  info.RowSize = value;
 case 'naxis2'
  info.Rows = value;
 case 'tfields'
  info.NFields = value;
  info.Slope = ones(1,value);
  info.Intercept = zeros(1,value);
  info.MissingDataValue = cell(1,value);
 case 'pcount'
  info.ExtensionSize = value;
 otherwise
   if findstr('tscal',lower(keyword));
    tscale_idx = sscanf(keyword(6:end),'%i');
    info.Slope(tscale_idx) = value;
   elseif findstr('tzero',lower(keyword));
    tzero_idx = sscanf(keyword(6:end),'%i');
    info.Intercept(tzero_idx) = value;
   elseif findstr('tnull',lower(keyword));
     tnull_idx = sscanf(keyword(6:end),'%i');
     info.MissingDataValue{tnull_idx} = value;
   elseif findstr('tform',lower(keyword))
    idx = sscanf(keyword(6:end),'%s');
    repeat = sscanf(value,'%f',1);
    if isempty(repeat)
      repeat = 1;
    end
    format = sscanf(value,' %*i%c',1);
    if isempty(format)
      format = sscanf(value,' %c',1);
    end
    % The value for tformN is a format defined in the FITS standard.  The
    % form is rTa, where r is the repeat, T is the precision and a is a
    % number undefined by the standard. 
    %
    % Binary Table Format valid T (precision) characters and # bytes
    %
    %  L - Logical             1
    %  X - Bit                 *
    %  B - Unsigned Byte       1
    %  I - 16-bit integer      2
    %  J - 32-bit integer      4
    %  A - Character           1
    %  E - Single              4
    %  D - Double              8
    %  C - Complex Single      8
    %  M - Complex Double      16
    %  P - Array Descriptor    8
    switch format
     case 'L'
      format = 'char';
     case 'X'
      precisionWidth = 8 * ceil(double(repeat) / 8);
      format = sprintf('bit%d', precisionWidth);
      if repeat~=0
          repeat = 1;
      end
     case 'B'
      format = 'uint8';
     case 'I'
      format = 'int16';
     case 'J'
      format = 'int32';
     case 'A'
      format = 'char';
     case 'E'
      format = 'single';
     case 'D'
      format = 'double';
     case 'C'
      format = 'single complex';
     case 'M'
      format = 'double complex';
     case 'P'
      format = 'int32';
      if repeat~=0
	repeat = 2;
      end
    end
    
    idxNum = sscanf(idx, '%f');
    
    info.FieldFormat{idxNum} = value;
    info.FieldPrecision{idxNum} = format;
    info.FieldSize(idxNum) = repeat;
  end    
end    
%END UPDATEINFOFORBINTABLE

function info = updateInfoForImage(info, keyword, value)

switch lower(keyword)
 case 'end'
 case 'bitpix'
  info.DataType =  bitdepth2precision(value);
 case 'naxis'
  info.Intercept = 0;
  info.Slope = 1;
 case 'blank'
  info.MissingDataValue= value;
 case 'bzero'
  info.Intercept = value;
 case 'bscale'
  info.Slope = value;
 otherwise
  %NAXISN keywords
  if findstr('naxis',lower(keyword))
    dim = sscanf(keyword(6:end),'%f');
    info(1).Size(dim) = value;
  end    
end    
%END UPDATEINFOFORIMAGE

function info = updateInfoForGeneric(info, keyword, value)

switch lower(keyword)
 case 'bitpix'
  info.DataType =  bitdepth2precision(value);
 case 'naxis'
  info.Intercept = 0;
  info.Slope = 1;
% case 'extend'         % This code doesn't appear to do anything,
%  extensions = 1;      % but I'm keeping it here just 'cuz.
 case 'bzero'
  info.Intercept = value;
 case 'bscale'
  info.Slope = value;
 case 'blank'
  info.MissingDataValue = value;
 case 'pcount'
  info.PCOUNT = value;
 case 'gcount'
  info.GCOUNT = value;
 case 'end'
 otherwise
  %Take care of NAXISN keywords
  if findstr('naxis',lower(keyword))
    dim = sscanf(keyword(6:end),'%f');
    info.Size(dim) = value;
  end    
end    
%END UPDATEINFOFORGENERIC

function precision = bitdepth2precision(value)
switch value
 case 8
  precision = 'uint8';
 case 16 
  precision = 'int16';
 case 32
  precision = 'int32';
 case -32
  precision = 'single';
 case -64
  precision = 'double';
end
%END BITDEPTH2PRECISION

function bitdepth = precision2bitdepth(precision)
switch precision
 case 'uint8'
  bitdepth = 8;
 case 'int16' 
  bitdepth = 16;
 case 'int32'
  bitdepth = 32;
 case 'single'
  bitdepth = 32;
 case 'double'
  bitdepth = 64;
end
%END PRECISION2BITDEPTH

function v = atEOF(fid,fileSize)
% Sometimes FEOF does not recognize that the file identifier is at the end of
% the file.  So, the end of the file has been reached if FEOF returns true or if
% the file identifyer is at the end of the file.
v = (feof(fid) == 1) || (ftell(fid) == fileSize);



function success = skipHduData(fid,datasize)

if (datasize ~= 0)
  
    % Data must be multiple of 2880 bytes, so skip to the end of the
    % last block.
    if (rem(datasize,2880) == 0)
      
        bytes_to_seek = datasize;
    
    else
      
        bytes_to_seek = datasize + (2880 - rem(datasize,2880));
    
    end
  
    status = fseek(fid,bytes_to_seek,0);
    
    % It's possible that the dataset didn't have enough data or that the
    % file wasn't properly padded to fill the 2,880 byte block.
    % Processing should stop with a warning.  Other failures should
    % cause an error.
    if (status == -1)
    
        [err, id] = ferror(fid);
    
        str1 = 'Seek failed because of incorrect header information.';
        str2 = 'File may be invalid or corrupt.  Output structure may not contain complete file information.';

        OFFSETBEYONDEOF = -27;  % From bnfile/fiofcn.cpp
        if (id == OFFSETBEYONDEOF)
      
            warning('MATLAB:fitsinfo:seekFailed', '%s\n%s', str1, str2)
      
        else
        
            error('MATLAB:fitsinfo:seekFailed', '%s\n%s', str1, str2)
      
        end
    
        success = false;
    
    else
    
        success = true;
    
    end
    
else
  
    % No data to skip.
    success = true;
  
end



function fid = openFile(filename)
%openFile   Open a FITS file for reading.

% FITS files are big-endian.
fid = fopen(filename,'r','ieee-be');

if (fid == -1)
    
    error('MATLAB:fitsinfo:fileOpen', ...
          'Unable to open file "%s" for reading.', filename);
    
end



function info = buildDefaultInfo
%buildDefaultInfo   Create a structure with the default info fields.

info.Filename = '';
info.FileModDate = '';
info.FileSize = [];
info.Contents = {};
info.PrimaryData = [];



function info = getFileSystemInfo(info, fid)    
%getPhysicalFileInfo   Get file system information about the FITS file.

% Get the full filename.
info.Filename = fopen(fid);

% Get info about the file from DIR.
d = dir(info.Filename);
info.FileModDate = d.date;
info.FileSize = d.bytes;



function headerInfo = createBlankHeaderInfo(headerType)

switch (headerType)
case 'primary';

    fields = {'DataType', []
              'Size', []
              'DataSize', []
              'MissingDataValue', []
              'Intercept', []
              'Slope', []
              'Offset', []
              'Keywords', {}};
    
case 'ascii'; 
    
    fields = {'Rows', []
              'RowSize', []
              'NFields', []
              'FieldFormat', {}
              'FieldPrecision', ''
              'FieldWidth', []
              'FieldPos', []
              'DataSize', []
              'MissingDataValue', {}
              'Intercept', []
              'Slope', []
              'Offset', []
              'Keywords', {}};
        
case 'binary';
        
    fields = {'Rows', []
              'RowSize', []
              'NFields', []
              'FieldFormat', {}
              'FieldPrecision', ''
              'FieldSize', []
              'DataSize', []
              'MissingDataValue', {}
              'Intercept', []
              'Slope', []
              'Offset', []
              'ExtensionSize', []
              'ExtensionOffset', []
              'Keywords', {}};
    
case 'image';
    
    fields = {'DataType', []
              'Size', []
              'DataSize', []
              'Offset', []
              'MissingDataValue', {}
              'Intercept', []
              'Slope', []
              'Keywords', {}};
        
case 'unknown';
    
    fields = {'DataType', []
              'Size', []
              'DataSize', []
              'PCOUNT', []
              'GCOUNT', []
              'Offset', []
              'MissingDataValue', []
              'Intercept', []
              'Slope', []
              'Keywords', {}};
    
end

fields = fields';
headerInfo = struct(fields{:});



function dataSize = getDataSize(info, headerType)

switch (headerType)
case {'primary', 'image'}
    
    if (~isempty(info.Size))
        dataSize = prod(info.Size) * precision2bitdepth(info.DataType)/8;
    else
        dataSize = 0;
    end
    
case {'ascii', 'binary'}

    dataSize = info.RowSize * info.Rows;

case 'unknown'	  
    
    if (~isempty(info.Size))
        
        dataSize = (precision2bitdepth(info.DataType) * info.GCOUNT * ...
                    (info.PCOUNT + prod(info.Size))) / 8;
    
    end
    
end



function info = readExtensions(fid, info)

asciicount = 1;
binarycount = 1;
imagecount = 1;
unknowncount = 1;

while ~atEOF(fid,info.FileSize)
    
    if (~strcmpi(readCardImage(fid), 'xtension'))
        
        status = fseek(fid, 2880 - 80, 0); % Seek one fits block minus
                                           % one card image just read.
        if status == -1
                                             
            msg = sprintf('%s\n%s\n%s', ...
                'Seek failed because of incorrect header information.', ...
                'File may be invalid or corrupt.', ...
                'Output structure may not contain complete file information.');
            warning('MATLAB:fitsinfo:seekFailed', msg);
            
            return;
            
        end
        continue;
        
    else
        
        % Rewind one card image
        fseek(fid,-80,0);
    end
    
    extensionInfo = readheaderunit(fid,info.FileSize);
    if isempty(extensionInfo)
        %No extension
        fclose(fid);
        return;
    end
    switch (getExtensionType(extensionInfo))
    case 'ascii'
        info.AsciiTable(asciicount) = extensionInfo;
        info.Contents{end+1} = 'ASCII Table';
        asciicount = asciicount+1;
    case 'binary'
        info.BinaryTable(binarycount) = extensionInfo;
        info.Contents{end+1} = 'Binary Table';
        info.BinaryTable(binarycount).ExtensionOffset = info.BinaryTable(binarycount).Offset+ info.BinaryTable(binarycount).RowSize*info.BinaryTable(binarycount).Rows;
        binarycount = binarycount+1;
    case 'image'
        info.Image(imagecount) = extensionInfo;
        info.Contents{end+1} = 'Image';
        imagecount = imagecount+1;
    case 'unknown'
        info.Unknown(unknowncount) = extensionInfo;
        info.Contents{end+1} = 'Unknown';
        unknowncount = unknowncount+1;
    end % End switch headerType

    success = skipHduData(fid, computeDataSize(extensionInfo));
    if (~success)
      
        return
        
    end
    
end % End while ~atEOF(....)



function isCompliant = isStandardFile(info)

isCompliant = any(strcmp('SIMPLE', info.PrimaryData.Keywords(:,1)));



function checkInputs(argumentCount)

estr = nargchk(1, 1, argumentCount, 'struct');

if (~isempty(estr))
    error(estr)
end



function extensions = hasExtensions(info)

idx = strcmpi('extend', info.PrimaryData.Keywords(:,1));

if (any(idx))
    
    if (strcmpi('t', info.PrimaryData.Keywords(find(idx), 2)))
        
        extensions = true;
        
    else
        
        extensions = false;
        
    end
    
else
    
    extensions = false;
    
end



function bytes = computeDataSize(extensionInfo)

if (isequal(getExtensionType(extensionInfo), 'binary'))
    
    bytes = extensionInfo.DataSize + extensionInfo.ExtensionSize;
    
else
    
    bytes = extensionInfo.DataSize;
  
end



function headerType = getExtensionType(extensionInfo)

headerType = getHeaderType(extensionInfo.Keywords{1,1}, ...
                           extensionInfo.Keywords{1,2});



function headerType = getHeaderType(extensionKeyword, extensionValue)

switch (lower(extensionKeyword))
case 'simple'
    
    headerType = 'primary';
    
case 'xtension'
    
    switch (lower(extensionValue))
    case 'bintable'
        
        headerType = 'binary';
        
    case 'image'
        
        headerType = 'image';
        
    case 'table'
        
        headerType = 'ascii';
        
    otherwise
        
        headerType = 'unknown';
        
    end
    
otherwise

    error('MATLAB:fitsinfo:unrecognizedExtension', ...
          'Cannot determine extension from keyword "%s".', ...
          extensionKeyword)
    
end



function keyword = getKeyword(cardImage)

%"The keyword shall be a left justified, 8-character, blank-filled, ASCII
% string with no embedded blanks."

keyword = cardImage(1:8);
keyword = keyword(~isspace(keyword));



function [value, comment] = getValueAndComment(cardImage)

% Isolate the value from a possible comment, which will be preceded by a
% slash and might contain quotes (i.e., quotes can appear in comments and
% slashes can occur in quoted values).
%
% If the value is a character string, then the value is within the first
% set of matched single quotes -- double single quotes ('') don't count.
% The comment begins after the first slash after the value.

% If no value indicator, then the card image is a commentary card image
% and a value is not present.
if ((~isequal(cardImage(9:10), '= ')) || (isCOMMENT(cardImage)))
    
    value = '';
    comment = cardImage(9:end);
    
elseif (isCharacterString(cardImage))

    [value, comment] = splitCharacterCard(cardImage);
    value = cleanupCharacterValue(value);
    
elseif (isTIMFILE(cardImage))
    
    [value, comment] = splitTIMFILECard(cardImage);

else

    [value, comment] = splitNumericCard(cardImage);
    value = cleanupNumericValue(value);
    value = convertNumericValue(value);
        
end

% Get rid of comment's "/" marker.  Trailing whitespace is not mentioned
% in the standard so leave it (unless it's the whole comment).
comment = stripCommentMarker(comment);
comment = cleanupCommentWhitespace(comment);



function [value, comment] = splitCharacterCard(cardImage)

quoteChar = char(39);  % 39 == '

% Look for the quotes denoting the value.
quoteIdx = find(cardImage == quoteChar);

% Temporarily set the endQuote to empty, in case the end quote is
% never found.
endQuote = [];

% The first "lone" closing single quote is the value's closing quote.
for p = 2:2:numel(quoteIdx)
    
    if ((p == numel(quoteIdx)) || ...
        (p == numel(quoteIdx) - 1))
        
        % If it's the last even-numbered quote, this is the end.
        endQuote = quoteIdx(p);
        
    elseif (quoteIdx(p + 1) ~= quoteIdx(p) + 1)
        
        % If the next odd quote is not adjacent, this is the end.    
        endQuote = quoteIdx(p);
        break
        
    end
    
end
    
% Make sure a closing quote was found.
if (isempty(endQuote))
    
    warning('MATLAB:fitsinfo:missingEndQuote', ...
            'The card image was missing an ending quote.')
    
    endQuote = numel(cardImage);
    
end

% Assign the value.
value = cardImage(quoteIdx(1):endQuote);

% Look for the comment.
slashIdx = find(cardImage == '/');

if (~isempty(slashIdx))
    
    % The first slash beyond the value's end quote starts the comment.
    commentStartIdx = min(slashIdx(slashIdx > endQuote));
    
    if (~isempty(commentStartIdx))
        
        comment = cardImage(commentStartIdx:end);
        
    else
        
        comment = '';
        
    end
    
else
    
    comment = '';
    
end



function [value, comment] = splitNumericCard(cardImage)

% It's possible to have slashes in keywords.  Start just after keyword.
slashIdx = find(cardImage(9:end) == '/') + 8;

if (~isempty(slashIdx))
    
    commentStartIdx = min(slashIdx);
    
    value   = cardImage(11:(commentStartIdx - 1));
    comment = cardImage(commentStartIdx:end);
    
else
    
    value   = cardImage(11:end);
    comment = '';
    
end

    

function comment = stripCommentMarker(comment)

if (isempty(comment))
    
    return
    
elseif (isequal(comment(1), '/'))
    
    comment(1) = '';
    
end



function value = cleanupNumericValue(value)

if (isempty(value))
    
    return
    
else
    
    % Remove blanks from other formats.
    value = sscanf(value, ' %s');

end



function value = cleanupCharacterValue(value)

if (isempty(value))
    
    return
    
else
    
    % Remove opening and closing single quote from character values.
    if (numel(value) >= 2)
        value([1 end]) = '';
    end

    % Remove trailing blanks.
    value = deblank(value);
    
    % Convert paired single quotes to one single quote.
    quoteChar = char(39);  % 39 == '
    value = strrep(value, [quoteChar quoteChar], quoteChar);
    
end



function valueNum = convertNumericValue(valueStr)

if (isempty(valueStr))
    
    valueNum = [];
    return
    
elseif (strfind(valueStr, '('))

    % Complex values.
    numberParts = sscanf(valueStr, ' ( %f , %f ) ');

    if (numel(numberParts) == 2)
        
        valueNum = complex(numberParts(1), numberParts(2));
        
    else
        
        valueNum = [];
        
    end
    
else
    
    switch (valueStr)
    case {'T', 'F'}
        
        valueNum = valueStr;
        
    otherwise
        
        valueNum = sscanf(valueStr, '%f');
        
        if (isempty(valueNum))
            
            warning('MATLAB:fitsinfo:unknownFormat', ...
                    ['Unable to determine format of the card value.\n', ...
                    'Returning the value as a string.'])

            valueNum = valueStr;
            
        end
        
    
    end
    
end



function tf = isCharacterString(cardImage)

% A value is a character string if the value begins with a quote.

valueAndComment = strtrim(cardImage(11:end));

if (isempty(valueAndComment))
    
    tf = false;
    
else
    
    quoteChar = char(39);  % 39 == '
    tf = isequal(valueAndComment(1), quoteChar);
    
end



function cardHasTIMFILE = isTIMFILE(cardImage)

cardHasTIMFILE = isequal(cardImage(1:7), 'TIMFILE');



function [value, comment] = splitTIMFILECard(cardImage)

% This keyword appears to contain a path string erroneously written without
% quotes.

keywordLength = 9;
valueAndComment = cardImage((keywordLength + 1):end);

slashIdx = find(valueAndComment == '/');

if (isempty(slashIdx))
    
    value = valueAndComment;
    comment = '';
    return
    
end

% This keyword must have a value, so the first slash cannot start a comment
% and be the first nonspace element of the card after the keyword.  It
% suffices to find the first " /" after the value and use that as the
% comment.

% Find the whitespace boundaries around the value.
spaceIdx = find(isspace(valueAndComment));
letterIdx = find(~isspace(valueAndComment));

valueStart = min(letterIdx);
valueEnd = min(spaceIdx(spaceIdx > valueStart)) - 1;

value = valueAndComment(valueStart:valueEnd);

% Find the optional comment.
commentStart = min(slashIdx(slashIdx > valueEnd));
if (isempty(commentStart))
    
    comment = '';
    
else
    
    comment = valueAndComment(commentStart:end);
    
end



function commentOut = cleanupCommentWhitespace(commentIn)

% The standard doesn't say how to treat whitespace before and after
% comments, so we will leave it.  The one exception is if the entire
% comment is empty.  This will likely only happen if there wasn't a value
% or comment in the card (i.e., everything after the keyword was empty).

if (all(commentIn == ' '))  % Compare to space.
    
    commentOut = '';
    
else
    
    commentOut = commentIn;
    
end



function status = moveToNextHDU(fid)

curr_pos = ftell(fid);

if rem(curr_pos, 2880) == 0
    bytes_to_seek = 0;
else
    bytes_to_seek = 2880 - rem(curr_pos, 2880);
end 

status = fseek(fid, bytes_to_seek, 'cof');



function cardHasCOMMENT = isCOMMENT(cardImage)

cardHasCOMMENT = isequal(cardImage(1:7), 'COMMENT');
