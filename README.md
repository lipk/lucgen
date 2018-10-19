# lucgen

lucgen is a dead simple script that runs Lua snippets embedded into C source
code. It's an uncomplicated, convenient tool for code generation. Mind that the
scripts are not sandboxed.

Simple example:
    
    /* Lua snippets are enclosed in @ */
    @
    function declvars(type, prefix, count)
        for i = 1, count do
            -- use emit to yield some code
            emit(type .. ' ' .. prefix .. i .. ';\n')
        end
    end
    @

    typedef struct S {
        @declvars('int', 'x', 10)@
    } S;

Output:
    
    /* Lua snippets are enclosed in @ */
    

    typedef struct S {
        int x1;
        int x2;
        int x3;
        int x4;
        int x5;
        int x6;
        int x7;
        int x8;
        int x9;
        int x10;
        
    } S;


Usage: lucgen.lua SOURCEFILE \[-o TARGETFILE\] \[-l PRELOADFILE\] \[-h\]

In a tad more detail:

* SOURCEFILE is the file to process
* The result is written to stdout by default, use -o to redirect it into
  TARGETFILE
* You can optionally specify one or more extra Lua scripts to be run before
  processing the source with -l. (The flag is required before each script).
* -h prints the help and exits

lucgen requires Lua 5.3 at minimum.
