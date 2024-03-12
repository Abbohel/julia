#!/usr/bin/env -S julia --project=@scriptdir

module Main2
using LinearAlgebra
function take_heap_snapshot()
    flags = Base.open_flags(
        read = true,
        write = true,
        create = true,
        truncate = true,
        append = false,
    )
    nodes = IOStream("<file lala.nodes>")
    ccall(:ios_file, Ptr{Cvoid}, (Ptr{UInt8}, Cstring, Cint, Cint, Cint, Cint),
        nodes.ios, "lala.nodes", flags.read, flags.write, flags.create, flags.truncate)
    edges = IOStream("<file lala.edges>")
    ccall(:ios_file, Ptr{Cvoid}, (Ptr{UInt8}, Cstring, Cint, Cint, Cint, Cint),
        edges.ios, "lala.edges", flags.read, flags.write, flags.create, flags.truncate)
    strings = IOStream("<file lala.strings>")
    ccall(:ios_file, Ptr{Cvoid},(Ptr{UInt8}, Cstring, Cint, Cint, Cint, Cint),
        strings.ios, "lala.strings", flags.read, flags.write, flags.create, flags.truncate)
    json = IOStream("<file lala.metadata.json>")
    ccall(:ios_file, Ptr{Cvoid}, (Ptr{UInt8}, Cstring, Cint, Cint, Cint, Cint),
        json.ios, "lala.metadata.json", flags.read, flags.write, flags.create, flags.truncate)
    ccall(:jl_gc_take_heap_snapshot,
        Cvoid,
        (Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid}, Cchar),
        nodes.handle, edges.handle, strings.handle, json.handle,
        Cchar(false))
    ccall(:ios_close, Cint, (Ptr{Cvoid},), nodes.ios)
    ccall(:ios_close, Cint, (Ptr{Cvoid},), edges.ios)
    ccall(:ios_close, Cint, (Ptr{Cvoid},), strings.ios)
    ccall(:ios_close, Cint, (Ptr{Cvoid},), json.ios)
    return nothing
end

#Open a new julia session and run the following commands to get a chrome snapshot:
#=
open("lala.heapsnapshot", "w") do io
Profile.HeapSnapshot.assemble_snapshot("lala", io)
end
=#

Base.@ccallable function main() :: Cint
    # println("Hello, world!")
    a = rand(10)
    b = sum(a)
    ccall(:printf, Int32, (Ptr{UInt8},Float64...), "hello_world %lf", b)
    ccall(:jl_,Cvoid, (Any,), lu(rand(10,10)))
    take_heap_snapshot()
    return 0
end

precompile(main, ())
precompile(Base._str_sizehint, (String,))
precompile(Base._str_sizehint, (UInt32,))
precompile(print, (Base.GenericIOBuffer{Memory{UInt8}}, String))
precompile(print, (Base.GenericIOBuffer{Memory{UInt8}}, UInt32))
precompile(join , (Base.GenericIOBuffer{Memory{UInt8}}, Array{Base.SubString{String}, 1}, String))
precompile(join , (Base.GenericIOBuffer{Memory{UInt8}}, Array{String, 1}, Char))
precompile(Base.showerror_nostdio, (Core.MissingCodeError, String))
precompile(Base.VersionNumber, (UInt32, UInt32, UInt32, Tuple{}, Tuple{}))
precompile(! ,(Bool,))
end