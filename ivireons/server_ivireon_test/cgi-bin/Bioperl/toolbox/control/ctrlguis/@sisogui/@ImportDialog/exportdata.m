function exportdata(this)
% Export data to sisotool

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/01/26 01:47:13 $


% Callback for OK button
ConfigData = this.Design;

% Refresh plant models associated with a variable name
% RE: Do not refresh compensator models (assumed "edited")
ImportList = this.ImportList;
for ct=1:length(ImportList)
   G = ImportList{ct};
   vname = ConfigData.(G).Variable;
   if ~isempty(vname)
      sys = evalin('base',vname,'[]');
      if ~isempty(sys)
         ConfigData.(G).Value = sys;
      end
   end
end

% % Refresh plant models associated with a variable name
% % RE: Do not refresh compensator models (assumed "edited")
% for ct=1:length(ConfigData.Fixed)
%    G = ConfigData.Fixed{ct};
%    vname = ConfigData.(G).Variable;
%    if ~isempty(vname)
%       sys = evalin('base',vname,'[]');
%       if ~isempty(sys)
%          ConfigData.(G).Value = sys;
%       end
%    end
% end
% 
% 
% 
% % Clear data for non-modified compensators
% % RE: Avoids overwriting unchanged C and losing structured
% %     PZ groups such as lead or real-valued complex pairs
% [CID,ia] = intersect(ConfigData.Tuned,fieldnames(this.CurrentData));
% for ct=1:length(CID)
%    C = CID{ct};
%    if isequal(ConfigData.(C).Value,this.CurrentData.(C).Value)
%       % Unchanged value
%       ConfigData.(C).Value = [];
%    end
% end

% Apply configuration settings
this.sisodb.configapply(ConfigData)
%this.Figure.Visible = 'off';