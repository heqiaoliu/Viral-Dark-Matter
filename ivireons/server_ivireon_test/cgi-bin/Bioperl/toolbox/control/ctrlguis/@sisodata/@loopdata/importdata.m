function importdata(this,Design)
%IMPORTDATA  Imports plant and compensator data.
%
%   Design is a @Design instance that contains data for
%   the fixed and tuned components. Imported data includes
%   model name and model value. To skip a particular component, 
%   set its Value to [].

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.24.4.3 $  $Date: 2006/01/26 01:46:49 $


% Check that data is valid (may throw an error)

% Revisit
[Design,Ts] = checkdata(this,Design);

% Notify peers of first import
if isempty(this.Plant)
   % Enable GUI functionality
   this.send('FirstImport')
end

% Import compensator data
for ct=1:length(Design.Tuned)
   Cdata = Design.(Design.Tuned{ct});
   this.C(ct).import(Cdata);
   this.C(ct).Ts = Ts;
end
   
% Import plant data
% RE: After comp. data because setting P for config=0 will trigger
%     ConfigChanged event that may access compensator data
for ct=1:length(Design.Fixed)
   Gdata(ct,1) = Design.(Design.Fixed{ct});
   Gdata(ct,1).Value.Ts = Ts;
end
this.Plant.import(Gdata);

% Import Loops data
for ct=1:length(Design.Loops)
   Ldata = Design.(Design.Loops{ct});
   this.L(ct).Ts = Ts;
   this.L(ct).Identifier = Design.Loops{ct};
   this.L(ct).import(Ldata,this);
end


% Update overall loop sample time
this.Ts = Ts;
