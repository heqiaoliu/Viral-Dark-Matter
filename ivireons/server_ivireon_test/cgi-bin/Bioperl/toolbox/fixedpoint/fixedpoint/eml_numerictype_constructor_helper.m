function [T,ERR] = eml_numerictype_constructor_helper(maxWL,varargin)
% EML_NUMERICTYPE_CONSTRUCTOR_HELPER Helper function for eML to construct a
% numerictype object.

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2009/05/14 16:53:34 $

ERR = ''; T = [];
try
  T = numerictype(varargin{:});
  % Check the Numerictype's "DataType" property and error out if it is
  % 'boolean' or 'ScaledDouble'
  if strcmpi(T.DataType,'boolean')  || strcmpi(T.DataType,'ScaledDouble')
      ERR = ['Numerictype DataTypeMode = ''' T.DataType ''' is not supported in Embedded MATLAB'];
      return;
  end
  % Check the Numerictype's WordLength and error is > 32 bits
  if strcmpi(T.DataType,'Fixed') && (T.WordLength > double(maxWL))      
      ERR = sprintf('Invalid WordLength specified; the WordLength must be less than %d bits.', double(maxWL)+1);    
      return;
  end
catch ME
  ERR = ME.message;
end



