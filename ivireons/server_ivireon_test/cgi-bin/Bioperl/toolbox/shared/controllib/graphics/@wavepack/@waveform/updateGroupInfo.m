function updateGroupInfo(this,varargin)
% UPDATEGROUPINFO Updates waveform groups legend info

%  Author(s): C. Buhr
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:28:09 $

this.DoUpdateName = false;
if isempty(varargin)
    dispname = this.name;
else
    dispname = varargin{1};
end

dispname = strrep(dispname,'_','\_');

grp = this.Group;

ax = getaxes(this);
[nu,ny] = size(getaxes(this));

for gct = 1:length(grp);
   set(grp(gct),'DisplayName',dispname)

   GroupLegendInfo = this.Style.GroupLegendInfo;
   if strcmpi(GroupLegendInfo.type, 'text')
       Fsize = get(ax(gct),'FontSize');
       Funits = get(ax(gct),'FontUnits');
       GroupLegendInfo.props = cat(2,GroupLegendInfo.props,{'FontUnits', Funits, ...
           'FontSize', Fsize});
   end
   legendinfo(grp(gct),GroupLegendInfo);  
   hA = get(grp(gct),'Annotation');
   if ishandle(hA)
       hL = hA.LegendInformation;
       if ishandle(hL)
           hL.IconDisplayStyle = 'on';
       end
   end
 
end
this.Group = grp;
this.DoUpdateName = true;
