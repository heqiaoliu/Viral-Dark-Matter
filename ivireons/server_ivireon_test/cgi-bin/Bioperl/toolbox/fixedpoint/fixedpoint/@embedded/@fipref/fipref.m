function this = fipref(varargin)
%FIPREF Fixed-point preferences object
%   P = FIPREF returns a fixed-point preferences object.
%
%   Refer to FIPREF for detailed documentation
%
%   See also FIPREF 


%   Thomas A. Bryan, 6 March 2003
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2006/12/20 07:13:15 $

persistent FIPREF_PERSISTENT;

if isa(FIPREF_PERSISTENT,'embedded.fipref')
  % Use the one created in this session.
  this = FIPREF_PERSISTENT;
elseif ispref('embedded','fipref')
  % Use the one stored in the preferences file.
  thisstruct = struct(getpref('embedded','fipref'));
  this = embedded.fipref;
  set(this,thisstruct);
  FIPREF_PERSISTENT = this;
else
  % Create a new one, and add it to the preferences file.
  this = embedded.fipref;
  addpref('embedded','fipref',struct(this));
  FIPREF_PERSISTENT = this;
end

if nargin>0
  % New settings from the input arguments.
  if isfipref(varargin{1})
    this = varargin{1}; % fipref is a singleton reference object
    set(this,varargin{2:end});
  else
    set(this,varargin{:});
  end
  FIPREF_PERSISTENT = this;
end

mlock;
