%GETMCRUSERDATA Retrieve MCR instance-specific data.
%   GETMCRUSERDATA(KEY) Return the MATLAB data associated with the 
%      string KEY in the current MCR instance. Returns an empty matrix 
%      if there is no data associated with the key.  This function is
%      available both in MATLAB and in deployed applications created with 
%      the MATLAB Compiler or one of the Builders. 
%
%      The key must be a string. The value retrieved may be any valid 
%      MATLAB data type, including matrices, cell arrays and Java objects.
%
%          value = getmcruserdata(key);
%
%      GETMCRUSERDATA returns a copy of the stored data. To modify the
%      value associated with a given key, first retrieve it with 
%      GETMCRUSERDATA, then modify it, then place it back in the data store
%      with SETMCRUSERDATA. 
%
%          value = magic(3);
%          setmcruserdata('magic', value);
%          value = getmcruserdata('magic');
%          value(2,2) = 17;
%          setmcruserdata('magic', value);
%
%   See also SETMCRUSERDATA.

%   Copyright 2008, The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/06/24 17:12:10 $
%   Built-in function.
