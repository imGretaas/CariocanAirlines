# ------------------------------
# Progetto di Ricerca Operativa
# di Greta Cavedon
# ------------------------------

# Insiemi del modello

set I; # tipi di aereo
set J; # classi | e=economy, p=premium, b=business
set M; # mesi 

# Variabili del modello
var x{I,J,M} >=0 integer; # biglietti da vendere 
var z binary;	  # attiva lo sconto del 10%
var k{I} binary;  # attiva lo sconto del 5% sui voli di dicembre in classe business
var v binary; 	  # passeggeri in economy alpha >> passeggeri in economy beta   
#var v2 binary;   # attivazione di un solo sconto

# Parametri del modello

param capacity{I} integer; # capacita' di ciascun aereo
param gasoline{J}; # carburante per ciascuna classe
param hostess{J};  # costo personale di bordo/terra
param food{J};	   # costo cibo
param tax integer; # tasse aeroportuali 
param iva{J};      # iva per biglietto venduto 
param Ma integer;  # soglia della classe economy per l'aereo alpha     
param Mb integer;  # soglia della classe economy per l'aereo beta
param C integer;   # soglia per sconto IVA
    
# Funzione obiettivo 

maximize obj: 1450* sum{i in I, m in M}(x[i,'e', m]) + 2000* sum{i in I, m in M}(x[i,'p',m])
+ 3100* sum{i in I, m in M}(x[i,'b',m]) - 1160*(gasoline['e']+hostess['e']+food['e']) * sum{i in I, m in M}(x[i,'e',m]) 
- 1600*(gasoline['p']+hostess['p']+food['p'])* sum{i in I, m in M}(x[i,'p',m])
- 2480*(gasoline['b']+hostess['b']+food['b'])* sum{i in I, m in M}(x[i,'b', m]) - iva['e']* sum{i in I, m in M}(x[i,'e', m]) 
- iva['p']* sum{i in I, m in M}(x[i,'p', m]) - iva['b']* sum{i in I, m in M}(x[i,'b',m]) - tax* sum{i in I, j in J, m in M}(x[i,j,m])
+ 0.1*z*sum{i in I, j in J, m in M}(x[i,j, m])-1160*0.05*k['alpha']*x['alpha','b','d']-1600*0.05*k['beta']*x['beta','b','d']-2480*0.05*k['gamma']*x['gamma','b','d'];

# Vincoli

# Capacita' di ciascun aereo

s.t. capacity_alpha {m in M}: sum{j in J} x['alpha', j, m]<=(capacity['alpha']);
s.t. capacity_beta {m in M}: sum{j in J} x['beta', j, m]<=(capacity['beta']);
s.t. capacity_gamma {m in M}: sum{j in J} x['gamma', j, m]<=(capacity['gamma']);

# Sconto sui biglietti venduti

s.t. sconto_dieci: sum{i in I, j in J, m in M}x[i, j, m]>=C*z;

# Quantita' minima di riempimento

s.t. min_alpha {m in M}: sum{j in J} x['alpha', j, m]>=0.8*capacity['alpha'];
s.t. min_beta {m in M}: sum{j in J} x['beta', j, m]>=0.8*capacity['beta'];
s.t. min_gamma {m in M}: sum{j in J} x['gamma', j, m]>=0.8*capacity['gamma'];

# Posti in Economy

s.t. economy_tickets {m in M}: sum{i in I}x[i,'e', m]>= sum{i in I}(x[i, 'p', m]+x[i, 'b', m]);

s.t. economy_alpha {m in M}: x['alpha', 'e', m]>= x['alpha','p', m]+x['alpha','b', m];
s.t. economy_beta {m in M}: x['beta', 'e',m]>= x['beta','p',m]+x['beta','b',m];
s.t. economy_gamma {m in M}: x['gamma', 'e', m]>= x['gamma','p', m]+x['gamma','b', m];

# Posti in Premium

s.t. min_pre {m in M}: sum{i in I} x[i,'p',m]>= 0.15* sum{i in I}(capacity[i]);

s.t. min_pre_a {m in M}: x['alpha', 'p',m]>= 0.1*x['alpha', 'b',m];
s.t. min_pre_b {m in M}: x['beta', 'p',m]>= 0.1*x['beta', 'b',m];
s.t. min_pre_g {m in M}: x['gamma', 'p',m]>= 0.1*x['gamma', 'b',m];

# Economy in Alpha e Beta - attivazione booleana

s.t. eco_alpha: x['alpha','e', 'g']-Ma*v>=0;
s.t. eco_beta: x['beta', 'e', 'g']-Mb*v<=0;

# Biglietti in Business minimi
s.t. business_class {i in I}: x[i,'b','d']>=0.25*x[i,'e','d'];

# Sconto sui biglietti in Business per Dicembre

s.t. bool_k {i in I}: x[i,'b','d']<=0.30*capacity[i]*k[i]; 
 
# Posti in business a gennaio

s.t. bus_alpha_gen: x['alpha','b','g']>=0.7*(x['alpha','b','d']+x['alpha','p','d']);
s.t. bus_beta_gen: x['beta','b','g']>=0.7*(x['beta','b','d']+x['beta','p','d']);
s.t. bus_gamma_gen: x['gamma','b','g']>=0.7*(x['gamma','b','d']+x['gamma','p','d']);

# Alternativa = applico uno sconto solo

# Se c'e' lo sconto sulla classe Business per Dicembre, non applico lo sconto del 10% sui biglietti totali

#s.t. alt_sconto {i in I}: k[i]-C*v2<=0;
#s.t. alt_sconto2: z-C*(1-v2)<=0;
