# sets
set nodes;
param orig symbolic in nodes;
param dest symbolic in nodes, <> orig;

set arcs within (nodes diff {dest}) cross (nodes diff {orig});

# params
param tau_max {(i,j) in arcs} >= 0; # duració màxima de la tasca
param tau_min {(i,j) in arcs} >= 0; # duració mínima de la tasca
param cost {(i,j) in arcs} >= 0;    # cost de cada tasca
param alpha;                        # coeficient paretto (=1: minimitzar temps, =0: minimitzar cost)
param ccptt;                        # coeficient de cost proporcional del temps total
/*param pressupost_inicial;           # pressupost que té el projecte sense demanar cap prèstec*/

# vars
var t {j in nodes} default 0;       # instant en que acabsa la tasca [i,j]
var tau {(i,j) in arcs};            # durada de la tasca [i,j]

# funció i restriccions
minimize time:
	alpha*        ( # temps total
                  t[dest]
                )
  +
  (1-alpha)*    ( # cost total
                  ( sum{(i,j) in arcs} cost[i,j]*(tau_max[i,j] - tau[i,j]) ) # cost segons diferència entre tau_max i tau
                  +
                  ( ccptt*t[dest] ) # cost proporcional al temps total
                  /*+
                  (1-alfa2)*prèstec # cost en cas de haver de demanar prèstec
                  */
                )
;

subject to tasca_entre_nodes {(i,j) in arcs}: t[i] + tau[i,j] - t[j] <= 0;
subject to t_positiu {i in nodes}: t[i] >= 0;
subject to fita_inferior {(i,j) in arcs}: tau_min[i,j] <= tau[i,j];
subject to fita_superior {(i,j) in arcs}: tau[i,j] <= tau_max[i,j];
