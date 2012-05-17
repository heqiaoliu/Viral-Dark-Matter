%inputParser Construct input parser object
%   PARSEOBJ = inputParser constructs an empty inputParser object, PARSEOBJ. 
%   This utility object supports the creation of an input scheme that
%   represents the characteristics of each potential input argument. Once
%   you have defined the input scheme, you can use the inputParser object
%   to parse and validate input arguments to functions.
%
%   The inputParser object follows handle semantics; that is, methods called on
%   it affect the original object, not a copy of it. Also note that inputParser
%   method names begin with a lowercase letter (e.g., addRequired) while
%   inputParser property names begin with an uppercase letter (e.g., Unmatched).
%
%   parse(PARSEOBJ, INPUT1, INPUT2, ...) parses and validates the named inputs
%   INPUT1, INPUT2, etc.
%
%   MATLAB configures inputParser objects to recognize an input scheme.
%   Use any of the following methods to create the scheme for parsing a
%   particular function.
%
%   addRequired(PARSEOBJ, ARGNAME, VALIDATOR) adds required argument
%   ARGNAME to the input scheme of object PARSEOBJ.  ARGNAME is a single-
%   quoted string that specifies the name of the required argument.
%   The optional VALIDATOR is a handle to a function that you write, used
%   during parsing to validate the input arguments.  If the VALIDATOR
%   throws an error or returns logical 0 (FALSE), the parsing fails and
%   MATLAB throws an error.
%
%   addOptional(PARSEOBJ, ARGNAME, DEFAULT, VALIDATOR) adds optional argument
%   ARGNAME to the input scheme of object PARSEOBJ. DEFAULT specifies the
%   value to use when the optional argument ARGNAME is not present in the
%   actual inputs to the function. The optional VALIDATOR input is the same
%   as for addRequired.
%
%   addParamValue(PARSEOBJ, PARAMNAME, DEFAULT, VALIDATOR) adds parameter
%   name/value argument PARAMNAME to the input scheme of object PARSEOBJ. 
%   Parameter name/value pair arguments are parsed after required and
%   optional arguments. The PARAMNAME input is a single-quoted string that
%   specifies the parameter name and is the name of the parameter in the
%   results structure that is created when parsing.   The DEFAULT input
%   specifies the value to use when the optional argument NAME is not
%   present in the actual inputs to the function.  The optional VALIDATOR
%   input is the same as for ADDREQUIRED.
%
%   createCopy(PARSEOBJ) creates a copy of the inputParser.  The
%   inputParser uses handle semantics, so a normal assignment does not
%   create a copy.
%
%   Properties:
%       Results         -  Structure array.  The results of the last parse.
%       Each known parameter is represented by a field in the structure.
%       The name of the field is the name of the parameter and the value
%       stored in the field is the value of the input.       
%
%       KeepUnmatched   -  Scalar logical. If TRUE, inputs that do not
%       match the input scheme are added to the UNMATCHED property.  If 
%       FALSE (default), MATLAB throws an error if an input that does not
%       match the scheme is found.
%
%       CaseSensitive -  Scalar logical. If TRUE, parameters are matched
%       case sensitively.  If FALSE (default), matching is case
%       insensitive.  
% 
%       StructExpand    -  Scalar logical.  If TRUE (default), the PARSE
%       method accepts a structure as an input in place of param-value
%       pairs (INPUT1, INPUT2, etc.). If FALSE, a structure is treated as a
%       regular, single input.
% 
%       FunctionName    -  Char array.  The function name that is used in
%       error messages thrown by the validating functions.
% 
%       Parameters      -  Cell array of strings.  A list of the parameters
%       in the input parser. Each row is a string containing the full name
%       of a known parameter.
% 
%       Unmatched       -  Structure array in the same format as the
%       Results. If KeepUnmatched is TRUE, this will contain the list of
%       inputs that did not match any parameters in the input scheme.
%
%       UsingDefaults   -  Cell array of strings.  A list of the parameters
%       that were not set by the user and, consequently, are using their
%       default values.
%
%   Example:
%      p = inputParser; 
%
%      p.addRequired('a'); 
%      p.addOptional('b',1);
%      p.addParamValue('c',2);
%
%      p.parse(10, 20, 'c', 30);
%      res = p.Results
%
%   Returns a structure:
%      res = 
%         a: 10
%         b: 20
%         c: 30
%
%   See also validateattributes, validatestring.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:24:19 $

