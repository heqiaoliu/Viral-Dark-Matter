function multibandwrite(data,filename,interleave,varargin)
%MULTIBANDWRITE write multiband data to a file
%
%   MULTIBANDWRITE writes a three dimensional data set to a binary file. All the
%   data may be written to the file with one function call or MULTIBANDWRITE may
%   be called repeatedly to write pieces of the complete data set to the file.
%
%   The following two syntaxes are ways to use MULTIBANDWRITE to write the
%   entire data set to the file with one function call.  The optional
%   parameter/value pairs described at the below can also be used with these
%   syntaxes.
%
%     MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE) writes DATA, the 2 or
%     3-dimensional array of any numeric or logical type, to the binary file
%     FILENAME.  The bands are written to the file in the form specified by
%     INTERLEAVE. The length of the third dimension of DATA is equal to the
%     number of bands.  By default the data is written to the file in the same
%     precision as it is stored in MATLAB (the same as the class of DATA).
%     INTERLEAVE is a string specifying the method of interleaving the bands
%     written to the file.  Valid strings are 'bil', 'bip', 'bsq', representing
%     band-interleaved-by-line, band-interleaved-by-pixel, and band-sequential
%     respectively. INTERLEAVE is irrelevant if DATA is 2-dimensional. If
%     FILENAME already exists, it will be overwritten unless the optional OFFSET
%     parameter has been specified.
%     
%   The complete data set may be written to the file in smaller chunks by
%   making multiple calls to MULTIBANDWRITE using the following syntax.
%
%     MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,START,TOTALSIZE) writes
%     the data to the binary file piece by piece. DATA is a subset of the
%     complete data set.  MULTIBANDWRITE will be called multiple times to write
%     all the data to the file. A complete file will be written during the
%     first function call and populated with fill values outside the subset
%     provided in the first call and subsequent calls will overwrite all or
%     some of the fill values. The parameters FILENAME, INTERLEAVE, OFFSET
%     and TOTALSIZE should remain constant throughout the writing of the
%     file.
%
%      START == [firstrow firstcolumn firstband] is 1-by-3 where firstrow
%      and firstcolumn gives the image pixel location of the upper left
%      pixel in the box and firstband gives the index of the first band to
%      write.  DATA contains some of the data for some of the bands.
%      DATA(I,J,K) contains the data for the pixel at [firstrow + I - 1,
%      firstcolumn + J - 1] in the (firstband + K - 1)-th band.
%
%      TOTALSIZE == [totalrows,totalcolumns,totalbands] gives the full
%      three-dimensional size of the complete data set to be contained in
%      the file.
%
%   Any number and combination these optional parameter/value pairs may be
%   added to the end of any of the above syntaxes.
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,...,PARAM,VALUE,...) 
%
%     Parameter Value Pairs:
%     
%     PRECISION is a string to control the form and size of each element
%     written to the file.  See the help for FWRITE for a list of valid
%     values for PRECISION.  The default precision is the class of the data.
%
%     OFFSET is the number of bytes to skip before the first data element. If
%     the file does not already exist, ASCII null values will be written to fill
%     the space by default. This option is useful when writing a header to the
%     file before or after writing the data. When writing the header after the
%     data is written, the file should be opened with FOPEN using 'r+'
%     permission.
%
%     MACHFMT is a string to control the format in which the data
%     is written to the file. Typical values are 'ieee-le' for little endian
%     and 'ieee-be' for big endian however all values for MACHINEFORMAT as
%     documented in FOPEN are valid.  See FOPEN for a complete list.  The
%     default machine format is the local machine format.
%     
%     FILLVALUE is a number specifying the value for missing data. FILLVALUE
%     may be a single number, specifying the fill value for all missing data
%     or FILLVALUE may be a 1-by-number of bands vector of numbers
%     specifying the fill value for each band.  This value will be used to
%     fill space when data is written in chunks.
%
%   Examples:
%
%   % 1.  Write all data (interleaved by line) to the file in one call.
%
%   data = reshape(uint16(1:600), [10 20 3]);
%   multibandwrite(data,'data.bil','bil');
%  
%   % 2.  Write the bands (interleaved by pixel) to the file in
%   %     separate calls.
%
%   totalRows    = size(data, 1);
%   totalColumns = size(data, 2);
%   totalBands   = size(data, 3);
%
%   for i = 1:totalBands
%
%      bandData = data(:, :, i);
%      multibandwrite(bandData, 'data.bip', 'bip', [1 1 i],...
%                     [totalColumns, totalRows, totalBands]);
%
%   end
%       
%   % 3.  Write a single-band tiled image with one call for each tile.
%   %     This is useful if only a subset of each band is available
%   %     at each call to MULTIBANDWRITE.
%
%   numBands = 1;
%   dataDims = [1024 1024 numBands];
%   data = reshape(uint32(1:(1024 * 1024 * numBands)), dataDims);
%
%   for band = 1:numBands
%       for row = 1:2
%          for col = 1:2
%   
%              subsetRows = ((row - 1) * 512 + 1):(row * 512);
%              subsetCols = ((col - 1) * 512 + 1):(col * 512);
%              
%              upperLeft = [subsetRows(1), subsetCols(1), band];
%              multibandwrite(data(subsetRows, subsetCols, band), ...
%                             'banddata.bsq', 'bsq', upperLeft, dataDims);
%              
%          end
%       end
%   end
%
%   See also MULTIBANDREAD, FWRITE, FREAD 

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2009/02/06 14:21:25 $

% Check input values.
error(nargchk(3,13,nargin, 'struct'));
error(nargoutchk(0,0,nargout, 'struct'));

options = parseInputs(data, filename, interleave, varargin{:});
verifyFileConsistency(filename, options)

% Open file.
fid = openFile(filename, options);

% Skip past / create the offset bytes.
moveToStart(fid, data, options)

% Write the data.
switch lower(interleave)
case 'bsq'
    writeFcn = @writebsqfile;
case 'bil'                                               
    writeFcn = @writebilfile;
case 'bip'                                               
    writeFcn = @writebipfile;
end

writeFcn(fid, data, options.precision, options.chunking, options.start, ...
         options.totalsize);

% Close the file.
fclose(fid);



%=============================================================
function moveToStart(fid, data, options)
% Move to the location where the data should start in this file, creating
% the file if necessary.

if (options.exists)
    
    status = fseek(fid, length(options.offsetBuffer), 'bof');
    if (status == -1)

        fclose(fid);
        error('MATLAB:multibandwrite:seekError', ...
            'Unable to seek to desired offset in existing file.');

    end

else

    fwrite(fid, options.offsetBuffer, 'uint8');

end

% The first time when writing chunks fill the file with the complete
% amount of data.
d = dir(fopen(fid));
if ((~options.exists && options.chunking) || ...
    (options.exists && (d.bytes==length(options.offsetBuffer))))

    % The first time when writing chunks fill the file with the complete
    % amount of data.
    writeFillData(fid, size(data), options.totalsize, options.fillvalue, ...
                  options.precision, options.interleave);

end



%=============================================================
function expectedSize = expectedFileSize(offsetSize,totalsize,precision)

numberOfValues = prod(totalsize);
[w, outputClass, bitprecision] = getPixelInfo(precision);
if bitprecision
    expectedSize = ceil(offsetSize+numberOfValues*w/8);
else
    expectedSize = offsetSize+numberOfValues*w;
end

%=============================================================
function writebipfile(fid, data, precision, chunking, start, totalsize)
% Write data with bands interleaved by pixel.  (e.g., RGBRGB...)

[rows, columns, bands] = size(data);
[w, outputClass, bitprecision, msg] = getPixelInfo(precision);
if ~isempty(msg)
    error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if (~chunking)
    outdata = permute(data, [3,2,1]);
    fwrite(fid, outdata, precision); 
else
    %Seek to beginning of band
    skipSize = start(3)-1;
    %Seek to first row
    skipSize = skipSize + totalsize(3)*totalsize(2)*(start(1)-1);
    %Seek to first column
    skipSize = skipSize + (start(2)-1)*totalsize(3);
    firstPixel = skipSize;
    for i=1:rows
        %%Seek to beginning of row
        skipSize = firstPixel + totalsize(3)*totalsize(2)*(i-1);
        skip(fid,skipSize,precision,bitprecision,w);
        for j=1:columns
            fwrite(fid,data(i,j,:),precision);
            %Seek to next column
            skip(fid,totalsize(3)-size(data,3),precision,bitprecision,w,'cof');
        end
    end
end

%=============================================================
function writebilfile(fid, data, precision, chunking, start, totalsize)
% Write data with bands interleaved by line.
% (e.g.  RRR...GGG...BBB...RRR...GGG...BBB...)

subsetRows  = size(data, 1);
subsetBands = size(data, 3);

[pixelWidth, outputClass, bitprecision, msg] = getPixelInfo(precision);
if ~isempty(msg)
    error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if (~chunking)

    % Output the whole dataset, writing rows interleaved by band.
    for i = 1:subsetRows
        for j = 1:subsetBands
            fwrite(fid, data(i,:,j), precision);
        end
    end
    
else

    fullRows    = totalsize(1);
    fullColumns = totalsize(2);
    fullBands   = totalsize(3);
    
    % Compute the location of the start of the data subset in the output
    % file.  (This is in element counts not bytes.)
    fileElementOffset = (start(3) - 1) * fullColumns + ...        % Band
                        (start(2) - 1) + ...                      % Column
                        (start(1) - 1) * fullColumns * fullBands; % Row

    for k = 1:subsetRows
        for j = 1:subsetBands
            % Compute the location of this band/row (in element counts).
            fileElementPosition = (k - 1) * fullColumns * fullBands + ...
                                  (j - 1) * fullColumns;

            % Go to the location of where to write the data.
            skip(fid, fileElementOffset + fileElementPosition, ...
                 precision, bitprecision, pixelWidth);

            % Write the data.
            fwrite(fid, data(k,:,j), precision);
        end
    end
end

    
%=============================================================
function writebsqfile(fid, data, precision, chunking, start, totalsize)
% Write data where all bands are separated into planes (like MATLAB's
% storage scheme except row major).
% (e.g, RRRRRR......GGGGGG......BBBBBB......)

rows = size(data, 1);
bands = size(data, 3);
[w,outputClass,bitprecision,msg] = getPixelInfo(precision);
if ~isempty(msg)
  error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if (~chunking)
    for i=1:bands
        for j=1:rows
            fwrite(fid,data(j,:,i),precision);
        end
    end
    % Memory abusive way
    %  fwrite(fid,permute(data,[2 1 3]),precision);
else
    for k=1:size(data,3)
        %Skip to beginning of the band to write
        skipSize = (start(3)+k-2)*prod(totalsize(1:2));
        %Skip to beginning of the first column to write
        skipSize = skipSize + (start(2)-1);  
        %Loop over number of row (because row major order in file)
        for i=1:size(data,1)
            %Skip to beginning of the row to write
            skip(fid,skipSize + (start(1)+i-2)*totalsize(2),precision,bitprecision,w);
            fwrite(fid,data(i,:,k),precision);
        end
    end
end

%=============================================================
function writeFillData(fid,datasize,totalsize,fillvalue,precision,interleave)

currentPos = ftell(fid);

if length(datasize)==length(totalsize) && all(datasize==totalsize)
  chunking = false;
else
  chunking = true;
end

% Create same number of fill values as amount of data user entered.
[w,outputClass,bitprecision,msg] = getPixelInfo(precision);
if ~isempty(msg)
  error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if length(fillvalue)==1
  % Fill value is the same for all bands
  fillBuffer(1:prod(datasize)) = feval(outputClass,fillvalue);
  % Calculate number of times to loop
  loop      = fix(prod(totalsize)/prod(datasize));
  remainder = rem(prod(totalsize),prod(datasize));
  % Write fill values
    for i=1:loop
    fwrite(fid,fillBuffer,precision);
  end
  % Write remainder
  if remainder
    fwrite(fid,fillBuffer(1:remainder),precision);
  end
else
  % Fill value is different for each band
  % Use 1 full band as a reasonable size buffer
  for i=1:totalsize(3)
    fillBuffer(totalsize(1),totalsize(2)) = feval(outputClass,fillvalue(i));
    start = [1 1 i];
    switch lower(interleave)
     case 'bsq'
      writebsqfile(fid,fillBuffer,precision,chunking,start,totalsize);
     case 'bil'        
      writebilfile(fid,fillBuffer,precision,chunking,start,totalsize);
     case 'bip'        
      writebipfile(fid,fillBuffer,precision,chunking,start,totalsize);
    end
  end
end
fseek(fid,currentPos,'bof');
return;

%=============================================================================
function [w,outputClass,bitprecision,msg] = getPixelInfo(precision)
% Returns width of each pixel.  Width is in bytes unless precision is 
% ubitN or bitN in which case width is in bits.  
% FTELL does not return correct values for bit precisions

msg = '';  
bitprecision = false;  
if isempty(strfind(precision,'bit'))
    tempfile = tempname;
    tf = fopen(tempfile,'W','n');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for writing.',tempfile);
    else
        try
            fwrite(tf,1,precision);
        catch myException
            fclose(tf);
            delete(tempfile);
            rethrow(myException);
        end
        fclose(tf);
    end
    
    tf = fopen(tempfile,'r');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for reading.',tempfile);
    else
        p = ftell(tf);
        tmp = fread(tf, 1, ['*' precision]);
        w = ftell(tf)-p;
        fclose(tf);
        outputClass = class(tmp);
    end
    try
        delete(tempfile);
    catch
        warning('MATLAB:multibandwrite:tempFileDelete', ...
                'Unable to delete temporary file %s.', tempfile);
    end
else
    % If it is a bit precision, parse the precision string to determine w.
    bitprecision = true;
    precision(isspace(precision))=[];
    if strncmp(precision,'*',1)
        precision(1)=[];
    end
    i = strfind(precision,'=>')-1;
    if isempty(i)
        i=length(precision);
    end
    w = sscanf(precision(~isletter(precision(1:i))), '%d');
    if isempty(w)
        error('MATLAB:multibandwrite:badPrecision', 'Unrecognized PRECISION, ''%s''.',precision);
    end
    tempfile = tempname;
    tf = fopen(tempfile,'W','n');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for writing.',tempfile);
    else
        fwrite(tf,ones(1,8),precision);
        fclose(tf);
    end
    
    tf = fopen(tempfile,'r');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for reading.',tempfile);
    else
        p = ftell(tf);
        tmp = fread(tf, 1, ['*' precision]);
        w = ftell(tf)-p;
        fclose(tf);
        outputClass = class(tmp);
    end
    try
        delete(tempfile);
    catch
        warning('MATLAB:multibandwrite:tempFileDelete', ...
                'Unable to delete temporary file %s.', tempfile);
    end
end
return;

%=============================================================

function skip(fid,skipSize,precision,bitprecision,eltsize,origin)
% Seek to a position in the file.
% If precision is a bit precision then skipSize is in bits.

if nargin==6
  origin = origin;
else
  origin = 'bof';
end
  
if bitprecision
  if strcmp(origin,'bof')
    frewind(fid);
  end
  % FSEEK 0 bytes before and after FREAD because file is being written to and
  % read from without being re-opened.
  fseek(fid,0,'cof');
  fread(fid,skipSize/eltsize,precision);
  fseek(fid,0,'cof');
else
  fseek(fid,skipSize*eltsize,origin);
end
return;

%=============================================================
function options = parseInputs(data, filename, interleave,varargin)

if ~isnumeric(data) && ~islogical(data)
  error('MATLAB:multibandwrite:badData', ...
        'DATA must be a numeric or logical array.');
end

if ndims(data) > 3
  error('MATLAB:multibandwrite:badData', ...
        'DATA must have no more than three dimensions.');
end

if ~ischar(filename)
  error('MATLAB:multibandwrite:badFilename', ...
        'FILENAME must be a string.');
end

if isempty(strmatch(lower(interleave),{'bil','bsq','bip'}))
  error('MATLAB:multibandwrite:badInterleave', ...
        'INTERLEAVE must be ''bil'', ''bip'', or ''bip''');
end

% Default precision == class of DATA
precision = class(data);
% Default to native machine format
machfmt   = 'n';
% Default fillvalue of zero
fillvalue = 0;
chunking  = false;
start     = [];
totalsize = [];
% Default to an offset of zero
% What if fillvalue is out of range?
offsetBuffer = uint8([]);

if islogical(data)
  precision = 'ubit1';
end

if ( (nargin > 3)&& isnumeric(varargin{1}) ) || ...
        ( (nargin > 5) && isnumeric(varargin{1}) )    
    chunking = true;
end

% Optional parameter/value pairs
if (nargin > 3) && ischar(varargin{1})
    idx = 1;
    if rem(length(varargin),2)
        error('MATLAB:multibandwrite:badParamPair', ...
              'The property/value inputs must always occur as pairs.')
    end
elseif (nargin > 5) && isnumeric(varargin{1}) && ischar(varargin{3})
    idx = 3;
    if rem(length(varargin)-2,2)
        error('MATLAB:multibandwrite:badParamPair', ...
              'The property/value inputs must always occur as pairs.')
    end
end
params = {'fillvalue','precision','machfmt','offset'};
if ((nargin > 3) && ischar(varargin{1})) || ...
        ( (nargin > 5) && isnumeric(varargin{1}) && ischar(varargin{3}))
  for i=idx:2:(length(varargin))
    m = strmatch(lower(varargin{i}),params);
    switch length(m)
     case 1
      if m==1
        fillvalue = varargin{i+1};
        %Check FILLVALUE
        if ~((ndims(fillvalue)==2 && ...
              (size(fillvalue,1)==1 || size(fillvalue,2)==1) ))
              error('MATLAB:multibandwrite:badFillvalue', ...
                    'FILLVALUE must be a row or column vector of numbers no longer than the total number of bands.')
        end
      elseif m==2
        precision = varargin{i+1};
      elseif m==3
        machfmt = varargin{i+1};
      elseif m==4
        if any(varargin{i + 1} < 0) || ~isnumeric(varargin{i+1})
          error('MATLAB:multibandwrite:badOffset', ...
                'OFFSET must be number zero or greater.');
        end
        % Decimal zero is the ASCII null character
        offsetBuffer(1:varargin{i+1}) = 0;
      end
     case 0
      error('MATLAB:multibandwrite:badParamPair', ...
            'Unrecognized parameter name ''%s''.', varargin{i});
     otherwise % more than one match
      error('MATLAB:multibandwrite:badParamPair', ...
            'Ambiguous parameter name ''%s''.', varargin{i});
    end % switch
  end
end

% Permissions for opening the file. If file exists, but no offset or chunking,
% overwrite.  If file exists but there is an offset or the file is being
% written in chunks, don't overwrite.
if isempty(dir(filename))
  % File does not exist.
  exists = 0;
  permission = 'W';
elseif ~chunking && isempty(offsetBuffer)
  % File exists, but overwrite.
  exists = 1;
  permission = 'W';
else  
  % File exists, don't overwrite.
  exists = 1;
  permission = 'r+';
end

if (chunking)
    start = varargin{1};
    totalsize = varargin{2};

    if ((numel(totalsize) ~= 3) || (any(totalsize <= 0)))
        error('MATLAB:multibandwrite:badTotalsize', ...
              'TOTALSIZE must be a 3 element vector of positive numbers specifying [totalrows,totalcolumns,totalbands].');
          
    elseif ((numel(start) ~= 3) || (any(start <= 0)))
        error('MATLAB:multibandwrite:badStart', ...
              'START must be a 3 element vector of positive numbers specifying [firstrow firstcolumn firstband].');
          
    elseif (numel(fillvalue) > totalsize(3))
        error('MATLAB:multibandwrite:badFillvalue', ...
              'FILLVALUE must be a row or column vector of numbers no longer than the total number of bands.')
    end
end

options.chunking = chunking;
options.exists = exists;
options.fillvalue = fillvalue;
options.machfmt = machfmt;
options.offsetBuffer = offsetBuffer;
options.permission = permission;
options.precision = precision;
options.start = start;
options.totalsize = totalsize;
options.interleave = interleave;



function verifyFileConsistency(filename, options)

% Only need to check for extant files where chunking is used.
if (options.exists && options.chunking)

    d = dir(filename);
    expectedSize = expectedFileSize(numel(options.offsetBuffer), ...
                                    options.totalsize, ...
                                    options.precision);
  
    % If the file size is different than the number of offset bytes or
    % the expected size, or if there is no data to write, then error.
    if (((d.bytes ~= numel(options.offsetBuffer)) && ...
        (d.bytes ~= expectedSize))) || any(options.totalsize) <=0
    
        error('MATLAB:multibandwrite:badTotalsize', ...
              'TOTALSIZE is inconsistent with the existing file size.');
    end
end



function fid = openFile(filename, options)

fid = fopen(filename, options.permission, options.machfmt);

if (fid < 0)

    error('MATLAB:multibandwrite:fileOpen', ...
          'Unable to open %s for writing.', filename);
    
end
