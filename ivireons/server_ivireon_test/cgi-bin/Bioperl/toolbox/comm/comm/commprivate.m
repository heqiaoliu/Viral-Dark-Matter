function varargout = commprivate(varargin)
%COMMPRIVATE This function allows access to the functions in the private dir.
%        COMMPRIVATE('FOO',ARG1,ARG2,...) is the same as
%        FOO(ARG1,ARG2,...).  

%     Copyright 1996-2010 The MathWorks, Inc.
%     $Revision: 1.6.4.3 $  $Date: 2010/05/20 01:57:59 $

%#function berlekamp betacdf betainv betapdf binofit checkDictValidity dec2oct distchck finv idealQAMConst is isgfvector isoctal 

if (nargout == 0)
  feval(varargin{:});
else
  [varargout{1:nargout}] = feval(varargin{:});
end
