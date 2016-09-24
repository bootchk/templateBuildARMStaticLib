
// main() to test library

#include "foo.h"

// Define function called by library.
// Not static, i.e. is visible outside this file i.e. declared extern in library
void initLogging() {}

int main() {
	Foo myFoo;

	int baz = myFoo.foo();
}
