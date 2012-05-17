function out = valid(cvdata)
% Determine if the cvdata object represents active up-to date data.
% Invalid data results when a model is closed or a model is changed
% between simulations.


	out = false;
	id = cvdata.id;
	
	if (id ~= 0) && (~cv('ishandle', id) || cv('get',id,'.isa')~= cv('get','default','testdata.isa'))
		return;
	end

	prop.type = '.';
	prop.subs = 'rootId';

	rootId = subsref(cvdata,prop);

	if  isequal(rootId,0) || isempty(cv('ishandle', rootId)) || ...
	   ~isequal(cv('get',rootId,'.isa'), cv('get','default','root.isa')) || ...
	   isequal(cv('get',rootId,'.treeNode.parent'), 0)
		return;
	end
	
	out = true;

	

