function sys = utCheckSystem(sys,Ny,Nu)
% Checks validity of system meta data.
% NU and NY are the number of inputs and outputs
% derived from the numerical data (@ltidata objects).

%   Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 14:23:24 $
  
% Check InputName and OutputName are consistent with I/O size from data.
% Resize if necessary, but only when all names are blank. Otherwise
%     sys = ss(1,2,3,4); set(sys,'inputn',{'a','b'})
% would not error out.
if length(sys.InputName)~=Nu
   if all(strcmp(sys.InputName,''))
      % Blast input groups and reinitialize input names
      sys.InputGroup = struct;
      sys.InputName = repmat({''},[Nu 1]);
   else
      ctrlMsgUtils.error('Control:ltiobject:ltiProperties05')
   end
end

if length(sys.OutputName)~=Ny
   if all(strcmp(sys.OutputName,''))
      % Blast output groups and reinitialize output names
      sys.OutputGroup = struct;
      sys.OutputName = repmat({''},[Ny 1]);
   else
      ctrlMsgUtils.error('Control:ltiobject:ltiProperties06')
   end
end

% Check InputGroup 
try
   iGroups = getgroup(sys.InputGroup);
catch 
   iGroups = [];
end
if ~isa(iGroups,'struct') || ~isequal(size(iGroups),[1 1])
    ctrlMsgUtils.error('Control:ltiobject:ltiProperties07')
end
f = fieldnames(iGroups);
for ct=1:length(f)
   channels = iGroups.(f{ct});
   if ~isnumeric(channels) || ~isvector(channels) || ...
         isempty(channels) || size(channels,1)~=1 || ...
         ~isequal(channels,round(channels))
      ctrlMsgUtils.error('Control:ltiobject:ltiProperties08')
   elseif any(channels<1) || any(channels>Nu),
       ctrlMsgUtils.error('Control:ltiobject:ltiProperties09')
   elseif length(unique(channels))<length(channels)
       ctrlMsgUtils.error('Control:ltiobject:ltiProperties10')
   end
end

% Check OutputGroup 
try
   oGroups = getgroup(sys.OutputGroup);
catch 
   oGroups = [];
end
if ~isa(oGroups,'struct') || ~isequal(size(oGroups),[1 1])
    ctrlMsgUtils.error('Control:ltiobject:ltiProperties11')
end
f = fieldnames(oGroups);
for ct=1:length(f)
   channels = oGroups.(f{ct});
   if ~isnumeric(channels) || ~isvector(channels) || ...
         isempty(channels) || size(channels,1)~=1 || ...
         ~isequal(channels,round(channels))
     ctrlMsgUtils.error('Control:ltiobject:ltiProperties12')
   elseif any(channels<1) || any(channels>Ny),
       ctrlMsgUtils.error('Control:ltiobject:ltiProperties13')
   elseif length(unique(channels))<length(channels)
       ctrlMsgUtils.error('Control:ltiobject:ltiProperties14')
   end
end
