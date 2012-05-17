function B = saveobj(obj)
%SAVEOBJ Save filter for audioplayer objects.
%
%    B = SAVEOBJ(OBJ) is called by SAVE when an audioplayer object is
%    saved to a .MAT file. The return value B is subsequently used by
%    SAVE to populate the .MAT file.
%
%    See also AUDIOPLAYER/LOADOBJ.

%    JCS
%    Copyright 2003-2005 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2007/07/26 19:28:58 $

% Get the properties of the audioplayer object.
props = get(obj);

% Convert any property that may contain user specified data to 
% their respective SAVEOBJ structures so they are properly saved.
props.UserData = localSaveUserData(props.UserData);
props.StartFcn = localSaveUserData(props.StartFcn);
props.StopFcn = localSaveUserData(props.StopFcn);
props.TimerFcn = localSaveUserData(props.TimerFcn);

% Save these properties as the internal object which is a private member.
% We are purposefully destroying the internal object here as a
% convenience for saving out the properties.
obj.internalObj = props;

% Because obj is an audioplayer object, its other private field, signal
% will be saved out when obj is saved.
B = obj;

% **************************************
function out = localSaveUserData(input)
%Recursively saves an object's UserData.

if ( iscell(input) )
    % For cell arrays, recursively convert each cell element
    [m,n] = size(input);
    out = cell(m,n);
    for i=1:m
        for j=1:n
            out{i,j} = localSaveUserData( input{i,j} );
        end
    end
elseif ( isstruct(input) )
    % For structures, recursively convert each field value.
    fields = fieldnames(input);
    for f = 1:length(fields)
        fieldvalue = localSaveUserData( input.(fields{f}) );
        out.(fields{f}) = fieldvalue;
    end
else
    out = localInvokeSaveObj(input);
end

% **************************************
function out = localInvokeSaveObj(input)
% Helper function that converts non-cell and non-structs
% to their native SAVEOBJ structure.

try
    out = saveobj(input);
catch
    % If SAVEOBJ failed, nothing left to do except just return input.
    out = input;
end
