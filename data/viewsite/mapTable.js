
Array.prototype.addGroupObj=function(obj){
	this.push(obj.key);
	this[obj.key]=obj;
}

function selectTable(){
	this.groupStorage=new Array();
	this.individualStorage=new Array();
}


selectTable.prototype.addGroupMem=function(obj){
	var temp=obj.hashCode();
	var index=this.groupStorage.indexOf(temp);
	if(index<0){
		this.groupStorage.addGroupObj(new groupObj(temp));
	}
	this.groupStorage[temp].add(obj);
}

selectTable.prototype.addIndMem=function(obj){
	this.individualStorage.push(obj);
}


function groupObj(code){
	this.key=code;
	this.members=new Array();
}

groupObj.prototype.add=function(obj){
	this.members.push(obj);
}

groupObj.prototype.GroupLabel(){
	var reps="*"+this.members[0].label+" Rep";
	for(int i=0;i<this.members.length;i++){
		reps+=this.members[i].replicateNum;
		if(i<this.members.length-1)
			reps+="&";	
	}
}

function dataObj(exp,bact,plate,replicate,expdate){
	this.expId=exp;
	this.bactId=bact;
	this.plateName=plate;
	this.replicateNum=replicate;
	this.expDate=expdate;
}



dataObj.prototype.hashCode=function(){
	return this.bactId+this.plateName+this.expDate;
}

dataObj.prototype.label=function(){
	return this.bactId+" "+plateName;
}



