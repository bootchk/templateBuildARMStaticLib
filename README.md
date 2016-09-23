Work in progress

Template project to build a library
- static (use ar)
- for Nordic nrf52 (ARM M4? ISA)
- a wedge (called once from main, calls abstraction layer to low-level libraries)
- cross-compiled on Linux host to ARM target
- Eclipse project
- hand-coded Makefile type of Eclipse project

Its a template: the project is mostly empty of SW content, it just demonstrates the build process.

In other words, I have one project that is very specific to a target  (nordic chip family nrf52) that has ARM mcu but also has other peripherals, and its own proprietary SDK.  The SDK doesn't provide an OS, but provides libraries for using the peripherals, etc.  This project has a convoluted hand-coded Makefile, mostly written by others.

I have another project which is target independent, calling an OSAL (OS abstraction layer) that abstracts away the specific peripherals of the target.  Currently the project is an Eclipse project that automatically generates makefiles.

I want to keep the projects separate, but link the second project into the first project.  So I build a static library (an archive of object files) to link into the second project.

