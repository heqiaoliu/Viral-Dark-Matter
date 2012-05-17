
//----------------------repGroup------------------
function repGroup(expDate,repNum){
    this.date=new Array();
    this.reps=new Array();
    this.add(expDate,repNum);
}

repGroup.prototype.add = function(expDate,repNum){
    var pos=this.date.indexOf(expDate);
    if(pos>=0)
        this.reps[pos].push(repNum);
    else{
        this.date.push(expDate);
        this.reps.push(new Array(repNum));
        }
}

repGroup.prototype.getAll(){
    return this.reps;
}
//--------------------plateGroup-----------
function plateGroup(plateName,expDate,repNum){
    this.plateNames=new Array();
    this.repGroups=new Array();
    this.add(plateName, expDate, repNum);
}

plateGroup.prototype.add=function(plateName,expDate,repNum){
    var pos=this.plateNames.indexOf(plateName);
    if(pos>=0)
        this.repGroups[pos].add(expDate, repNum);
    else{
        this.plateNames.push(plateName);
        this.repGroups.push(new repGroup(expDate,repNum));
    }
        
}
//---------------------bactGroup------------
function bactGroup(){
    this.bactNames=new Array();
    this.plateGroups=new Array();
}

bactGroup.prototype.add=function(bactName,plateName,expDate,repNum){
    var pos=this.bactNames.indexOf(bactName);
    if(pos>=0)
        this.plateGroups[pos].add(plateName,expDate, repNum);
    else{
        this.bactNames.push(bactName);
        this.plateGroups.push(new plateGroup(plateName,expDate,repNum));
    }
}
//-----------------------indivObj---------------
function indivObj(bactName,plateName,expDate,repNum){
    this.bactName=bactName;
    this.palteName=plateName;
    this.expDate=expDate;
    this.repNum=repNum;
}
//-----------------------selectList-------------
function selectList(){
    this.groupList=new bactGroup();
    this.indivList=new Array();
    this.wellList=new Array();
}

selectList.prototype.addGroup=function(bactName,plateName,expDate,repNum){
    this.groupList.add(bactName,plateName,expDate,repNum);
}

selectList.prototype.addIndiv=function(bactName,plateName,expDate,repNum){
    this.indivList.push(new indivObj(bactName,plateName,expDate,repNum));
}

selectList.prototype.addWell=function(wellNum){
    this.wellList.push(wellNum);
}

selectList.prototype.getAllGroups=function(){
    return;
}
