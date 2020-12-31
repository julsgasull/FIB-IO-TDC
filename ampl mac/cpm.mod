# sets
set nodes;
param orig symbolic in nodes;
param dest symbolic in nodes, <> orig;

set arcs within (nodes diff {dest}) cross (nodes diff {orig});

# params
param tau {(i,j) in arcs} >= 0;
# duracion de trabajo [i,j]

# vars
var t {j in nodes} default 0; # instant en que acabsa la tasca [i,j]

# funció i restriccions
minimize time: t[dest];
subject to r1 {(i,j) in arcs}:
	t[i] + tau[i,j] - t[j] <= 0;
subject to r2 {i in nodes}:
	t[i] >= 0;
