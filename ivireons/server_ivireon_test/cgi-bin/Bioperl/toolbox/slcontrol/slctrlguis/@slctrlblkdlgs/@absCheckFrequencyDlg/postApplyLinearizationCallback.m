function [status, errmsg] = postApplyLinearizationCallback(this,dlg)

% Author(s): A. Stothert 12-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:40 $

% POSTAPPLYLINEARIZATIONCALLBACK manage post apply actions for the
% linearization tab
%

blk = getFullName(this.getBlock);

%Push DDG class properties set during preApplyLinearizationCallback to the
%block
if ~isa(this.LinearizationIOs,'linearize.IOPoint')
   %Block is not getting IO points from workspace variable so update
   str = localSerializeIOs(this.LinearizationIOs);
   set_param(blk,'LinearizationIOs',str);
end

%Set return arguments
status = true;
errmsg = '';
end

function str = localSerializeIOs(data)
%Helper function to serialize linio object for storage as a check block
%parameter.

str   = '{';
nrows = size(data,1);
for ct = 1:nrows
   str = sprintf('%s''%s'', %d, ''%s'', ''%s''',str,...
      data{ct,1}, data{ct,2}, data{ct,3}, data{ct,4});
   if ct < nrows
      str = sprintf('%s;',str);
   end
end
str = sprintf('%s}',str);
end