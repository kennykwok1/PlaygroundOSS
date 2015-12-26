C# Documentation
================

Introduction
-------------

The C++ Engine interacts with a Scripting Language in order to develop more efficiently.
The main scripting language used with this Engine is **LUA**, but we also developed a C# framework to script in C#.
To get more details about the LUA Scripting, please refer to Modules/Scripting.txt

Be aware that this is an experimental work and that this had not gone past the test phase - ie it had never been in production.

Here will be explained how the C# framework does work and how to use it.

### The C# framework
can be found in ```CSharpVersion/Engine_Prototype/EnginePrototypeCS/```

### The C++ Compiler
can be found in ```CSharpVersion/CSharp_CPPCompiler```

### The C++ Runtime C# 
can be found in ```Engine/libs/RuntimeCSharp/RuntimeLibrary/```

A How To Use section is available at the end of this document to help you woth installing and running 
the C# framework for our Game Engine.

Communication between C++ and C#
---------------------------------

To communicate with **LUA**, the only way was to use the LUA stack for every single operation involving C++-LUA communication.
With C#, it is possible to call exported static C++ methods directly.

To call a C++ Engine method from C#, we proceeded as is : 
- The method must be Scripting Language independent ; that means no interaction with the LUA stack for example.
- Define the methods in ExportListC_Likefunction.h (in the Engine project).
  Export them in the ExportListC_Likefunction.cpp, file of the Game project
  converting the static call to an instance call through the pointer transmitted as an argument if necessary.
  See Engine/source/Scripting/ExportListC_Likefunction.h and .cpp for more implementation details.
- Import them in the C# Framework
- Define a method in C# wrapping this imported method.

C# Framework Architecture and How it works
-------------------------------------------

Basically, each C++ scripting object has a wrapper in C#.
Hereafter will be detailed the Framework Core classes 

### GameObject

To correctly manage the communication between the two languages, the binding between objects (one in C++, one in C#), 
we developed a C# Framework to provide simple APIs for programmers.

**GameObject** (FrameworkCore/GameObject.cs) is the most generic class of the C# framework.
All wrappers inherit this class.

Each GameObject can be bound to 1 and only 1 C++ object. The two instances are common handle.
The handle is a unique unsigned int which identifies the C# object.
It is given and registered in the C++ object when binding, so the C++ object could identify the C# object bound with it.
The default behavior is to bind directly when instantiating a C# object, but it is also possible to create an empty C# object 
(without any C++ object bound) and to bind it later.

It is also used to register callbacks in the C++ Engine.
More details about callbacks from C++ to C# can be found hereafter.

A GameObject contains a handle, a typeID, a tag and a pointer to a CppObject.

Each GameObject contains a typeID which is used to verify that the C++ and the C# object are the same type 
and to authorize the binding or not.
The typeID comes from the BaseType.h file (Engine/include/BaseType.h)

A pointer is also stored in C# pointing directly to the C++ object.
Communicating it to the C++ makes us able to call methods from this object in C++ directly without having to 
find the object back through his handle.

### WrapperRegister

Every GameObject is registered in the WrapperRegister, a singleton allowing to find a GameObject through its handle.
In fact, the handle is the index in the array of GameObject of the WrapperRegister.
The possibility of finding a GameOject through its handle makes the callbacks possible from C++ to C# just knowing
the handle of the C# object.

### NativeManagement

NativeManagement is a static class used to interact with C++.
It is able to register and unregister C# wrappers for each C++ object.
It also has a static method to destroy a C# wrapper directly
from the C++ Engine.

The pointer of this static function must be sent to the C++ Engine 
at the beginning of the program.

### __MarshallingUtils and __FrameworkUtils

They are static classes providing utility methods.


Game Object Life Cycle
-------------------------

When instantiating a GameObject in C# you an either create an empty one or instantiate it with parameters and create a C++ object
at the same time. Both objects will be bound through the system previously described.
If an empty C# object had been created, no C++ object had been created with it. You will have to bind it manually with an already 
instantiated C++ object. The typeID must correspond and remember that only one C++ object can be bound with C# one object.

When a C++ or a C# Object dies, the binding has to be destroyed. Indeed it would be very problematic to call methods on a destroyed
C++ object from C# or to try to callback on a C# destroyed object.
A C++ object can either die "by itself", meaning that the destruction is asked by the Engine or its destruction can be asked
from the C# framework by Disposing the GameObject.
The destruction is divided in 3 steps : 

#### The C++ destruction is asked (either by the Engine or the C# script)

If the destruction is asked by the Engine

1. The C++ destructors are called.
2. The C++ calls back the C# to destroy the bound C# object
3. Dispose the C# object

If the destruction is asked by the C# script, it's actually just an unbinding
1. The C# object is emptied (Disposed)
2. The C++ object will be destroyed by the Engine opportunely.

Callback System
---------------

The Engine is based on running tasks and receive callbacks from the scripting language.
With LUA the callbacks where static methods called through their names.
With C#, callbacks are delegates that can be static or linked with an instance of a C# object.

As explained before, each C# GameObject bound with a C++ Object has the same handle than the C++ Object,
so the C++ Object is able to find the right C# GameObject it has to call back.

Static methods have been designed to call back the right object from C++ to C#.
The handle and the callback number are regrouped in a unsigned int 32 and passed back to the C# that
is in charge of retrieving the right object and call its right callback.

There will not be a detailed technical explanation here, so if needed, refer to the source code 
of the following classes : 

- Framework/Core/GameObject.cs
- Framework/Core/NativeManagement.cs
- Engine/source/Scripting/CKLBScriptEnv_forCSharp.cpp

### Basically, a callback is a X phases process

1. The C++ object is asked to call back the C#, this method is defined in Engine/source/Scripting/CKLBScriptEnv.h
It is for instance 

  ```csharp
call_eventDragIcon(const char* funcName, CKLBObjectScriptable* obj, u32 type, s32 dragX, s32 dragY)
```

2. This call_eventDragIcon(...) method is declared once in CKLBScriptEnv.h and defined for each scripting language.
The funcName is only used for LUA.

  ```csharp
void CKLBScriptEnv::call_eventDragIcon(const char* funcName, CKLBObjectScriptable* obj, u32 type, s32 dragX, s32 dragY)
{
  m_call++;
  u32 objectHandle = obj->getScriptHandle();
  klb_assert(objectHandle != _NULLHANDLER,"ScriptHandle is null");
    callbackUII(objectHandle, type, dragX, dragY);
}
```

  The object handle is passed back to the C#.
If the C# object can have more than 1 callback, the callback number is added to the Handle (3 upper bits).

3. A signature specific static function is then called.
In this example, it is callbackUII().
These methods are exported in C++ and imported in C#.

4. public static void doCallBackUII(uint cbInfos, uint uint_1, int int_1, int int_2)
A C# method of NativeManagement is wrapping the imported static function and redirects the call to the
right object and the right callback.

5. By default, the callback method is a virtual method calling the object delegate, specific for each object.
This allows the developer to override the method and define a general behavior or to keep the default behavior.


MonoLib
-------

The C# version of the Engine uses Mono as an embedded module.
The callback system is using the MonoLib in order to invoke C# methods from C#.

Moreover, using the MonoLib to run the C# executable makes us able to debug with MonoSoftDebugger 
(in MonoDevelop). MonoSoftDebugger allows to run a C# executable from a C++ one and debug the C# 
executable (breakpoints, stop, etc.).
You will find more details on how to process at the end of this document.

You will find more details about Embedding Mono here 

- http://www.mono-project.com/Embedding_Mono

C++ version
-----------

Mono is a great tool to run the executable on PCs and to help during the debugging phase, but for devices (especially
iOS, it is a bit problematic having multiple executables).
To avid those problems, we developed a C# compiler that translates the C# code into C++ code and supporting the basic C# 
functionalities. Moreover, this results in a lighter and an only one language final executable.

You will find more documentation about the Compiler at the bottom of this document.

A "Runtime C#" had been developed to mimic the C# essential classes way of working (such as String, Array, List, Dictionary).
It provides exactly similar methods to the C# ones. An Object allocator and a Garbage Collector has also been developed.

For more details, refer to the source code.

How To Run using C# with Mono
-----------------------------

### How to Install

[Mono Download Link](http://monodevelop.com/Download)

- If you are working with Windows, install the .NET Framework 4.0 or upper and GTK#
- If you are using OSX, install Mono + GTK#

### How to Run MANUALLY

#### Edit File

Edit the paths for your development environment in ```CKLBScriptEnv_forCSharp.cpp```

I recommend to install all the files in something like

```
D:\\KLab\\playground\\Engine\\porting\\Win32\\Output\\Debug_CSharp
```

*(Engine output directory)*.

- mono_set_dirs ("YourOwnPath\\libs\\lib","../../etc/");
- const char* frameworkPath = "YourOwnPath\\MyCSharpLibForWindows.dll";
- const char* bootPath 		= "YourOwnPath\\start.dll";

#### Compile the different files

1. Compile the Engine and the Sample Game with the Debug_CSharp debug mode

  Output : ```/Engine/porting/Win32/Output/Debug_CSharp```

2. Compile the C# framework

  Output : ```/VariousPrototyping/Engine_Prototype/EnginePrototypeCS/EnginePrototype/bin/Debug```

3. Compile your C# program

  Output : ```/SampleProject/CSharp/bin/Debug```

4. Run Mono Soft Debugger Listener

- Required #1

  Set the following environment variable ```MONODEVELOP_SDB_TEST=1```

- Required #2

  Custom Command Mono Soft Debugger must be at the bottom of preferred debuggers.
  It can be changed in ```Tools > Options > Debugger > Preferred Debuggers Run > Run With > Custom Command Mono Soft Debugger > Listen```

  **Start the debugger listening on port 127.0.0.1:10000**


#### Execute the following command line :

```
D:\KLab\playground\Engine\porting\Win32\Output\Debug_CSharp\SampleGame.exe -e "D:/KLab/playground/Projects/ScriptSample/SimpleItem/.publish/iphone" -i "D:/KLab/playground/Projects/ScriptSample/SimpleItem/.publish/iphone"
```

### Common Problems

- MonoDevelop does not display anything in ```Run > Run With``` 

  - If the project is not an Executable MonoDevelop won't provide this Menu
  - Change the project to an executable in the Project Properties or create an empty project

- The Engine stops with the following error : 

- "Mono JIT init failed (this is NOT a matter of JIT)."
- "C# assembly loading failed."

  - Be sure to have the right path in frameworkPath

- "C# boot assembly loading failed."

  - Be sure to have the right path in bootPath
  - Take care of the extension.


How To Run using C# converted to C++
--------------------------------------

1. Open the C#->C++ Compiler solution 

  ```
(/CSharpVersion/CSharp_CPPCompiler/CompilerProject/CompilerProject.sln)
```

2. Compile the framework and pass as argument : (Example path where the project was installed)

  
  ```
C:\playgroundOSS\CSharpVersion\EnginePrototype -oa C:\playgroundOSS\SampleProject\Cpp\ -compileframework
```

3. Compile your C# project

  ```
-framework C:\playgroundOSS\CSharpVersion\EnginePrototype  -user C:\playgroundOSS\SampleProject\CSharp\Program.cs -oa C:\playgroundOSS\SampleProject\Cpp\out.cpp
```

4. Move these files from the output location of the step 2 to 


  ```
  /Engine/libs/RuntimeCSharp/RuntimeLibrary/inline/

  ```

  - __InternalUtilsGetTypeID_specializations.inl
  - classPrototypes.inl

5. Run your C++ project

  Open the SampleProject Solution (in Engine/porting/Win32/SampleProject/)
  Select the "Debug_Cpp" debug configuration.
  Don't forget to specify the path for the assets. (```-i``` and ```-e``` arguments)
  Run it!

About the compiler and runtime library
---------------------------------------

The C++ Runtime C# found in ```Engine/libs/RuntimeCSharp/RuntimeLibrary/``` is completly independant from the game engine and the compiler also.
It could be moved to a seperate project and be a usefull technology for other projects, directly and cleanly without any dependance on 
Playground game engine.

Command line help about the compiler
--------------------------------------

The compiler will generate ONE big C++ file containing all the user code translated from C#.
The generated code will use the C++ runtime library associated with it.

Here is the help extracted from the compiler command line :

### Command line options

```
-o or -or
```

- Description : Tells the output path (relative). If no output option is used, the result will be displayed in the console.
- Argument : Output path, including the file name

```
-oa
```
- Description :  Tells the output path (absolute). If no output option is used, the result will be displayed in the console.
- Argument : Full output path, including the file name

```
-user
```

- Description : Tells the path to the user project directory. If this option is not used, the first command line argument needs to be this path.
- Argument : Full path to the project directory.

```
-framework
```

- Description : When a project which uses the framework is compiled, tells the path to the framework directory.
- Argument : Full path to the framework directory.

```
-compileframework
```

- Description : Used to compile the framework only. In this case, -framework is not used and -user is the path to the framework.
- Argument : None.

```
-ignore
```

- Description : Rather than parsing the mentioned files only, the compiler will parse all the files
except the ones which have been enumerated.
- Argument : None.

```
-h or -help
```

- Description : Displays this menu.
- Argument : None.

### Compilation process

- Make sure that your C# project compiles in C#.
- Check that it does not contain restricted functionalities.
- Launch the compilation. The basic syntax for the command line is :

```
CompilerProject.exe <path to the project> [<C# file to parse 1> <C# file to parse 2> <...>] [-o <output file name>]
```

If no parsed file is explicited, every C# file of the folder will be recursively parsed.
For further explanation, see the description of the command line options above.
- Place the inline (.inl) files generated by the compiler into the "inline" folder of the "RuntimeLibrary" folder.
- If your project uses the game engine framework, you also need to compile it once, as described below.

### How to compile the framework ###

- Launch the compiler with the following command line :

```
CompilerProject.exe <path to the framework folder> -oa <output path> -compileframework
```

- Include the generated files (framework.h and framework.cpp) in your C++ project.
- Do not forget to compile the framework again if changes are made in C#.

See the command line executed for our project in the "How To Run using C# converted to C++" upper section.

Technical Information about the compiler
-----------------------------------------

This compiler is a prototype and is not ready for full production.
So for now the compiler documentation is very limited, and the source code is quite "technical".

See technical limitations of the compiler in ```/CSharpVersion/CSharp_CPPCompiler/Compiler_Limitations.txt```

Here is the technical difficulties that the compiler handle to transform C# to C++ code :

- Object reference maintenance for garbage collector :


Compiler know when assigning an object to an array, a reference member, a static variable, and generate the wrapper call for assigment.

Our garbage collector(GC) system rely on EXACT maintenance and avoid "generic" scanning type of algorithm which are too expensive to our taste.
Because of expression evaluation order that we have to keep the same as the original C# code, the generated code is more convoluted
that it would seems at first glance.

- Support C# delegate by generating template and have the compiler detect where the delegate is used and assigned.
Support include the "capture" of local variable to be able to generate a C++ class playing the role of the delegate.

- Wrapping all the calls to object, testing for NULL pointer to be able to throw NULL pointer exceptions.
(We do NOT rely on the C++ exception mecanism but do everything ourselves)

- Analyze dependancies between classes, constants, enum and other symbol declaration because C# allows those definition to be in any order
while need the C++ programmer to guarantee those. We do a dependancy analysis and generate the information in order to generate a C++ compliant code.
  
- Parser has still some issue with < and > symbol : conflict between generics and comparison operator making the grammar ambiguous.
It seems that it is a common problem among many C# parser. What we finally ended up with is to "preparse" the source code with a very stupid parser
which replace the generic < > symbol with unambiguous symbol.
Of course the trick is not perfect but that should work for all cases we have found until now.
  
- Parser has the classic "dangling else" issue, but again that should not be a problem.

- Generate code using macros to do : try / catch / finally.
Basically the current version of the generated code is quite heavy and not optimal.
We could, as an example, make a full analysis of the expression tree and decide that if a variable is "safe" (not null) we could generate all the code
in the same code path do NOT perform the null check anymore, we would gain in speed and performance.
