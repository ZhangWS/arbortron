# Physically Evolving Networks

This was a project that I conducted under the supervision of Professor Alfred Hüler at the Institute for Complexity Research at the University of Illinois in 2011. His students had conducted experiments to simulate Physically Evolving Networks (PEN) with metal particles in oil that had voltage applied to it (see Hubler, Stephenson, Lyon, and Swindeman 2011 for a description of the original experiment). When a current starts to flow, the metal particles formed branch-like structures, hence the name arbortron.

My job was to provide proof-of-concept MATLAB code that digitally emulated the experimental behavior of the metal particles. In other words, to digitally simulate arbortron formation.

Given hardware and programming limitations, the MATLAB code provided here simulated a small grid with a minimal number of arbortrons. In fact, any more than about 4 or 5 particles on the board crashed the program due to memory demands on my MacBook Pro (Core 2 Duo, 2 gb RAM). While it was not possible to observe branch formation with this code, it was enough to simulate how the metal particles reacted to a charged medium (oil with current flowing through it) more or less accurately.

Computing limitations and increasing research and coursework demands from my home department meant that I was not able to finish refining the code at the time. I believe that Dave Lyon eventually ported my code to Cuda C to expand the experimental medium (from 10x10 to 720 x 720) with more particles (32 insead of just 4). A simulation of the finished code, which was an expansion of my original project, can be seen here: https://www.youtube.com/watch?v=pYGAB6vaT08.
