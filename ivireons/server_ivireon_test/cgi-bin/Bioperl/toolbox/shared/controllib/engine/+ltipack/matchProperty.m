function PropName = matchProperty(InputStr,PublicProps,ClassName)
% Matches property name against public property list.
%
%   PROPERTY = MATCHPROPERTY(STR,PROPLIST,CL) performs a case-insensitive, 
%   partial matching of the string STR name against the list of properties
%   PROPLIST for the class CL. If there is a unique match, PROPERTY contains 
%   the full name of the matching property. Otherwise an error message is 
%   issued. 

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:54 $
imatch = find(strncmpi(InputStr,PublicProps,length(InputStr)));

% Get matching property name
switch length(imatch)
case 0
   % No hit
   ctrlMsgUtils.error('Control:utility:pnmatch2',ClassName,InputStr)
case 1
   % Single hit
   PropName = PublicProps{imatch};
otherwise
   % Multiple hits. Take shortest match provided it is contained
   % in all other matches (Xlim and XlimMode as matches is OK, but 
   % InputName and InputGroup is ambiguous)
   [minlength,imin] = min(cellfun(@length,PublicProps(imatch)));
   PropName = PublicProps{imatch(imin)};
   if ~all(strncmpi(PropName,PublicProps(imatch),minlength)),
       ctrlMsgUtils.error('Control:utility:pnmatch3',InputStr)
   end
end

