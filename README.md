
About
-

Template project to build a library
- static (use ar)
- for Nordic nrf52 (ARM M4? ISA)
- a wedge (called once from main, calls abstraction layer to low-level libraries)
- cross-compiled on Linux host to ARM target
- Eclipse project
- hand-coded Makefile type of Eclipse project

Its a template: the project is mostly empty of SW content, it just demonstrates the build process.

The audience is people who want to understand cross building libraries (for targets not the same as the host.)  Some compiler flags are relevant only if you are using ARM M4.  No compiler flags are specific to the exact target: nrf52 family chip.

In other words, I have project A that is very specific to a target.  
The target:
- is chip family nrf52) made by Nordic Semicondutor Inc.
- has ARM mcu but also has other peripherals
- has its own proprietary SDK.  The SDK doesn't provide an OS, but provides libraries for using the peripherals, etc.  
Project A has a convoluted hand-coded Makefile, mostly written by others.

I have another project B:
- target independent
- calls an OSAL (OS abstraction layer) that abstracts away the specific peripherals of the target.  
- is an Eclipse project that automatically generates makefiles.

I want to keep the projects separate, but link the project B into project A.  So I build project A as a static library (an archive of object files) to link into project B.

See Also
-

Basic intro at: http://www.adp-gmbh.ch/cpp/gcc/create_lib.html

Discussion of library ordering problem: http://eli.thegreenplace.net/2013/07/09/library-order-in-static-linking


