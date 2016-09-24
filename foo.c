
#include "foo.h"

// class data member
int Foo::bar;

// Declare method defined in other project
extern void initLogging();

// This method is called from other project
int Foo::foo() {

	// call a function defined by other project
	initLogging();
	return 1;
}
