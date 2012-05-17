function setDefaultName(this,WaveList)
%SETDEFAULTNAME  Assigns default name to unnamed waveforms.

%  Author(s): P. Gahinet
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:28:07 $

% Resolve wave name
if isempty(this.Name)
   % Assign untitled## name when name is unspecified
   Names = get(WaveList,{'Name'});
   Names = [Names{:}];
   n = 1;
   while ~isempty(strfind(Names,sprintf('untitled%d',n)))
      n = n+1;
   end
   this.Name = sprintf('untitled%d',n);
end

set(this.Group,'DisplayName', strrep(this.Name,'_','\_'));