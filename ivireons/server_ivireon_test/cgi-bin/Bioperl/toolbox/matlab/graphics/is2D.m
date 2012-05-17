function [retval] = is2D(ax)
% Internal use only. This function may be removed in a future release.

% Copyright 2002-2005 The MathWorks, Inc.

%IS2D Return true if axes is 2-D

% For now, just consider x-y plots. A more generic version is 
% commented out below.
VIEW_2D = [0,90];
ax_view = get(ax,'View');
camUp = get(ax,'CameraUpVector');
if iscell(ax_view)
    % ToDo: replace for loop with cellfun
   for n = 1:length(ax_view)
      retval(n) = isequal(ax_view{n},VIEW_2D) && isequal(abs(camUp{n}),[0 1 0]);
   end
else
    retval = isequal(ax_view,VIEW_2D) && isequal(abs(camUp),[0 1 0]); 
end
   

%--Uncomment this code for generic 2-D plot support--%

%test to see if viewing plane is parallel to major axis (x,y, or z)
%test1 = logical(sum(campos(ax)-camtarget(ax)==0)==2);
% 
% % test to see if upvector is orthogonal to primary axes
% if (test1)
%     cup = camup(ax);
%     I = find(( (campos(ax)-camtarget(ax)) ==0 )==1);
%     test2 = sum(cup(I)~=0)~=2;
%      
%     % test to see if projection is orthographic
%     if(test2)
%         retval = strcmpi(get(ax,'Projection'),'Orthographic');
%     end
% end


