%ISFIELD True if field is in structure array.
%   ISFIELD(S,FIELD) returns true if the string FIELD is the name of a
%   field in the structure array S.
%
%   TF = ISFIELD(S,FIELDNAMES) returns a logical array, TF, the same size
%   as the size of the cell array FIELDNAMES.  TF contains true for the
%   elements of FIELDNAMES that are the names of fields in the structure
%   array S and false otherwise.
%
%   NOTE: TF is false when FIELD or FIELDNAMES are empty.
%
%   Example:
%      s = struct('one',1,'two',2);
%      fields = isfield(s,{'two','pi','One',3.14})
%
%   See also GETFIELD, SETFIELD, FIELDNAMES, ORDERFIELDS, RMFIELD,
%   ISSTRUCT, STRUCT. 

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.13.4.4 $  $Date: 2005/06/09 04:38:31 $


