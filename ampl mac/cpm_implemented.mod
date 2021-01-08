# sets
set nodes;
param orig in nodes;
param dest in nodes diff {orig};

set arcs within (nodes diff {dest}) cross (nodes diff {orig});

# params
param tau_max {(i,j) in arcs} >= 0; # duració màxima de la tasca
param tau_min {(i,j) in arcs} >= 0; # duració mínima de la tasca
param cost {(i,j) in arcs} >= 0;    # cost de cada tasca
param coeficient_paretto;           # coeficient paretto (=1: minimitzar temps, =0: minimitzar cost)
param ccptt;                        # coeficient de cost proporcional del temps total
param pressupost;           				# pressupost que té el projecte sense demanar cap prèstec
param tipus_interes;								# factor que multiplica el cost-pressupost en cas prèstec
var prestec_demanat binary;					# (=1 s'ha de demanar prestec, =0 otherwise)

param cost_total default 0;


# vars
var t {j in nodes} default 0;       # instant en que acabsa la tasca [i,j]
var tau {(i,j) in arcs} >= 0;            # durada de la tasca [i,j]

# funció i restriccions
minimize cost_paretto:
	coeficient_paretto*t[dest] +
	(1.0-coeficient_paretto)*
	( # cost total
		(sum{(i,j) in arcs} cost[i,j]*(tau_max[i,j]-tau[i,j])) + 	# cost segons diferència entre tau_max i tau
		ccptt * t[dest] +																					# cost proporcional al temps total
    prestec_demanat *																					# cost si s'ha de demanar prestec
		(
			(tipus_interes/100)*																		# tipus_interes * valor_pressupost_demamat
			(
				(sum{(i,j) in arcs} (cost[i,j]*(tau_max[i,j]-tau[i,j]))) +
				ccptt*t[dest]	- pressupost
			)
		)
	)
;


subject to tasca_entre_nodes {(i,j) in arcs}: t[i] + tau[i,j] - t[j] <= 0;
subject to t_fita_inferior {i in nodes}: t[i] >= 0;
subject to t_inicial_es_0 {i in nodes}: t[1] = 0;
subject to tau_fita_inferior {(i,j) in arcs}: tau_min[i,j] <= tau[i,j];
subject to tau_fita_superior {(i,j) in arcs}: tau[i,j] <= tau_max[i,j];

subject to interessos: # només es demana prèstec si se sobrepassa el pressupost
	prestec_demanat =
	(
		if
		(
			((sum{(i,j) in arcs} (cost[i,j]*(tau_max[i,j]-tau[i,j]))) + ccptt*t[dest] - pressupost) > 0
		) then 1
		else 0
	)
;
