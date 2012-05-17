/*
 * DMI.INC - DOORS/MATLAB Interface Functions
 *
 * Contains function definitions for all services provided by DOORS/MATLAB
 * interface.
 *
 * $Revision: 1.1.6.15.2.1 $
 * Copyright 1990-2010 The MathWorks, Inc.
 *
 */


Module dmiSurrogateM_ = null
Skip   dmiSurrogateS_ = createString
Object dmiPrevObjPtr_ = null
Object dmiActiveObj   = null
Object dmiLastExportObj = null
OleAutoObj dmiMatlab_ = null
string dmiResult_     = null
DB dmiSimulationDB_   = null
DB dmiBrowseDB_   = null
DBE dmiScriptDBE_     = null
DBE dmiResultsDBE_    = null
char    dmiCSVDoubleQuote   = `\"'
Buffer  dmiCSVBuffer = create
Regexp  dmiCSVQuotes1
Regexp  dmiCSVQuotes2
const   Regexp  dmiCSVRealReg   = regexp " *(-|+|)[0-9]*(\\.|)[0-9]* *";
const   Regexp  dmiCSVAnything  = regexp ".*"

int     dmiFirstNewObj    // corresponds to -1 from update
int     dmiCSVLineNum
int     dmiStatusCnt


/******************************************************************************/
const string DMI_VERSION = "3.12"  /*** VERSION (MUST be MATLAB consistent) ***/
/******************************************************************************/

const string DMI_BLOCK_NAME_ATTR_ = "Object Heading"
const string DMI_BLOCK_PATHNAME_ATTR_ = "Block Name"
const string DMI_BLOCK_NAME_TITLE_ = "Block Name"
const string DMI_BLOCK_TYPE_ATTR_ = "Block Type"
const string DMI_BLOCK_DELETED_ATTR_ = "Block Deleted?"
const string DMI_VIEW_ = "DOORS MATLAB Interface"
const string DMI_SIMULATION_SCRIPT_ATTR_ = "Simulation Script"
const string DMI_SIMULATION_RESULTS_ATTR_ = "Simulation Results"
const string DMI_LAST_SYNC_DATE_ = "Last Synchronization Date"
const string DMI_MODULE_DESCRIPTION_PREFIX = "DMI Surrogate for "
const string DMI_DESCRIPTION_ATTR = "DMI description"
const string DMI_EXT_NAVIGATE_ATTR = "DmiSlNavCmd"
const string DMI_EXT_COMMAND_ATTR = "MATLAB Command"
const string DMI_MODEL_VER_ATTR_ = "Simulink model version"
const string DMI_MODEL_TIMESTAMP_ATTR_ = "Simulink file timestamp"

const bool DMI_DEBUG_ = false


void dmi_debug(string msg) {
    if (DMI_DEBUG_) {
        print msg
    }
}

void dmiOpenBrowseDlg_()
{
    if (dmiBrowseDB_ == null) {
        dmiBrowseDB_ = create "Tree view"
    }
    show(dmiBrowseDB_)
    oleSetResult(getTitle(dmiBrowseDB_))
}

void dmiBrowseForPath_()
{   // Callback for button
    Folder thisFolder = null;
	string szModuleName = fnMiniExplorer(null, thisFolder, MINI_EXP_FORMAL_MODS, "Browse", "Please select a module");
    oleSetResult(szModuleName);
}

Object dmiObjectAtIndex(Module m, int idx) {

    current = m
    if (idx < 0) {
        idx = dmiFirstNewObj - idx - 1;
    }

    if (idx==0) {
        return(null)
    } else {
        return(object(idx))
    }
}

string dmiDoubleUpQuotes_(string s) {
    string new = ""

    while (matches("\"",s)) {
        new = new s[0:start(0)] "\""
        s = s[start(0)+1:]
    }
    new = new s

    return new
}

string dmiEscapeSingleQuotes_(string s) {
    string new = ""

    while (matches("'",s)) {
        new = new s[0:start(0)-1] "''"
        s = s[start(0)+1:]
    }
    new = new s

    return new
}

string dmiEscapeCarriageReturns_(string s) {
    string new = ""

    while (matches("\n",s)) {
        new = new s[0:start(0)-1] " "
        s = s[start(0)+1:]
    }
    new = new s

    return new
}


string dmiCSVRemoveDoubleQuotes(Buffer buff) {
    Buffer temp
    string result
    int    i        = 0
    int    buff_len = length buff
    bool   found    = false

    if (buff_len == 0)
        return ""

    temp = create

    if (buff[0] == dmiCSVDoubleQuote)
        i++

    while (i < buff_len) {
        if (buff[i] == dmiCSVDoubleQuote) {
            if (found) {
                found = false
            } else {
                temp += buff[i]
                found = true
            }
        } else {
            temp += buff[i]
        }
        i++
    }

    buff_len = length temp
    if (temp[buff_len - 1] == dmiCSVDoubleQuote)
        result = temp[0:buff_len - 2] ""
    else
        result = temp[0:buff_len - 3] ""

    delete temp

    return result

} /* dmiCSVRemoveDoubleQuotes */


bool dmiCSVHasEvenNumDoubleQuotes(Buffer buff) {
    int    i     = 0
    int    count = 0

    if (length buff == 0)
        return false

    while (i < length buff) {
        if (buff[i] == dmiCSVDoubleQuote)
            count++
        i++
    }

    if (count%2 == 0)
        return true
    else
        return false

} /* dmiCSVHasEvenNumDoubleQuotes */







/*******************************************************************************
 * dmiCSVGetToken - Read a single CSV token from an input file.
 *   (Modified from \lib\dxl\standard\import\commas.dxl:impSprGetToken)
 */
string dmiCSVGetToken(Stream file, string &line, char sep) {
    string  token = ""
    Buffer b = create

    setempty(b)

    if (line[0] == sep) {
        line = line[1:]
        token = ""
    } else if (line[0] == dmiCSVDoubleQuote) {
        setempty dmiCSVBuffer
        while (!dmiCSVHasEvenNumDoubleQuotes dmiCSVBuffer) {
            if (dmiCSVQuotes1 line) {
                dmiCSVBuffer += line[0:end 0]
                line = line[(end 0) + 1:]
            } else {
                dmiCSVBuffer += line[0:(length line) - 1]
                line = ""
            }
            if (!dmiCSVHasEvenNumDoubleQuotes dmiCSVBuffer && line == "") {
                file >= b
                line = stringOf b
                dmiCSVLineNum++;
                dmiCSVBuffer += "\n"
            }
        }
        token = dmiCSVRemoveDoubleQuotes dmiCSVBuffer
    } else if (dmiCSVQuotes2 line) {
        token = line[0:(end 0) - 1]
        line = line[(end 0) + 1:]
    } else if (dmiCSVAnything line && (end 0) == (length line - 1)) {
        token = line[0:end 0]
        line = null
    }
    delete b
    return token

} // dmiCSVGetToken





/*******************************************************************************
 * dmiCSVReadRow - Read a single object entry from a CSV input file.
 *   (Modified from \lib\dxl\standard\import\commas.dxl:impSprReadRow)
 */
bool dmiCSVReadRow(Stream file, char sep, Module m) {
    string      line
    string      token = ""
    Buffer      b = create
    int         objVal
    int         parentVal
    int         olderBroVal
    Object      o
    Object      par         = null
    Object      olderBro    = null

    setempty b
    if (end file) {
        return false
    }

    file >= b
    line = stringOf b
    dmiCSVLineNum++;

    /************ First 3 entries identify position in tree ***************/
    // % mods{:,1}  :=  DOORS Ids or -N for new objects
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
        objVal = intOf(realOf(token))
    } else {
        // Ignore the empty line
        return true
    }

    // % mods{:,2}  :=  DOORS Parent ID
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
        parentVal = intOf(realOf(token))
    } else {
        return false
    }

    // % mods{:,3}  :=  DOORS Older brother ID  (0 if first child)
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
        olderBroVal = intOf(realOf(token))
    } else {
        return false
    }

    //Find or create the object
    if (olderBroVal != 0) {
        olderBro = dmiObjectAtIndex(m,olderBroVal)
    } else {
        if (parentVal != 0) {
            par = dmiObjectAtIndex(m,parentVal)
        }
    }

    if (objVal < 0) {
        if (olderBro != null) {
            o = create(after(olderBro))
        } else {
            if (par == null) {
                o = create(m)
            } else {
                o = create(first(below(par)))
            }
        }

        if (objVal == -1) {
            dmiFirstNewObj = o."Absolute number"
        } else {
            // Internal testing
            int objNum = o."Absolute number"
            if (objNum != (dmiFirstNewObj - objVal - 1)) {
                ack "Internal error!  -1 ==> #" dmiFirstNewObj ", " objVal " ==> #"  objNum ""
            }
        }
    } else {
        o = dmiObjectAtIndex(m,objVal)

        // Update the hierarchy
        if (olderBro != null) {
            move(o,olderBro)
        } else {
            move(o,below(par))
        }
    }


    /************ Remaining entries for organization/visual display **********/
    // % mods{:,4}  :=  fullPath
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
        o.DMI_BLOCK_PATHNAME_ATTR_ = token
    } else {
        return false
    }

    // % mods{:,5}  :=  shortName
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
        o.DMI_BLOCK_NAME_ATTR_ = token
    } else {
        return false
    }

    // % mods{:,6}  :=  objType
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
        o.DMI_BLOCK_TYPE_ATTR_ = token
    } else {
        return false
    }

    // % mods{:,7}  :=  level
    if (line != null) {
        token = dmiCSVGetToken(file, line, sep)
    } else {
        return false
    }

    // Set block deleted to false
    o.DMI_BLOCK_DELETED_ATTR_ = false
    delete b
    return true

} // dmiCSVReadRow


/******************************************************************************/
/**************************** MATLAB Services *********************************/
/******************************************************************************/

void dmiVersionNumber() {
    oleSetResult("Interface version " DMI_VERSION)
}



/**************************** Misc Utilities *********************************/

void dmiUtilCurrentFolder_() {
    Folder f = current
    if (f ==null) {
        oleSetResult("")
    } else {
        oleSetResult(fullName(f))
    }
}

void dmiUtilCurrentProject_() {
    Project p = current
    if (p ==null) {
        oleSetResult("")
    } else {
        oleSetResult(fullName(p))
    }
}


bool dmiUtilIsFolderValid(string name) {
    Folder f = folder(name)
    return(f != null)
}

void dmiUtilIsNameValid_(string name) {
    bool out = isValidName(name)
    if (out) {
        oleSetResult("true");
    } else {
        oleSetResult("false");
    }
}

void dmiUtilIsFolderValid_(string name) {
    if (dmiUtilIsFolderValid(name)) {
        oleSetResult("true");
    } else {
        oleSetResult("false");
    }
}


bool dmiIsMATLABSurrogate(Module m) {
    if (! exists attribute DMI_DESCRIPTION_ATTR) {
        return false
    }

    string modDescription = m.DMI_DESCRIPTION_ATTR
    int prefixL = length(DMI_MODULE_DESCRIPTION_PREFIX)
    bool matches = (modDescription[0:(prefixL-1)] == DMI_MODULE_DESCRIPTION_PREFIX)
    return matches
}

void dmiCreateModuleAttributes(Module m) {
    current = m

    if (! exists attribute DMI_BLOCK_NAME_ATTR_) {
        create object type "string" attribute DMI_BLOCK_NAME_ATTR_
    }
    if (! exists attribute DMI_BLOCK_PATHNAME_ATTR_) {
        create object type "text" attribute DMI_BLOCK_PATHNAME_ATTR_
    }
    if (! exists attribute DMI_BLOCK_TYPE_ATTR_) {
        create object type "string" attribute DMI_BLOCK_TYPE_ATTR_
    }
    if (! exists attribute DMI_BLOCK_DELETED_ATTR_) {
        create object type "boolean" attribute DMI_BLOCK_DELETED_ATTR_
    }
    if (! exists attribute DMI_SIMULATION_SCRIPT_ATTR_) {
        create module type "text" attribute DMI_SIMULATION_SCRIPT_ATTR_
    }
    if (! exists attribute DMI_SIMULATION_RESULTS_ATTR_) {
        create module type "text" attribute DMI_SIMULATION_RESULTS_ATTR_
    }
    if (! exists attribute DMI_LAST_SYNC_DATE_) {
        create module type "string" attribute DMI_LAST_SYNC_DATE_
    }
    if (! exists attribute DMI_DESCRIPTION_ATTR) {
        create module type "string" attribute DMI_DESCRIPTION_ATTR
    }
    if (! exists attribute DMI_MODEL_VER_ATTR_) {
        create module type "text" attribute DMI_MODEL_VER_ATTR_
    }
    if (! exists attribute DMI_MODEL_TIMESTAMP_ATTR_) {
        create module type "text" attribute DMI_MODEL_TIMESTAMP_ATTR_
    }
}

void dmiNewSurrogate_(string path, string modelName) {
    string moduleDescription

    dmi_debug "\nCreating surrogate module..."

    // Create surrogate module

    moduleDescription = DMI_MODULE_DESCRIPTION_PREFIX "'" modelName "' Interface Version " DMI_VERSION
    interfaceMakeMod_(path, moduleDescription, "", 1)
    if (oleGetResult != "OK") {
        halt
    }

    dmiSurrogateM_ = current Module
    oleSetResult(uniqueID(module(dmiSurrogateM_)))

    // Create required attributes
    dmiCreateModuleAttributes(dmiSurrogateM_)

    dmiSurrogateM_.DMI_DESCRIPTION_ATTR = moduleDescription

    // Save attribute definitions
    save dmiSurrogateM_

    // Create DMI view
    width(column 0,100)
    justify(column 0,right)

    title(column 1,DMI_BLOCK_NAME_TITLE_)
    width(column 1,300)
    justify(column 1,left)

    attribute(insert column 2,DMI_BLOCK_TYPE_ATTR_)
    width(column 2,100)
    justify(column 2,left)

    attribute(insert column 3,DMI_BLOCK_DELETED_ATTR_)
    width(column 3,100)
    justify(column 3,center)

    save view DMI_VIEW_

    // Make this view the default
    setDefaultViewForModule(dmiSurrogateM_,DMI_VIEW_)

    dmi_debug "done."
}


void dmiCreateNewSurrogate_(string projName, string folderName ,string moduleName, string modelName) {
    Project prj = project("/" projName);
    string folderPath = "/" projName "/" folderName
    Folder f

    if (prj == null) {
        prj = create(projName,"DMI Created project");
        if (prj == null) {
            oleSetResult("DMI Error: Could not create project \"" projName "\"")
            halt
        }

    }

    f = folder(folderPath);
    if (f == null) {
        f = create(folderPath,"DMI Created folder");
        if (f == null) {
            oleSetResult("DMI Error: Could not create folder \"" folderPath "\"")
            halt
        }
    }

    current = f
    dmiNewSurrogate_(moduleName, modelName);
}

void dmiCreateSurrogate_(string modelName) {
    string path = "./" modelName
    dmiNewSurrogate_(path,modelName);
}



Object dmiCreateObject_(Module m, int lvl, Object prevObj) {

    dmi_debug "\nCreating object..."

    current = m
    if (null prevObj) return create m
    if (lvl > level prevObj) return create below prevObj

    // Level new object <= level of previous object
    while (lvl != level prevObj) {
        prevObj = parent prevObj
    }
    return create after prevObj

    dmi_debug "done."
}


void dmiUpdateHierarchy_(Object curObj, int newLevel, Object prevObj) {

    dmi_debug "\nUpdating hieararchy..."

    current = module curObj
    if (null prevObj && curObj != first current Module) {
        move(curObj,after first current Module)	    // Move curObj to level 1
        move(first current Module, after curObj)	// Move curObj to first level 1.
    } else if (level curObj != newLevel || previous curObj != prevObj) {
        if (newLevel > level prevObj) {
            move(curObj,below prevObj)
        } else {
            while (newLevel != level prevObj) {
                prevObj = parent prevObj
            }
            move(curObj,after prevObj)
        }
    }

    dmi_debug "done."
}


void clear(Skip s) {
    Object value
    for value in s do {
        delete(s,(string key s))
    }
}


void dmiInitSurrogateS_(){

    dmi_debug "\nInitializing surrogate list..."

    // Clear surrogate list
    clear dmiSurrogateS_

    current = dmiSurrogateM_

    // Initialize surrogate list
    filtering off; outlining off; level 0
    Object o
    for o in dmiSurrogateM_ do {
        string id = o."Absolute Number"
        Buffer b = create
        b += id
        put(dmiSurrogateS_,stringOf(b),o)
    }

    dmi_debug "done."
}


void dmiInitSurrogate_(string modelName, bool createSurrogate) {

    dmi_debug "Initializing surrogate module..."

    // Check if a project is open
    if (null current Project) {
        oleSetResult("DMI Error: You must first open a DOORS project!")
        halt
    }

    // Check if surrogate exists
    if (! exists module modelName) {
        if (createSurrogate) {
            dmiCreateSurrogate_(modelName)
        } else {
            oleSetResult("DMI Error: Model " modelName " has not been exported to DOORS!")
            halt
        }
    } else {
        // If the module was deleted it must be restored
        // prior to synchronization
	    if (isDeleted module modelName) {
	        string msg = "The module '" modelName "' is deleted in the current project.  It must be restored or the synchronization will abort."
	        string buttons[] = {"Restore", "Abort"}
            int answer = messageBox(msg,buttons, msgQuery)

            if (answer==0) {
	            undelete(module modelName)
	            refreshDBExplorer()
	        } else {
	            oleSetResult("DMI Error: Module " modelName " is deleted")
	            halt
	        }
	    }
	}

    dmiSurrogateM_ = edit modelName
    dmiInitSurrogateS_

    // Display DMI view
    current = dmiSurrogateM_
    if (currentView current Module != DMI_VIEW_) {
        load view DMI_VIEW_
    }

    // Add the description attribute for identification
    if (! exists attribute DMI_DESCRIPTION_ATTR) {
        create module type "string" attribute DMI_DESCRIPTION_ATTR
        moduleDescription = DMI_MODULE_DESCRIPTION_PREFIX "'" modelName "' Interface Version " DMI_VERSION
        dmiSurrogateM_.DMI_DESCRIPTION_ATTR = moduleDescription
    }

    oleSetResult("")
    dmi_debug "done."
}


bool dmiHasLinks_(Object o) {
    // Check for outgoing links
    Link l
    for l in o->"*" do return true
    // Check for incoming links
    string s
    for s in o<-"*" do return true
    return false
}



void dmiSendObject_(string doorsId, string blockName, string blockType, int blockLevel, string itemName) {

    current = dmiSurrogateM_

    Object o
    if (null doorsId || ! find(dmiSurrogateS_,doorsId,o)) {
        o = dmiCreateObject_(dmiSurrogateM_,blockLevel,dmiPrevObjPtr_)
    } else {
        dmiUpdateHierarchy_(o,blockLevel,dmiPrevObjPtr_)
        delete(dmiSurrogateS_,doorsId)
    }

    o.DMI_BLOCK_PATHNAME_ATTR_ = blockName
    o.DMI_BLOCK_NAME_ATTR_ = itemName
    o.DMI_BLOCK_TYPE_ATTR_ = blockType
    o.DMI_BLOCK_DELETED_ATTR_ = false

    string id = o."Absolute Number"
    if (dmiHasLinks_ o) {
        oleSetResult(id ",true")
    } else {
        oleSetResult(id ",false")
    }

    dmiPrevObjPtr_ = o
}



void dmiSelectObjectStart_(string modelName) {
    if (open(module(modelName))) {
    	dmiSurrogateM_ = module(item(modelName))

    	/* Make visible if it is not */
    	if (!isVisible(dmiSurrogateM_)) {
    	    read(fullName(dmiSurrogateM_),true)
        }

    } else {
    	dmiSurrogateM_ = edit modelName
    }
    oleSetResult("")
}


void dmiReadObjectStart_(string modelName) {

    dmiSurrogateM_ = read(modelName, false)
    dmiInitSurrogateS_

    // Clear display set of surrogate
    current = dmiSurrogateM_

    filtering off; outlining off; level 0
    Object o
    for o in dmiSurrogateM_ do {
        reject o
    }
    oleSetResult("")
}

// Helper for the next function
// Makes a string that can be eval-ed into a cell array with following
// columns: MODULE_PATH MODULE_NAME MODULE_UNIQUE_ID 
string dmiProjModulesToString_(Project proj) {
    string proj_name = name proj
    Item i
    Module mod
    string mod_name
    string mod_id
    string proj_path
    string mod_path
    string value = ""
    for i in proj do {  // this gets all items recoursively
        mod = read(fullName(i), false)   // module(name) won't work if not open
        if (mod != null) {   // if this is really a module
            mod_name = mod."Name"
            mod_id = uniqueID(module(fullName(i)))
            proj_path = fullName(getParentFolder(proj))
            mod_path = fullName(getParentFolder(mod))
            value = value "'" mod_id "', '" mod_name "', '" mod_path "', '" proj_name "', '" proj_path "'; " 
        }
    }
    return value
}
// Try to list all modules for a given projectName.
// Try to list all modules in a database if projectName is "/".
void dmiListModules_(string projectName) {
    string value = "{"
    Project proj
    if (projectName == "/") {
        for proj in database do { 
            proj_modules = dmiProjModulesToString_(proj)
            value = value proj_modules
        }
    } else {
        proj = project(projectName)
        if (proj == null) {
            oleSetResult("'Unable to read project \"" projectName "\"'")
            return
        } else {
            proj_modules = dmiProjModulesToString_(proj)
            value = value proj_modules
        }
    }
    value = value "}"
    oleSetResult(value)
}

Module dmiID2Module_(string moduleId, bool editable) {
    Item itm = itemFromID(moduleId)
    if (itm == null) {
        oleSetResult("DMI Error: Module ID '" moduleId "' does not exist")
        return null
    }
    Module m = module(itm)
    if (m == null) {
        // We get here if the module is not loaded. 
        // We'll need to read or edit depending on value of 'editable'
        if (editable) {
            m = edit(fullName(itm))
        } else {
            m = read(fullName(itm),false)
        }
        if (m == null) {
            if (editable) {
                oleSetResult("DMI Error: Could not edit module '" moduleId "'")
            } else {
                oleSetResult("DMI Error: Could not read module '" moduleId "'")
            }
            return null
        }
    } else {
        // The module was already loaded, make editable if required
        if (editable && !canModify(m)) {
            edit(fullName(itm))
            if (!canModify(m)) {
                oleSetResult("DMI Error: Could not edit module '" moduleId "'")
                return null
            }
        }
    }
    
    return m
}

// Returns all IDs
string dmiModuleObjectIDs_(Module m) {
    Object   o
    string   value = "["

    for o in m do {
        value = value o.("Absolute Number") " "
    }
 
    value = value "]"
    return value
}

string dmiGetAllSlRefObjects_(Module m) {
 
    current = m
    if (! exists attribute DMI_EXT_NAVIGATE_ATTR) {
        oleSetResult( "No Simulink reference objects in module " fullName(m) )
        return "{ }"
    }

    string result = ""
    Object o
    string text
    string label
    string nav_command
    string my_command
    string my_model
    string my_guid
    
    if (m != null) {

        Regexp objText = regexp "Simulink reference: (.+)"
        Regexp command_pattern = regexp "^(\\w+)\\('([^']+)', ?'([^']+)'"

        for o in m do {

            nav_command = o.DMI_EXT_NAVIGATE_ATTR
            if (command_pattern nav_command) {
                my_command = nav_command[start(1):end(1)] 
                my_model = nav_command[start(2):end(2)]
                my_guid = nav_command[start(3):end(3)]   
            } else {
                continue;  // this does not look like our expected command
            }

            text = o."Object Text"
            if (objText text) {
                label = text[start(1):length(text)-2]
            } else {
                label = "INVALID LABEL"
            }
            label = dmiEscapeSingleQuotes_(label)
            label = dmiEscapeCarriageReturns_(label)
            result = result "'" o."Absolute Number" "', '" my_model "', '" my_guid "', '" label "', '" my_command "'; "  
        }
    }
    return "{ " result " }"
}

void dmiModuleGet_(string moduleId, string attr) {
    Object  o
    string  value
    string  errString
    Module  m = dmiID2Module_(moduleId, false)
    if (m==null) {
        return
    }

    if (lower(attr) == "fullname") {
        value = fullName(m)
    } else if (lower(attr) == "lastmodified") {
        value = m."Last Modified On" " by " m."Last Modified By" ""

    } else if (lower(attr) == "unsaved") {
        if (unsaved(m)) {
            value = "true"
        } else {
            value = "false"
        }

    } else if (lower(attr) == "objectids") {
        oleSetResult(dmiModuleObjectIDs_(m))
        return

    } else if (lower(attr) == "slrefobjects") {
        oleSetResult(dmiGetAllSlRefObjects_(m))
        return

    } else {
        noError
        value = m.(attr)
        errString = lastError
        if (errString != null) {
            oleSetResult("DMI Error: " errString)
            return
        }
    }

    oleSetResult(value)
}


void dmiModuleResolvePath_(string path) {
    if (exists(module path)) {
        oleSetResult(uniqueID(item(path)))
    } else {
        oleSetResult("")
    }
}

void dmiAddLinkObj_(string moduleId, int objAbsNum, string iconPath, string labelTxt, string navcmd) {
    Object  o
    Object  new
    bool    status
    Module  m = dmiID2Module_(moduleId, true)

    if (m == null) {
        halt
    }

    current = m
    o = object(objAbsNum, m)

    if (dmiIsMATLABSurrogate(m)) {
        oleSetResult("DMI Error: You can not create two way links to surrogate modules");
        halt
    }


    // If needed add the navigation command attribute
    if (! exists attribute DMI_EXT_NAVIGATE_ATTR) {
        create object type "string" attribute DMI_EXT_NAVIGATE_ATTR
    }

    if (o==null) {
        oleSetResult("DMI Error: DOORS Id '" objAbsNum "' not found!")
    } else {
        // Special case if this is a table object
        if (cell(o)) {
            o = getTable(o)
            // Add the picture object
            status = insertPictureFileAfter(iconPath,formatDIB,o)
            new = next(sibling(o))
       } else {
        // Add the picture object
        status = insertPictureFileBelow(iconPath,formatDIB,o)
            new = first(o)
        }

        if (status) {
            new."Object Text" = labelTxt
            new.DMI_EXT_NAVIGATE_ATTR = navcmd
        } else {
            oleSetResult("DMI Error: Could not add Simulink navigation object")
        }
        refresh(m)
    }
}

void dmiModuleSet_(string moduleId, string attr, string value) {
    Module  m = module(itemFromID(moduleId))
    Object  o

    m.(attr) = value;
    oleSetResult("")
}


void dmiObjGet_(string moduleId, int objAbsNum, string attr) {
    
    Module m = dmiID2Module_(moduleId, false)
    if (m == null) {
        return
    }
    
    Object  o = object(objAbsNum, m)
    if (o == null) {
        oleSetResult("DMI Error: DOORS Id '" objAbsNum "' not found!")
        return
    }

    // Special cases for things that are not really attributes
    if (lower(attr) == "parentid") {
        Object po = parent(o);
        if (po == null) {
            oleSetResult("DMI Error: Parent not found for DOORS Id '" objAbsNum "'!")
        } else {
            oleSetResult(po."Absolute Number" "");
        }

    } else {
        // all other cases
        string  value
        value = o.(attr)
        oleSetResult(value)
    }
}

void dmiUtilIsModuleOutlined_(string moduleId) {
    Module  m = module(itemFromID(moduleId))
    if (outlining(m)) {
        oleSetResult("true");
    } else {
        oleSetResult("false");
    }
}


void dmiObjSet_(string moduleId, int objAbsNum, string attr, string value) {
    Module  m = module(itemFromID(moduleId))
    Object  o

    if (m == null || !canModify(m)) {
        edit(fullName(itemFromID(moduleId)))
        m = module(itemFromID(moduleId))
    }

    if (lower(attr) == "navcmd" || lower(attr) == "dmillnavcmd") {
        attr = DMI_EXT_NAVIGATE_ATTR
    }

    current = m
    o = object(objAbsNum)
    
    if (lower(attr) == "picture") {
        // Note: error is thrown by DOORS if 'o' is not a picture object
        insertPictureFile(value, formatDIB, o)
        refresh(m)
    } else { 
        // all other cases
        o.(attr) = value
    }
    oleSetResult("")
}



void dmiOpenLinkedModules(Object o) {
    ModName_ srcModRef
    ModName_ destModRef
    Link   outLink

    for srcModRef in o<-"*" do {
        read(fullName(srcModRef), false)
    }

    for outLink in o->"*" do {
        destModRef = target(outLink)
        read(fullName(destModRef), false)
    }
}

void dmiObjOpen_(string moduleId, int objAbsNum, bool highlight) {

    Object  o
    Module  m = dmiID2Module_(moduleId, true)
    if (m == null) {
        m = dmiID2Module_(moduleId, false)
        if (m == null) {
            halt
        }
        // make sure this read-only module is visible
        read(fullName(itemFromID(moduleId)), true)
    }

    current = m
    if (objAbsNum>0) {
        o = object(objAbsNum)

        if (o==null) {
            oleSetResult("DMI Error: DOORS Id '" objAbsNum "' not found!")
            if (highlight) deselect(m)
        } else {
            oleSetResult("");
            accept o
            current = o
            if (highlight) setSelection(o)
        }
    } else {
        oleSetResult("");
        if (highlight) deselect(m)
    }
    refresh m
}

int dmiStrToInt(string s) {
    int  lngth = length(s)
    int  value = 0
    int  charIdx = 0
    int  charVal = 0
    bool isNeg = false

    while(charIdx<lngth) {
        charVal = intOf(s[charIdx]);
        if (charVal==45) {
            isNeg = true
        } else if(charVal<58 && charVal>47) {
            value = value*10 + (charVal-48)
        } else {
            ack "DMI Error: unexpected character"
            halt
        }
        charIdx++
    }

    if (isNeg) {
        value = -value;
    }

    return value
}




void dmiSelectObject_(string doorsId) {

    current = dmiSurrogateM_

    Object o

    o = object(dmiStrToInt(doorsId))

    if (o==null) {
        oleSetResult("DMI Error: DOORS Id '" doorsId "' not found!")
        halt
    } else {
        accept o
        current = o
    }
}


void dmiSelectObjectEnd_() {

    current = dmiSurrogateM_

    //filtering on
    refresh dmiSurrogateM_
    clear dmiSurrogateS_
    oleSetResult("")
}


void dmiGetModifiedDate_(string modelName) {
    dmiInitSurrogate_(modelName,false)
    oleSetResult(dmiSurrogateM_.DMI_LAST_SYNC_DATE_ "")
}


// Create a link using the default link module
// create the module as a side-effect if it does not
// exist
void dmiCreateLink(Object src, Object dest) {
    string    srcRef      = fullName(module(src))
    string    trgRef      = fullName(module(dest))
    string    linkModName = getDefaultLinkModule(module(srcRef),module(trgRef))
    Module    linkMod

    if (!exists(module(linkModName))) {
        // Make the source parent the current folder
        Project p = getParentProject(module(src))
        string  modName = fullName(p) "/" linkModName

        if (!exists(module(modName))) {
            linkMod = create(modName,"RMI default link module",manyToMany,false)
        }

        setDefaultLinkModule(modName)

        //string anyError = lastError
        //if (!null anyError) {
        //    ack "Error creating the default link module: " anyError
        //    halt
        //}
    }


    //noError
    src -> dest;
    //string anyError = lastError
    //if (!null anyError) {
    //    ack "Error creating link: " anyError
    //    halt
    //}


}

// Create a link from the object to the module and object identified
// If not possible return silently without throwing an error
void dmiCreateLink(Object o, string  modStr, string  objNumStr) {
    Item    itm     = itemFromID(modStr)
    Module  destMod
    Object  dest

    if (itm != null) {
        destMod = module(itm)
        if (destMod == null) {
            read(fullName(itm),false)
            destMod = module(itm)
        }

        if (destMod != null) {
            dest = object(dmiStrToInt(objNumStr), destMod)
            if (dest != null) {
                dmiCreateLink(o, dest) // Use the default linkset
            }
        }
    }
}


void dmiCreateOutLinks_(Object o, string linkstr) {
    int     index = 1
    string  modStr
    string  objNumStr
    Module  destMod

    // Remove the initial { if it exists
    if (linkstr[0]=='{') {
        linkstr = linkstr[1:]
    }

    // Remove the closing } if it exists
    if (linkstr[length(linkstr)-1]=='}') {
        linkstr = linkstr[0:(length(linkstr)-2)];
    }


    while (matches(",",linkstr)) {
        if (index%2 == 0) {
            objNumStr = linkstr[0:start(0)-1]
            dmiCreateLink(o,modStr,objNumStr)
        } else {
            modStr = linkstr[0:start(0)-1]
        }

        linkstr = linkstr[start(0)+1:]
        index++
    }

    if (index%2 == 0) {
        objNumStr = linkstr
        dmiCreateLink(o,modStr,objNumStr)
    }
}


void dmiObjCreateLinks_(string moduleId, int objAbsNum, string linkstr) {
    Module  m = module(itemFromID(moduleId))
    Object  o = object(objAbsNum, m)

    if (o == null) {
        ack "Could not open object #" objAbsNum " in module ID=" moduleId
    } else {
        dmiCreateOutLinks_(o, linkstr)
    }
}

// Removes a specific link when called like this:
// dmiDeleteLink_("000009a2", 4, "000009a1", 1)
void dmiDeleteLink_(string srcModule, int srcObj, string destModule, int destObj) {

    Module sModule = dmiID2Module_(srcModule, true)
    if (sModule == null) { // failed to open - do nothing
        return
    }

    Object sObj = object(srcObj, sModule)
    if (sObj == null) {  // hmm... no such object - do nothing
        return
    }

    Module dModule = dmiID2Module_(destModule, false) // destination module can be read-only
    if (dModule == null) { // failed to open - do nothing
        return
    }

    Object dObj = object(destObj, dModule)
    if (dObj == null) {  // hmm... no such object - do nothing
        return
    }

    delete(sObj -> dObj)
}

// This will delete all outgoing links of this object
void dmiDeleteLinks_(string srcModule, int srcObj) {

    Module sModule = dmiID2Module_(srcModule, true)
    if (sModule == null) { // failed to open - do nothing
        return
    }

    Object sObj = object(srcObj, sModule)
    if (sObj == null) {  // hmm... no such object - do nothing
        return
    }

    Link lnk
    for lnk in sObj -> "*" do {
        delete lnk
    }
}

// Remove object with all its outgoing links. Use cases:
//     when cleaning up surrogate objects,
//     when cleaning up outdated "Simulink reference" objects. 
void dmiDeleteObject_(string targetModule, int targetObj) {

    Module tModule = dmiID2Module_(targetModule, true)
    if (tModule == null) { // failed to open - do nothing
        return
    }

    Object tObj = object(targetObj, tModule)
    // If this object already missing from Surrogate, let's not worrry about it now
    if (tObj == null)
        return
    
    // Note that there is no need to delete links first: surrogate objects are
    // only supposed to have outgoing links, and these are deleted together with
    // the object.
    // On the other hand, DOORS will refuse to delete objects that have descendants,
    // which is really what we want, because we don't want user removing subsystem
    // objects from surrogate modules when some inner blocks are in surrogate.
    // Note that there 'bool canDelete(obj)' is also discussed in DXL Manual, but we
    // use 'string canDelete(obj)' here to keep track of the reason.
    string why_cant_delete = canDelete(tObj)
    if (why_cant_delete != null) {
        oleSetResult(why_cant_delete)
    } else {
        // The difference between hardDelete() and softDelete() is that objects 
        // are really deleted, they can not be restored using undelete().
        // Also, softDelete() would not ERROR even if canDelete() was not null.
        hardDelete(tObj)
        oleSetResult("")
    }
}

void dmiRefreshModule_(string targetModule) {
    Module tModule = module(itemFromID(targetModule))
    if (tModule == null) {
        // Refresh is not a crucial step, let's not worry about it now
        return
    }
    refresh(tModule)
}

string dmiGetAttr(Object o, string attrName, int max) {
    string str = ""

    if (null o) {
        return str
    }

    if (attrName == "Object Identifier")
        str = (identifier o "")
    else if (attrName == "Object Number")
        str = (number o "")
    else if (attrName == "Object Level")
        str = (level o "")
    
    else {  // All other atrributes

        Module oldc = current
        current = (module o)
        if (exists attribute attrName && canRead o.attrName) {
            str = o.attrName
        }
        if (! null oldc) current = oldc        
    }
        
    if (length(str) > max) {
        str = str[0:max]
    }
    return str
}

string dmiObjectDescription_(Object o) {
    string dscr
    string body

    dscr = dmiGetAttr(o,"Object Number", 60)
    if (length(dscr)==0) {
        dscr = dmiGetAttr(o,"Object Identifier", 60)
    }

    body = dmiGetAttr(o,"Object Heading", 60)
    if (length(body)==0) {
        body = dmiGetAttr(o,"Object Text", 60)
    }
    dscr = dscr " " body
    return dscr
}


void dmiObjLabel_(string moduleId, int objAbsNum) {
    Module  M = module(itemFromID(moduleId))
    Object  o = object(objAbsNum, M)
    string  value = dmiObjectDescription_(o);

    oleSetResult(value)
}


void dmiObjIsValid_(string moduleId, int objAbsNum) {
    string  value = "false"
    Item    itm = itemFromID(moduleId)
    Module  m
    Object  o
    
    if (itm != null) {
	      m = module(itm)

	      if (m == null) {
	         m = read(fullName(itm),false);
		    }
		
        if (m != null) {
    		    o = object(objAbsNum, m);
		
            if (o != null) {
			          value = "true"
            }
        } else {
            value = "no module"
        }
    } else {
        value = "no item"
    }

    oleSetResult(value)
}



/**************************************************
 * Utility to prune surrogate items that do not
 * have links
 **************************************************/


bool dmiDeleteUnlinkedContent_(Object o) {
    Object      child
    Object      nextChild
    bool        hasLinks = false
    bool        ChildHasLinks = false

    // If there are children see if any of them have
    // links
    if (first(o) != null) {
        nextChild = first(o)

        while(nextChild != null) {
            child = nextChild
            ChildHasLinks = dmiDeleteUnlinkedContent_(child)
            nextChild = next(sibling(child))

            if(!ChildHasLinks && canDelete(child)) {
                softDelete(child)
            } else {
                hasLinks = true
            }
        }
    }

    if (!hasLinks) {
        hasLinks = dmiHasLinks_(o)
    }

    // Update the status bar
    dmiStatusCnt++
    progressStep dmiStatusCnt

    return(hasLinks)

}

void dmiModuleRemoveCB_(DB x) {
    Module  m = current
    Object  obj, o = first(m)
    pragma  runLim, 0
    pragma  stack, 100000
    int     objCnt = 0

    for obj in m do objCnt++
    dmiStatusCnt = 0   // Initialize global counter

    progressStart(x, "Processing objects", "Completed",objCnt)
    dmiDeleteUnlinkedContent_(o)

    progressStop
    flushDeletions()
    refresh(m)

}

void dmiModuleRemoveUnlinked_(string moduleId) {
    Module  m = module(itemFromID(moduleId))
    current = m

    DB progressDB = create "Remove unlinked objects"
    label(progressDB, "This action will remove objects unless they \nhave links or have a decsendant with a link")
    apply(progressDB, dmiModuleRemoveCB_)
    show progressDB
}



string dmiObjInfo_(Object o, string descrPrefix) {
    Module m
    string objInfo = ""
    if (o==null) {
        return objInfo
    }

    m = module(o)
    objInfo = uniqueID(module(m)) "," o.("Absolute Number") "," descrPrefix dmiObjectDescription_(o)
    return objInfo
}

void dmiActiveObjectInfo_() {
    Object o

    o = lastSelectedObject_
    if (o==null) {
        // try to at least get the module info
        Module m
        m = lastSelectedModule_
        if (m==null) {
            oleSetResult("");
        } else {
            oleSetResult(uniqueID(module(m)));
        }
    } else {
        oleSetResult(dmiObjInfo_(o,""))
    }
}


string dmiModuleContents_(string moduleId, int startAt, int maxCount) {
    Object   o
    string   value = "{"
    string   objpair
    string   descr
    int      iterCnt

    Module m = dmiID2Module_(moduleId, false)
    if (m==null) {
        return "{}"
    }

    iterCnt = 0
    for o in m do {

        iterCnt++

        // skip as required by second argument
        if (iterCnt < startAt) {
            continue
        }

        // quit as required by the third argument
        if (iterCnt == startAt + maxCount) {
            break
        }

        // insert separator if not the very first item in this range
        if (iterCnt > startAt) {
            value = value ","
        }

        // for each object in range append Abs Number and Description
        descr = dmiObjectDescription_(o)
        descr = dmiEscapeSingleQuotes_(descr)
        objpair = "'" o.("Absolute Number") "','"  descr  "'"
        value = value objpair
    }

    value = value "}"
    return value
}

void dmiModuleContents(string moduleId, int startAt, int maxCount) {
    oleSetResult(dmiModuleContents_(moduleId, startAt, maxCount));
}


void dmiObjectSelect_(string encodedLocation) {
    string   modId
    string   objNumStr
    int      objNum
    Module   m
    Object   o

    if (matches(",",encodedLocation)) {
    	modId = encodedLocation[0:(start(0)-1)]
    	objNumStr = encodedLocation[(start(0)+1):]
    	objNum = dmiStrToInt(objNumStr)
    }

    m = dmiID2Module_(modId, false)
    if (m==null) {
        halt
    }
    
    if (!isVisible(m)) {
        read(fullName(itemFromID(modId)),true)
    }

    current = m
    o = object(objNum,m)
    if (o==null) {
        ack "DMI Error: Could not resolve object #" objNumStr
        halt
    }

    accept o
    current = o
}



string dmiSourceDescription_(Link l) {
    string str = ""
    string head = ""
    int len = 0
    int maxLen = 60

    Object src = source(l)
    str = source(l)
    str = str "/"
    head = src."Object Heading"
    str = str head

    if (length(str) > maxLen) {
        str = str[0:(maxLen-3)] "..."
    }

    str = str " (" (identifier src) ")"

    str = (dmiEscapeSingleQuotes_(str))
    return str
}


string dmiSurrogateTargetDescription_(Link l) {
    string str = ""
    string head = ""
    int len = 0
    int maxLen = 60

    Object trg = target(l)
    str = trg.DMI_BLOCK_PATHNAME_ATTR_

    if (length(str) > maxLen) {
        str = str[0:(maxLen-3)] "..."
    }

    return str
}


void dmiFollowToSource_(Link l) {
    ModName_ modName = source(l)
    Module srcMod
    int len = 0
    int maxLen = 60

    srcMod = read(fullName(modName),true)
    current = srcMod
    Object src = source(l)
    accept src
    current = src
    read(fullName(current Module), true)

}


string dmiObjLinkInfo(Object o) {
    Object      rqO
    Module      rqM
    Link        lnk
    string      lnkInfo = "{"
    string      objDesc = ""
    bool        isFirst = true


    dmiOpenLinkedModules(o)
    for lnk in o<-"*" do {
        rqO = source(lnk)
        rqM = module(rqO)

        if (!isFirst) {
            lnkInfo = lnkInfo ";"
        } else {
            isFirst = false
        }

        // Double up quotes to prevent CSV file corruption
        objDesc = dmiDoubleUpQuotes_(dmiObjectDescription_(rqO))

        // Escape quotes to allow proper strings in MATLAB
        objDesc = dmiEscapeSingleQuotes_(objDesc)

        lnkInfo = lnkInfo "'<-" objDesc  "',"
        lnkInfo = lnkInfo "'" uniqueID(module(rqM))  "','" rqO.("Absolute Number") "'"
    }

    for lnk in o->"*" do {
        rqO = target(lnk)
        rqM = module(rqO)

        if (!isFirst) {
            lnkInfo = lnkInfo ";"
        } else {
            isFirst = false
        }

        // Double up quotes to prevent CSV file corruption
        objDesc = dmiDoubleUpQuotes_(dmiObjectDescription_(rqO)) 
        
        // Escape quotes to allow proper strings in MATLAB
        objDesc = dmiEscapeSingleQuotes_(objDesc)

        lnkInfo = lnkInfo "'->" objDesc  "',"
        lnkInfo = lnkInfo "'" uniqueID(module(rqM))  "','" rqO.("Absolute Number") "'"
    }

    lnkInfo = lnkInfo "}"
    return lnkInfo
}

/* New methods to improve the interface */
void dmiLinkDescriptions_(string doorsId) {
    Link inLink
    Link outLink
    string allDescr = ""
    bool isFirst = true
    current = dmiSurrogateM_

    Object o
    if (find(dmiSurrogateS_,doorsId,o)) {

        // Open modules as needed
        dmiOpenLinkedModules(o)

        // Check for incoming links
        for inLink in o<-"*" do {
            if (isFirst) {
                allDescr = "'" dmiSourceDescription_(inLink) "'"
                isFirst = false
            } else {
                allDescr = allDescr ", '" dmiSourceDescription_(inLink) "'"
            }
        }
        oleSetResult("{" allDescr "}")
    } else {
        oleSetResult("DMI Error: DOORS Id '" doorsId "' not found!")
        halt
    }
}



void dmiFollowLink_(string doorsId, int idx) {
    Link inLink
    Link outLink
    current = dmiSurrogateM_
    int thisIdx = 1;

    Object o
    if (find(dmiSurrogateS_,doorsId,o)) {

        // Check for incoming links
        for inLink in o<-"*" do {
            if (thisIdx==idx) {
                dmiFollowToSource_(inLink)
            } else {
                thisIdx++
            }
        }
        oleSetResult("")
    } else {
        oleSetResult("DMI Error: DOORS Id '" doorsId "' not found!")
        halt
    }


}

void dmiStartLinkInSurrogate_(string doorsId) {
}


/******************************************************************************/
/***************************** DOORS Services *********************************/
/******************************************************************************/


int dmiCountSurrogateLinkedItems(Object o) {
    int count = 0
    Link outLink

    // First count the number of items
    dmiOpenLinkedModules(o)
    for outLink in o->"*" do {
        Object trgObj = target(outLink)
        if (dmiIsMATLABSurrogate(module(trgObj))) {
            count++
        }
    }
    return count
}


void dmiFillSurrogateLinkedItems(DBE listItem, Object o) {
    int count = 0
    Link outLink
    Object srcObj
    Module srcMod

    // Now create the items
    index = 0
    for outLink in o->"*" do {
        Object trgObj = target(outLink)
        if (dmiIsMATLABSurrogate(module(trgObj))) {
            insert(listItem, count, dmiSurrogateTargetDescription_(outLink))
            count++
        }
    }
}




void dmiMatlabConnect_() {

    if (null dmiMatlab_) {
        dmiMatlab_ = oleGetAutoObject("Matlab.Application")
        if (null dmiMatlab_) {
            ack "DMI Error: Can't connect to MATLAB.\nMake sure MATLAB is running as an automation server before attempting this command."
            halt
        }
    }
    // Check if connection is live; if not, retry connect
    dmiResult_ = null
    OleAutoArgs arglist = create
    put(arglist,"")
    string msg = oleMethod(dmiMatlab_,"Execute",arglist,dmiResult_)
    if (! null msg) {
        if (! confirm("DMI Error: Failed to connect to Matlab.\nWould you like to try again?")) halt
        dmiMatlab_ = null
        dmiMatlabConnect_()
    }
    return
}


void dmiMatlabExecute_(OleAutoObj mObj, string function) {
    //print function

    OleAutoArgs arglist = create
    string msg = null
    dmiResult_ = null
    put(arglist,function)
    msg = oleMethod(mObj,"Execute",arglist,dmiResult_)
    delete arglist
    if (! null msg) {
        ack "DMI Error: " msg
        halt
    }
//    if (! null dmiResult_) {
//        if (! null dmiResult_) {
//            ack dmiResult_
//            halt
//        }
//    }

    return
}


string dmiEscapeDoubleQuotes_(string s) {
    string new = ""

    while (matches("\"",s)) {
        new = new s[0:start(0)-1] "\\\""
        s = s[start(0)+1:]
    }
    new = new s

    return new
}

string dmiEscapeCR_(string s) {
    string new = ""

    while (matches("\n",s)) {
        new = new s[0:start(0)-1] "\\n"
        s = s[start(0)+1:]
    }
    new = new s

    return new
}


string dmiEscapeBackslash_(string s) {
    string new = ""

    while (matches("\\\\",s)) {
        new = new s[0:start(0)-1] "\\\\"
        s = s[start(0)+1:]
    }
    new = new s

    return new
}

string dmiCRLF2space_(string s) {
    string new = ""
    while (matches("\n",s)) {
        new = new s[0:start(0)-1] " "
        s = s[start(0)+1:]
    }
    new = new s
    return new
}


void dmiInvokeNavCmd_(Object o) {
    string command
    if (null o) {
        ack "DMI Error: No object is selected in module '" (current Module)."Name" "'"
        halt
    }

    if ((! exists attribute DMI_EXT_NAVIGATE_ATTR)){
        ack "DMI Error: Object has no navigation information"
        halt
    }

    command = o.DMI_EXT_NAVIGATE_ATTR

    if (command == "") {
        ack "DMI Error: Object has no navigation information"
        halt
    }

    command = dmiEscapeBackslash_(command)
    command = dmiEscapeDoubleQuotes_(command)
    command = "dmiMatlabConnect_(); dmiMatlabExecute_(dmiMatlab_,\"" command "\")"
    evalTop_ command
}


void dmiSelectBlock_(Object o) {
    string BlockPath
    string navCmd

    if (null o) {
        ack "DMI Error: No object is selected in module '" (current Module)."Name" "'"
        halt
    }

    if ((! exists attribute DMI_BLOCK_PATHNAME_ATTR_)) {
        dmiInvokeNavCmd_(o)
        return
    } else {
        BlockPath = o.DMI_BLOCK_PATHNAME_ATTR_
        BlockPath = dmiEscapeSingleQuotes_(BlockPath)
        if (BlockPath == "") {
            dmiInvokeNavCmd_(o)
            return
        }
    }

    if (o.DMI_BLOCK_DELETED_ATTR_ "" == "True") {
        ack "DMI Error: Block '" o.DMI_BLOCK_NAME_ATTR_ "' has been deleted from MATLAB model"
        halt
    }

    string AbsNum = o."Absolute Number"
    string command = "dmiSelectBlock_('"
    command = command AbsNum
    command = command "','"
    command = command BlockPath
    command = command "')"
    command = (dmiEscapeBackslash_(command))
    command = (dmiEscapeDoubleQuotes_(command))
    command = (dmiCRLF2space_(command))
    command = "dmiMatlabConnect_(); dmiMatlabExecute_(dmiMatlab_,\"" command "\")"
    evalTop_ command
}


string dmiEscapeQuotes_(string s) {
    // Quote apostrophes with an apostrophes.
    string new = ""
    while (matches("'",s)) {
        new = new s[0:start(0)] "'"
        s = s[start(0)+1:]
    }
    new = new s

    // Replace linefeeds with spaces.
    s = new
    new = ""
    while (matches("\n",s)) {
        new = new s[0:start(0)-1]" "
        s = s[start(0)+1:]
    }
    new = new s

    return new
}


void dmiRun_(DB dmiDB_) {
    string script = get dmiScriptDBE_
    if (null script) {
        ack ("DMI Error: You must provide a simulation script")
        return
    }

    // Save simulation script
    (current Module).DMI_SIMULATION_SCRIPT_ATTR_ = script

    // Run simulation
    string command = "dmiRun_('" (current Module)."Name" "','" (dmiEscapeQuotes_(script)) "');"
    dmiMatlabExecute_(dmiMatlab_, command)

    // Save simulation results
    ////    (current Module).DMI_SIMULATION_RESULTS_ATTR_ = dmiResult_
    ////    set (dmiResultsDBE_ , dmiResult_)

    if(! null dmiResult_) {
        // Error
        (current Module).DMI_SIMULATION_RESULTS_ATTR_ = dmiResult_
        set (dmiResultsDBE_ , dmiResult_)
    } else {
        // Success
        (current Module).DMI_SIMULATION_RESULTS_ATTR_ = oleGetResult
        set (dmiResultsDBE_ , oleGetResult)
    }
}


void dmiRunSimTop_ () {
    current = dmiSurrogateM_
    if (! exists attribute DMI_BLOCK_PATHNAME_ATTR_) {
        ack "DMI Error: This function may only be used from within a MATLAB module"
        halt
    }

    //clear previous run
    (current Module).DMI_SIMULATION_RESULTS_ATTR_ = ""

    //connect to matlab - evalTop needed to keep active connection
    if (null dmiMatlab_) {
        dmiMatlabConnect_()
    }

    dmiSimulationDB_ = create "Run MATLAB Simulation"
    dmiScriptDBE_ = text(dmiSimulationDB_,"Simulation script:",(current Module).DMI_SIMULATION_SCRIPT_ATTR_ "",500,150,false)
    dmiResultsDBE_ = text(dmiSimulationDB_,"Simulation results:",(current Module).DMI_SIMULATION_RESULTS_ATTR_ "",500,150,true)

    apply(dmiSimulationDB_,"Run",dmiRun_)
    show dmiSimulationDB_
}


void dmiRunSimulation_() {
    dmiSurrogateM_ = current Module
    evalTop_ "dmiRunSimTop_ ()"
}


void dmiUpdateAttibutes(string moduleId) {
    Module m = dmiID2Module_(moduleId, true)
    if (m == null) {
        halt
    }
    dmiCreateModuleAttributes(m)
}


void dmiUpdateModuleFromFile_(string moduleId, string filePath) {
    Stream  file
    Object  o
    string  blockPath
    char    sep = ','
    dmiCSVLineNum = 0;
    dmiFirstNewObj = 0;

    Module  m = dmiID2Module_(moduleId, true)
    if (m==null) {
        halt
    }

    if (!fileReadable_ filePath) {
        ack "Could not open the file \"" filePath "\" for reading"
    }

    file = read filePath

    dmiCSVQuotes1 = regexp "[^\"]*\"" sep ""
    dmiCSVQuotes2 = regexp "[^" sep "]*" sep ""

    while (!end file) {
        if (!dmiCSVReadRow(file, sep, m)) {
            oleSetResult("DMI Error: Problem reading \"" filePath "\" at line #" dmiCSVLineNum "")
            halt
        }
    }

    if (dmiFirstNewObj ==0) {
        oleSetResult("[]");

    } else {
        oleSetResult("" dmiFirstNewObj "");
    }
}


/* Export at most maxObjCnt objects to a csv file.  The last object is stored in
 * a global variable so that successive calls can access the remainder of the file
 * when startAtBegin is false.
 *
 * Returns true when there are more objects, false otherwise */
bool dmiExportPartialModule_(string modID, string filePath, int maxObjCnt, bool startAtBegin) {
    Stream  file
    Object  o
    string  blockPath
    int     objCnt = 0
    file = write filePath
    Module  m = dmiID2Module_(modID, true)
    if (m==null) {
        halt
    }

    if (startAtBegin || dmiLastExportObj==null) {

		// Make sure the attributes are correct:
		dmiCreateModuleAttributes(m);

        // Start off by making all the "Block deleted" attibutes false
        for o in m do {
            o.DMI_BLOCK_DELETED_ATTR_ = false
        }

        o = first(m)
    } else {
        o = next(dmiLastExportObj)
        if (o==null) {
            close file
            return false
        } else {
            if (module(o) != m) {
                ack "Attempting to continue exporting from a different module"
            }
        }
    }

    while(o != null && ((maxObjCnt==0) || objCnt<maxObjCnt)) {
        if (canRead o) {

            /* Column 1: Identifier */
            file << "\"" identifier(o)  "\","

            /* Column 2: depth */
            file << "\"" level(o) "\","

            /* Column 3: path */
            blockPath = dmiDoubleUpQuotes_(o.DMI_BLOCK_PATHNAME_ATTR_ "")
            file << "\"" blockPath "\","

            /* Column 4: type */
            file << "\"" o.DMI_BLOCK_TYPE_ATTR_ "\","

            /* Column 5: link info */
            file << "\"" dmiObjLinkInfo(o) "\"\n"
        }

        objCnt++
        o = next(o)
    }

    if (o==null) {
        dmiLastExportObj = null
    } else {
        dmiLastExportObj = previous(o)
    }

    close file
    return 0!=null
}

void dmiExportModulePart_(string modID, string filePath, int maxObjCnt, bool startAtBegin) {
    bool hasMore = dmiExportPartialModule_(modID, filePath, maxObjCnt, startAtBegin)

    if (hasMore) {
        oleSetResult("true")
    } else {
        oleSetResult("false")
    }
}


/* New methods to improve the interface */
bool dmiObjHasMatlabLinks_(Object o) {
}

void dmiSelectMatlabLink_(Object o, int idx) {
}

void dmiUpdateMatlabLinkMenus_(Object o) {
}

void dmiChooseLinkedItem(DBE listItem) {
    int index = get(listItem)
    int count = 0
    Link outLink
    Object o = dmiActiveObj

    for outLink in o->"*" do {
        Object trgObj = target(outLink)
        if (dmiIsMATLABSurrogate(module(trgObj))) {
            if (count == index) {
                current = dmiSurrogateM_
                dmiSelectBlock_(trgObj)
                return
            }
            count++
        }
    }
}

void dmiSelectLinkedItem_(Object o) {
    totalLinks = dmiCountSurrogateLinkedItems(o)
    DB selectBox;
    DBE selectList;
    string dummyList[] = {}

    if (totalLinks==0) {
        infoBox("Selected object is not linked to any MATLAB objects")
        return
    }

    // Create a dialog box to choose the appropriate MATLAB link
    dmiActiveObj = o
    selectBox = create(module(o), "Choose the item to select")
    selectList = list(selectBox, "Linked Surrogate Items: ", 4, dummyList)
    set(selectList, dmiChooseLinkedItem)
    realize selectBox
    dmiFillSurrogateLinkedItems(selectList, o)
    show selectBox

}


