function hinfo = hdfquickinfo(filename,dataname)
%HDFQUICKINFO scan HDF file
%
%   HINFO = HDFQUICKINFO(FILENAME,DATANAME) scans the HDF file FILENAME for
%   the data set named DATANAME.  HINFO is a structure describing the data
%   set.  If no data set is found an empty structure is returned.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/04/15 15:25:54 $

found = 0;
hinfo = struct([]);

%Search for EOS data sets first because they are wrapers around HDF data
%sets

%Grid data set
if ~found
	[found, hinfo] = findInsideGrid ( filename, dataname );
end

%Swath data set
if ~found
	[found, hinfo] = findInsideSwath ( filename, dataname );
end

%Point data set
if ~found
	[found, hinfo] = findInsidePointDataSet ( filename, dataname );
end

% Read data (SD or Vdata set) inside a Vgroup
if ~found
	[found, hinfo] = findInsideVgroup ( filename, dataname );
end


%Scientific Data Set
if ~found
	[found, hinfo] = findInsideSD ( filename, dataname );
end


%Vdata set
if ~found
	[found, hinfo] = findInsideVdata ( filename, dataname );
end

%8-bit Raster Image
if ~found
	[found, hinfo] = findInside8bitRasterImage ( filename, dataname );
end

%24-bit Raster
if ~found
	[found, hinfo] = findInside24bitRasterImage ( filename, dataname );
end



return;




%--------------------------------------------------------------------------
function [parentID, dataname] = findVgroupInPath(fileID,dataname,vgroupID)
% Find a parent vgroup in the supplied path.
parentID = -1;
if nargin==2
    % vgroup is empty.  Open the root vgroup and call ourselves again.
    if dataname(1)=='/' % The root directory
        dataname(1) = '';
    end
    [head dataname] = splitPathname(dataname);
    if isempty(head)
        return
    end
    ref = hdfv('find', fileID, head);
    vgroupID = hdfv('attach',fileID, ref, 'r');
    % Return the parent ID.
    [parentID, dataname] = findVgroupInPath(fileID, dataname, vgroupID);
else
    [head dataname] = splitPathname(dataname);
    if isempty(head)
        % If there are no subdirectories, we are done.            
        parentID = vgroupID;
        return
    end
    % Open the next vgroup
    vgroupID = findVgroupFromName(fileID, vgroupID, head);
    if vgroupID ~= -1
        % Attempt to open further Vgroups, if possible.
        [parentID, dataname] = findVgroupInPath(fileID, dataname, vgroupID);
    end
end

if parentID ~= vgroupID 
    % release all vgroup ID's except for the last one.
    hdfv('detach', vgroupID);
end



function [head dataname] = splitPathname(dataname)
% Get the head of a pathname (vgroup name)
pathLoc = strfind(dataname, '/');
if ~isempty(pathLoc)
    head = dataname(1:pathLoc(1)-1);
    dataname = dataname(pathLoc(1)+1:end);
else
    head = [];
end

function [childID] = findVgroupFromName(fileID, vgroupID, dirName)
% Get a Vgroup with a given dirName (from inside a VGroup).
vgroupRef = -1;
while true
    % Get the next vgroup in the file
    vgroupRef = hdfv('getid', fileID, vgroupRef);
    if vgroupRef==-1
        break;
    end
    % If they are not a child of vgroupID, keep looking.
    if ~hdfv('isvg', vgroupID, vgroupRef)
        continue;
    end
    % Open the vgroup, and if the names match, we are done.
    childID = hdfv('attach', fileID, vgroupRef, 'r');
    [vgroup_name, status] = hdfv('getname', childID);
	if status ~= 0
		hdfv('end',fileID);
		hdfh('close',fileID);
		error ( 'MATLAB:HDF:getname', 'failed on childID %d', childID ); 
	end
    if strcmp(vgroup_name, dirName)
        return
    end
    hdfv('detach', childID);
end
childID = -1;






%--------------------------------------------------------------------------
function [found, hinfo] = findInsideVgroup ( filename, dataname )

found = 0;
hinfo = [];

fileID = hdfh('open',filename,'read',0);
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
anID = hdfan('start',fileID);


% Open the required interfaces and find the parent vgroup (if any).
hdfv('start',fileID);
sdID = hdfsd('start',filename,'read');
[parentID, dataname] = findVgroupInPath(fileID, dataname);
count = hdfv('ntagrefs', parentID);
% Iterate over each child
for i=0:count-1
    if found
        break
    end
    % Find out the type of the child
    [tag,ref,status] = hdfv('gettagref', parentID,i);
	if status ~= 0
		hdfsd('end',sdID);
		hdfv('end',fileID);
		hdfan('end',anID);
		hdfh('close',fileID);
		error ( 'MATLAB:HDF:gettagref', 'failed on tag %d', i ); 
	end

    bVG = hdfv('isvg', parentID, ref);
    bVS = hdfv('isvs', parentID, ref);
    bSDS = ~bVG && ~bVS;
    % handle the case where it is VDATA
    if( bVS ) 
        % Read the VDATA name.
        vdata_id = hdfvs('attach', fileID, ref, 'r');
        vdataName = hdfvs('getname', vdata_id);
        if strcmp(vdataName, dataname)
            found = 1;
            hinfo = hdfvdatainfo(filename, fileID, anID, ref);
        end
        hdfvs('detach',vdata_id);
        % Handle the case where it is Scientific Data
    elseif( bSDS ) 
        % Read the SDS name.
        if ((tag==hdfml('tagnum','DFTAG_NDG')) ...
                || (tag==hdfml('tagnum','DFTAG_SD')))
            index = hdfsd('reftoindex', sdID, ref);
            sdsID = hdfsd('select', sdID, index);
            sdsName = hdfsd('getinfo', sdsID);
            if strcmp(sdsName, dataname)
                found = 1;
                hinfo = hdfsdsinfo(filename, sdID, anID, index);
            end
            hdfsd('endaccess', sdsID);
        end
    end
end
if parentID > 0
    hdfv('detach', parentID);
end
hdfsd('end',sdID);
hdfan('end',anID);
hdfv('end',fileID);
hdfh('close',fileID);

return




%--------------------------------------------------------------------------
function [found, hinfo] = findInsideGrid ( filename, dataname )

found = false;
hinfo = [];
numgrids = hdfgd('inqgrid',filename);
if numgrids == 0
    return
end
fileID = hdfgd('open',filename,'read');
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
gridID = hdfgd('attach',fileID,dataname);
if gridID~=-1
    found = 1;
    hinfo = hdfgridinfo(filename,fileID,dataname);
    hdfgd('detach',gridID);
end
hdfgd('close',fileID);

return




%--------------------------------------------------------------------------
function [found, hinfo] = findInsideSwath ( filename, dataname )
found = false;
hinfo = [];
numswaths = hdfsw('inqswath',filename);
if numswaths==0
    return
end
fileID = hdfsw('open',filename,'read');
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
swathID = hdfsw('attach',fileID,dataname);
if swathID~=-1
        found = 1;
        hinfo = hdfswathinfo(filename,fileID,dataname);
        hdfsw('detach',swathID);
end
hdfsw('close',fileID);
return



%--------------------------------------------------------------------------
function [found, hinfo] = findInsidePointDataSet ( filename, dataname )
found = false;
hinfo = [];
numpoint = hdfpt('inqpoint',filename);
if numpoint == 0
    return
end
fileID = hdfpt('open',filename,'read');
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
pointID = hdfpt('attach',fileID,dataname);
if pointID~=-1
        found = 1;
        hinfo = hdfpointinfo(filename,fileID,dataname);
        hdfpt('detach',pointID);
end
hdfpt('close',fileID);
return




%--------------------------------------------------------------------------
function [found, hinfo] = findInsideSD ( filename, dataname )

%
% If given something like "/varname", then the slash just means
% that varname is part of the root group.  We need to remove
% the slash.
if ( dataname(1) == '/' )
    dataname(1) = '';
end

found = false;
hinfo = [];
sdID = hdfsd('start',filename,'read');
fileID = hdfh('open',filename,'read',0);
if (fileID<0 || sdID<0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
anID = hdfan('start',fileID);
index = hdfsd('nametoindex',sdID,dataname);
if index~=-1
    found = 1;
    hinfo = hdfsdsinfo(filename,sdID,anID,dataname);
end
%Close interface
hdfsd('end',sdID);
hdfan('end',anID);
hdfh('close',fileID);
return



%--------------------------------------------------------------------------
function [found, hinfo] = findInsideVdata ( filename, dataname )

%
% If given something like "/varname", then the slash just means
% that varname is part of the root group.  We need to remove
% the slash.
if ( dataname(1) == '/' )
    dataname(1) = '';
end

found = false;
hinfo = [];
fileID = hdfh('open',filename,'read',0);
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
anID = hdfan('start',fileID);
hdfv('start',fileID);
ref = hdfvs('find',fileID,dataname);
if ref~=0
    found = 1;
    hinfo = hdfvdatainfo(filename,fileID,anID,ref);
end
hdfv('end',fileID);
hdfan('end',anID);
hdfh('close',fileID);

return





%--------------------------------------------------------------------------
function [found, hinfo] = findInside8bitRasterImage ( filename, dataname )
found = false;
hinfo = [];

fileID = hdfh('open',filename,'read',0);
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
anID = hdfan('start',fileID);

[name,ref] = strtok(dataname,'#');
if strcmp('8-bit Raster Image ',name)
    %Strip off # sign
    ref = sscanf(ref(2:end), '%d');
    hinfo = hdfraster8info(filename,ref,anID);
    if ~isempty(hinfo)
       found = 1;
    end
end

hdfan('end',anID);
hdfh('close',fileID);

return




%--------------------------------------------------------------------------
function [found, hinfo] = findInside24bitRasterImage ( filename, dataname )
found = false;
hinfo = [];

fileID = hdfh('open',filename,'read',0);
if (fileID < 0)
    error('MATLAB:HDF:invalidFile', ...
          'HDF file ''%s'' may be invalid or corrupt.', filename);     
end
anID = hdfan('start',fileID);

[name,ref] = strtok(dataname,'#');
if strcmp('24-bit Raster Image ',name)
    %Strip off # sign
    ref = sscanf(ref(2:end), '%d');
    hinfo = hdfraster24info(filename,ref,anID);
    if ~isempty(hinfo)
       found = 1;
    end
end

hdfan('end',anID);
hdfh('close',fileID);

return



