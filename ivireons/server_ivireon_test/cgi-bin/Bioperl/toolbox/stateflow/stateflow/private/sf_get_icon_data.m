function data = sf_get_icon_data(type)
%
% Reads icon data from file.
%

%   Jay Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.9.2.3 $  $Date: 2008/12/01 08:07:20 $

%
% try bitmap first
%
filename = [sf_root,'private',filesep,type,'.bmp'];

if isequal(exist(filename, 'file'), 2),
	try data = imread(filename,'bmp');
	catch, error('Stateflow:UnexpectedError',['Problem loading icon for class: ',type]);
	end;
else
	%
	% try MAT-file next
	%
	filename = [sf_root,'private',filesep,type,'.mat'];
	try load(filename);
	catch, error('Stateflow:UnexpectedError',['Problem loading icon for: ',type]);
	end;
end;

