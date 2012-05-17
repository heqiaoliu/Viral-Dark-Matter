function TF = isanalyze75(filename)
%ISANALYZE75 Return true for a header file of a Mayo Analyze 7.5 data set.
%
%   TF = ISANALYZE75(FILENAME) returns TRUE if FILENAME is a header file of
%   a Mayo Analyze 7.5 data set. 
%
%   FILENAME is considered to be a valid header file of a Mayo Analyze 7.5
%   data set if the header size is 348 bytes.
%
%   Example
%   -------  
%   TF = isanalyze75('brainMRI.hdr');
%
%   See also ANALYZE75INFO, ANALYZE75READ.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/12/22 23:48:12 $


% Check the number of input arguments.
iptchecknargin(1,1,nargin,mfilename);

% Check if filename is a string.
if ~isa(filename,'char')
    eid = 'Images:isanalyze75:invalidInputArgument';
    msg = 'Input argument to ISANALYZE75 must be a filename.';
    error(eid, msg);
end
    
% Open the HDR file
fid  = analyze75open(filename, 'hdr', 'r');

% Check headerSize
TF = validateHeaderSize(fid, filename);

% Close the file
fclose(fid);



%%%
%%% Function validateHeaderSize
%%%
function TF = validateHeaderSize(fid, filename)

% Analyze 7.5 format standard header size
analyzeHeader = int32(348);
% Interfile header - swapbytes(typecast(uint8('!INT'), 'int32'))
interfileHeader = int32(558452308); 
% Possible extended header size
extendedRange = int32([348 2000]);

% Read headerSize.
headerSize = fread(fid, 1, 'int32=>int32');
swappedHeaderSize = swapbytes(headerSize);

% Compare with Standard Analyze 7.5 headerSize. 
if ((headerSize == analyzeHeader)||(swappedHeaderSize == analyzeHeader))
    TF = true;
% Compare with Interfile header 
elseif ((headerSize == interfileHeader) || ...
        (swappedHeaderSize == interfileHeader))
    TF = false;
% Check for extended headerSize  
elseif ((headerSize > extendedRange(1)) ... 
    && (headerSize < extendedRange(2))) ...
    || ((swappedHeaderSize > extendedRange(1)) ...
    && (swappedHeaderSize < extendedRange(2)))
     % Return true but warn that this may not be a valid Analyze 7.5 file
     TF = true;
     warnid = 'Images:isanalyze75:incorrectHeaderSize';
     msg = ['Header size was not 348 bytes. %s may not be a valid ' ...
         'Analyze7.5 format HDR file'];
     warning(warnid, msg, filename');   
% Invalid headerSize    
else
    TF = false;    
end






