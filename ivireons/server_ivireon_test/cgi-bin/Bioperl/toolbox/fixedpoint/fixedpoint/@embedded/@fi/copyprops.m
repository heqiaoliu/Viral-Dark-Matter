function copyprops(this,other)
%COPYPROPS(this,other)
%    COPYPROPS(THIS,OTHER) Copy all properties except for the data from
%    fi object THIS to fi object OTHER.  This is a way to get the same
%    data-type information without copying the data.

%   Thomas A. Bryan
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/12/20 07:12:01 $

this.Datatype            = other.Datatype;
this.Scaling             = other.Scaling;
this.Signed              = other.Signed;
this.Wordlength          = other.Wordlength;
this.Fractionlength      = other.Fractionlength;
this.Fimath              = fimath(other);
