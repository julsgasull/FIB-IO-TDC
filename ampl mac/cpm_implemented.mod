# sets
set nodes;
param orig symbolic in nodes;
param dest symbolic in nodes, <> orig;

set arcs within (nodes diff {dest}) cross (nodes diff {orig});

# params
param tau_max {(i,j) in arcs} >= 0; # duració màxima de la tasca
param tau_min {(i,j) in arcs} >= 0; # duració mínima de la tasca
param cost {(i,j) in arcs} >= 0;    # cost de cada tasca
param coeficient_paretto;           # coeficient paretto (=1: minimitzar temps, =0: minimitzar cost)
param ccptt;                        # coeficient de cost proporcional del temps total
param pressupost;           				# pressupost que té el projecte sense demanar cap prèstec
param tipus_interes;
var prestec_demanat binary;

param cost_total default 0;


# vars
var t {j in nodes} default 0;       # instant en que acabsa la tasca [i,j]
var tau {(i,j) in arcs};            # durada de la tasca [i,j]

# funció i restriccions
minimize time:
	coeficient_paretto*
	( # temps total
		t[dest]
	)
  +
  (1-coeficient_paretto)*
	( # cost total
		sum{(i,j) in arcs} cost[i,j]*(tau_max[i,j]-tau[i,j]) + 	# cost segons diferència entre tau_max i tau
		ccptt * t[dest] +																				# cost proporcional al temps total
    prestec_demanat *																				# cost si s'ha de demanar prestec
		(
			tipus_interes*
			(
				sum{(i,j) in arcs} cost[i,j]*(tau_max[i,j]-tau[i,j]) +
				ccptt*t[dest]
			)
		)
	)
;


subject to tasca_entre_nodes {(i,j) in arcs}: t[i] + tau[i,j] - t[j] <= 0;
subject to t_positiu {i in nodes}: t[i] >= 0;
subject to fita_inferior {(i,j) in arcs}: tau_min[i,j] <= tau[i,j];
subject to fita_superior {(i,j) in arcs}: tau[i,j] <= tau_max[i,j];

subject to interessos: # només es demana prèstec si es sobrepassa el pressupost
	prestec_demanat =
	(
		if
		(
			sum{(i,j) in arcs} cost[i,j]*(tau_max[i,j]-tau[i,j]) + ccptt*t[dest] - pressupost > 0
		) then 1
		else 0
	)
;
