/* Copyright 2003-2004 The MathWorks, Inc. */

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
extern adder *createAdder();
extern void deleteAdder(adder *obj);
extern double adderOutput(adder *obj, int increment);

#endif /* _ADDER_CPP_ */


