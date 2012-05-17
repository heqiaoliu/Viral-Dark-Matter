/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#ifndef _ADDER_CPP_
#define _ADDER_CPP_

class adder {
private:
	int int_state;
public:
	adder();
	int add_one(int increment);
	int get_val();
};

// External declaration for class instance global storage
extern adder *adderVar;

// Method wrappers
extern void createAdder();
extern void deleteAdder();
extern int adderOutput(int increment);

#endif /* _ADDER_CPP_ */


