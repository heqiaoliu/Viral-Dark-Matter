% Data types and structures.
%
% Data types (classes)
%   double          - Convert to double precision.
%   logical         - Convert numeric values to logical.
%   cell            - Create cell array.
%   struct          - Create or convert to structure array.
%   single          - Convert to single precision.
%   uint8           - Convert to unsigned 8-bit integer.
%   uint16          - Convert to unsigned 16-bit integer.
%   uint32          - Convert to unsigned 32-bit integer.
%   uint64          - Convert to unsigned 64-bit integer.
%   int8            - Convert to signed 8-bit integer.
%   int16           - Convert to signed 16-bit integer.
%   int32           - Convert to signed 32-bit integer.
%   int64           - Convert to signed 64-bit integer.
%   inline          - Construct INLINE object.
%   function_handle - Function handle array.
%   javaArray       - Construct a Java Array object.
%   javaMethod      - Invoke a Java method.
%   javaObject      - Invoke a Java object constructor.
%   javaMethodEDT   - Invoke a Java method on the Swing Event Dispatch Thread.
%   javaObjectEDT   - Invoke a Java object constructor on the Swing Event Dispatch Thread.
%
%   cast            - Cast a variable to a different data type or class.
%
% Class determination functions.
%   isnumeric       - True for numeric arrays.
%   isfloat         - True for floating point arrays, both single and double.
%   isinteger       - True for arrays of integer data type.
%   islogical       - True for logical array.
%
%   iscom           - true for COM/ActiveX objects.
%   isinterface     - true for COM Interfaces.
%
% Cell array functions.
%   cell            - Create cell array.
%   celldisp        - Display cell array contents.
%   cellplot        - Display graphical depiction of cell array.
%   cell2mat        - Convert the contents of a cell array into a single matrix.
%   mat2cell        - Break matrix up into a cell array of matrices.
%   num2cell        - Convert numeric array into cell array.
%   deal            - Deal inputs to outputs.
%   cell2struct     - Convert cell array into structure array.
%   struct2cell     - Convert structure array into cell array.
%   iscell          - True for cell array.
%
% Array functions.
%   arrayfun        - Apply a function to each element of an array.
%   cellfun         - Apply a function to each cell of a cell array.
%   structfun       - Apply a function to each field of a scalar structure.
%
% Structure functions.
%   struct          - Create or convert to structure array.
%   fieldnames      - Get structure field names.
%   getfield        - Get structure field contents.
%   setfield        - Set structure field contents.
%   rmfield         - Remove fields from a structure array.
%   isfield         - True if field is in structure array.
%   isstruct        - True for structures.
%   orderfields     - Order fields of a structure array.
%
% Function handle functions.
%   @               - Create function_handle; use "help function_handle".
%   func2str        - Construct a string from a function handle.
%   str2func        - Construct a function_handle from a function name string.
%   functions       - List functions associated with a function_handle.
%
% Byte manipulation functions.
%   swapbytes       - Swap byte ordering, changing endianness.
%   typecast        - Convert datatypes without changing underlying data.
%
% Object oriented programming functions.
%   class           - Create object or return object class.
%   classdef        - Define a new MATLAB class.
%   struct          - Convert object to structure array.
%   methods         - Display class method names.
%   methodsview     - View names and properties of class methods.
%   properties      - Display class property names.
%   events          - Display class event names.
%   enumeration     - Display class enumerated value names.
%   superclasses    - Display names of the superclasses of a given class.
%   isa             - True if object is a given class.
%   isjava          - True for Java object arrays
%   isobject        - True for MATLAB objects.
%   inferiorto      - Inferior class relationship.
%   superiorto      - Superior class relationship.
%   substruct       - Create structure argument for SUBSREF or SUBSASGN.
%   ismethod        - True if method of an object.
%   isprop          - Returns true if the property exists
%   metaclass       - Metaclass for MATLAB class
%
%   loadobj         - Called when loading an object from a .MAT file.
%   saveobj         - Called when saving an object to a .MAT file.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.38.4.12 $  $Date: 2009/04/15 23:17:40 $
