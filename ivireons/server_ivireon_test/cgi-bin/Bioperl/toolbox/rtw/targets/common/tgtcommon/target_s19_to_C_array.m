function c_array = target_s19_to_C_array( input_file, variable_name, maxsize )
%FUNCTION c_array = target_s19_to_C_array( INPUT_FILE,  VARIABLE_NAME, MAXSIZE )
%
%Converts an s-record file to an C array with the specified variable name.
%Throws an error if the memory that the file represents occupies more than
%the number of bytes specified in maxsize

% Copyright 2005 The MathWorks, Inc.

% Count number of parameters and fail gracefully if wrong number passed
if nargin ~= 3
  TargetCommon.ProductInfo.error('common', 'NumInputArgsInvalid');
  return;
end

% Only accept full paths now
input_file_full = input_file;

max_to_read = 100000;

% Get a handle to the SFILE
try
    sfile = com.mathworks.toolbox.ecoder.srecord.SRecordFile(input_file_full, max_to_read);
catch
  TargetCommon.ProductInfo.error('common', 'S19FileNotFound', input_file_full);
  return;
end

% First Pass - just to get length of file
mem_end = 0;
while sfile.hasMoreRecords
    sr = sfile.nextRecord;
    mem_end_buffer = sr.address + length(sr.data) - 1 ;
    if mem_end_buffer > mem_end
        mem_end = mem_end_buffer;
    end
end

% Close the file
sfile.close;

% Check that the memory size is the correct length
% Each entry is a uint8 = 8 bits.  This each entry is 1 byte.
% If we specify the maximum size in bytes
if mem_end > maxsize
  TargetCommon.ProductInfo.error('common', 'S19OutOfMemoryRange');
  return;
end

% Set the memory layout to 0s
mem_layout = zeros(1, mem_end, 'uint16');

% Reopen the sfile again
try
    sfile = com.mathworks.toolbox.ecoder.srecord.SRecordFile(input_file_full, max_to_read);
catch
  TargetCommon.ProductInfo.error('common', 'S19FileNotFound', input_file_full);
  return;
end

% For each record in the file, decode and generate the binary image in RAM
while sfile.hasMoreRecords
    sr = sfile.nextRecord;
    addr1=sr.address + 1;
    addr2=sr.address + length(sr.data);
    if addr2~=0
        mem_layout( addr1:addr2 ) = typecast(int8(sr.data),'uint8');
    end
end

% Close the sfile
sfile.close;

% Define the variable to hold the data table
c_array = [sprintf(['const uint8_T ',variable_name,'[] =\n{\n'])];

% Display bytes individually

% Number of entries per row
numentriesperrow = 12;
% Number on last row (can be 0);
numonlastrow = mod(length(mem_layout),numentriesperrow);
% Number of rows is number of entries minus number on last row, divided by
% number of entries per row
numberofcompleterows = (length(mem_layout) - numonlastrow)/numentriesperrow;
% Number of incomplete rows is 1 if and only if there is an incomplete last
% row
if numonlastrow ~= 0
    numberofincompleterows = 1;
else
    numberofincompleterows = 0;
end

% Iterate through all the complete rows first
for curr_row=1:numberofcompleterows
    % Iterate through each column in the complete row
    for curr_col = 1:numentriesperrow
        % Append the next hexadecimal entry to the row
        c_array = [c_array, sprintf('0x%02x',mem_layout( (curr_row-1) * numentriesperrow + curr_col ) )];
        % A comma is needed after the entry in the following cases:
        %       1) We are in the middle of a row
        %       2) We are at the end of a row but we have not hit the
        %          complete number of full rows
        %       3) We are at the end of the row and have hit the complete
        %          number of full rows, and there is an incomplete row yet
        %          to populate
        if (curr_col ~= numentriesperrow) | ...
                (curr_row ~= numberofcompleterows) | ...
                ((curr_row == numberofcompleterows) & (numberofincompleterows ~= 0))
            c_array = [c_array, ', '];
        end
    end
    c_array = [c_array, sprintf('\n')];
end

if numberofincompleterows == 1
   for curr_col = 1:numonlastrow
       c_array = [c_array, sprintf('0x%02x',mem_layout( (numberofcompleterows) * numentriesperrow + curr_col ) )];
       if curr_col ~= numonlastrow
          c_array = [c_array, ', ']; 
       end
   end
   c_array = [c_array, sprintf('\n')];
end

% Close the definition
c_array = [c_array,sprintf('};\n')];

end
