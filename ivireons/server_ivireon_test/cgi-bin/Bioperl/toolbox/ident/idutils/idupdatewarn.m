function idupdatewarn(obj)
%UPDATEWARN  output a warning when LOADOBJ routines are called

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/10/16 04:56:42 $

persistent last_old_object;

str = '';
if isa(obj,'idmodel')
    str = 'model';
end

if isempty(last_old_object) || (etime(clock, last_old_object) > 1)
   ctrlMsgUtils.warning('Ident:utility:IdentObjectUpdate',str)
end
last_old_object = clock;
