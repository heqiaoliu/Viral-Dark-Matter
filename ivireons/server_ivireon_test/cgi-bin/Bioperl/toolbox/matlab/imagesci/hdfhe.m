function varargout = hdfhe(varargin)
%HDFHE MATLAB gateway to the HDF HE interface.
%   HDFHE is a gateway to the HDF HE interface. 
%
%   The general syntax for HDFHE is
%   HDFHE(funcstr,param1,param2,...).  There is a one-to-one correspondence
%   between HE functions in the HDF library and valid values for funcstr.
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the operation
%   failed.
%
%     hdfhe('clear')
%       Clears all information on reported errors from the error stack.
%
%     hdfhe('print',level)
%       Prints information in error stack; if level is 0, the entire error
%       stack is printed.
%
%     error_text = hdfhe('string',error_code)
%       Returns the error message associated with the specified error code.
%
%     error_code = hdfhe('value',stack_offset)
%       Returns an error code from the specified level of the error stack;
%       stack_offset of 1 gets the most recent error code.
%
%   The HDF library functions HEpush and HEreport are not currently
%   supported by this gateway.
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%            HDFHX, HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8.2.1 $  $Date: 2010/06/24 19:34:18 $

% Call HDF.MEX to do the actual work.
ans = [];
if nargout>0
  [varargout{1:nargout}] = hdf('HE',varargin{:});
else
  hdf('HE',varargin{:});
end
if ~isempty(ans)
  varargout{1} = ans;
end
