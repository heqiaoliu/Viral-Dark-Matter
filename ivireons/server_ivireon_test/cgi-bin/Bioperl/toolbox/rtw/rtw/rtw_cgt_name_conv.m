function outName = rtw_cgt_name_conv(inName,direction)
% RTW automatically converts .cgt files to .tlc file.  The convention
% is to convert file.cgt to file_cgt.tlc.  This function performs the
% necessary conversion in the direction: 'cgt2tlc'.
%
% A conversion is not performed if it does not match the convention.
% For example, rt_cgt_name_conv('foo.tlc','cgt2tlc') returns foo.tlc.
%
% Args:
%   inName    - File name to convert
%   direction - 'cgt2tlc'
%
% Returns:
%   outName   - Converted file name

% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $
  
  switch direction
    case 'cgt2tlc'
      [path,file,ext] = fileparts(inName);
      if isequal(ext,'.cgt')
          outName = fullfile(path,[file,'_cgt.tlc']);
      else
          outName = inName;
      end
    case 'tlc2cgt'
      pattern = '_cgt.tlc';
      len = length(pattern);
      if length(inName) > len && strcmp(inName(end-len+1:end),pattern)
          outName = [inName(1:end-len) '.cgt'];
      else
          outName = inName;
      end
    otherwise
      DAStudio.error('RTW:utility:invalidInputArgs',direction); 
  end
    
  
