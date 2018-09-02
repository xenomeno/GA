# GA
Genetic Algorithms

Simple Genetic Algorithm implementation for maximizing f(x)=x^10 and minimizing De Jong's F1 function f(x,y,z)=x^2+y^2+z^2

Two implementations via 2-alphabet(bitstrings) and 8-alphabet are compared on both functions as different parameters are tweaked to investigate how the objective changes as generations are advancing. Implementation is in Lua and is based on David E. Goldberg's book "Genetic Algorithms: In Search, Optimization and Machine Learning".

Different max generations, population size are tested along without and with fitness scaling(a few different scaling values). Bitstring implementation is optimized to be internally represented as 32bit integer words. Octal strings are ordinary strings. Bitmap file saving implementation in is pure Lua and is very slow but is used to draw graph for comparisions.

![Alt text](GA/Max/SGA_OCTAL_POW_10_gens20_pop30.bmp?raw=true "Title")
