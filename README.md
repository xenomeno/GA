# GA
Genetic Algorithms

Simple Genetic Algorithm implementation for maximizing f(x)=x^10 and minimizing De Jong's F1 and F5 functions.

Implementation is in Lua and is based on David E. Goldberg's book "Genetic Algorithms: In Search, Optimization and Machine Learning".

Different population sizes are tested along without and with fitness scaling(a few different scaling values). Ranking procedures and selection methods are also compared. Bitstring implementation is optimized to be internally represented as 32bit integer words. Octal strings are ordinary strings. Bitmap file saving implementation is in pure Lua and is very slow but is used to draw graph for comparisions.

Following are some comparisons graphics. On the left is the Interim performance performance and on the right the Ultimate performance up to each generation. Interim is the on-line performance so far - the best objectives up to a given generation are summed and divided by the generation to get the average best through the generations. Ultimate is the off-line performance plotting the best individual so far for all generations tested.

Compare and contrast alternative selection methods:
![](Selections.png?raw=true "Title")

Compare and contrast alternative scaling schemes:
![](Scaling.png?raw=true "Title")

Compare and contrast alternative ranking procedures:
![](Scaling.png?raw=true "Title")

Compare and contrast different crossover points count:
![](CrossoverPoints.jpg?raw=true "Title")
