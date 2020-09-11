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
var v2 binary;   # attivazione di un solo sconto

# Parametri del modello

param price{J};	   # costo biglietto per classe
param capacity{I} integer; # capacita' di ciascun aereo
param riempimento{I} integer; # capacita' minima di riempimento di ciascun aereo
param gasoline{J}; # carburante per ciascuna classe
param hostess{J};  # costo personale di bordo/terra
param food{J};	   # costo cibo
param iva{J};      # iva per biglietto venduto 
param occ_premium{J,I}; # occupazione posti in premium rispetto i posti business
param min_premium{I}; # occupazione minima posti in premium 

# Costanti del modello

param tax integer;  # tasse aeroportuali 
param business_gen; # posti in business a gennaio
param business_dic; # sconto posti in business a dicembre
param min_business; # posti minimi in business
param sconto_bus;   # sconto business

param Ma integer;  # soglia della classe economy per l'aereo alpha     
param Mb integer;  # soglia della classe economy per l'aereo beta
param C integer;   # soglia per sconto IVA
    
# Funzione obiettivo 

maximize obj: sum{i in I, j in J, m in M}price[j]*(x[i, j, m]) 
- sum{i in I, j in J, m in M}(price[j]-iva[j])*(gasoline[j]+hostess[j]+food[j])*(x[i,j,m]) 
- sum{i in I, j in J, m in M}iva[j]*(x[i,j,m]) - tax* sum{i in I, j in J, m in M}(x[i,j,m])
+ 143*z - sconto_bus*sum{i in I}k[i];

# Vincoli

# Capacita' di ciascun aereo

s.t. capacity_alpha {i in I, m in M}: sum{j in J} x[i, j, m]<=(capacity[i]);

# Sconto sui biglietti venduti

s.t. sconto_dieci: sum{i in I, j in J, m in M}x[i, j, m]>=C*z;

# Quantita' minima di riempimento

s.t. min_alpha {i in I, m in M}: sum{j in J} x[i, j, m]>=riempimento[i];

# Posti in Economy

s.t. economy_tickets {m in M}: sum{i in I}x[i,'e', m]>= sum{i in I}(x[i, 'p', m]+x[i, 'b', m]);

s.t. economy {i in I,m in M}: x[i, 'e', m]>= x[i,'p', m]+x[i,'b', m];

# Posti in Premium

s.t. min_pre {m in M}: sum{i in I} x[i,'p',m]>= sum{i in I}(min_premium[i]*capacity[i]);

s.t. min_pre_a {i in I, j in J, m in M}: x[i, 'p',m]>=occ_premium[j,i]*x[i, 'b',m];

# Economy in Alpha e Beta - attivazione booleana

s.t. eco_alpha: x['alpha','e', 'g']-Ma*v>=0;
s.t. eco_beta: x['beta', 'e', 'g']-Mb*v<=0;

# Biglietti in Business minimi
s.t. business_class {i in I}: x[i,'b','d']>= min_business * x[i,'e','d'];

# Sconto sui biglietti in Business per Dicembre

s.t. bool_k {i in I}: x[i,'b','d']<= business_dic*capacity[i]*k[i]; 
 
# Posti in business a gennaio

s.t. bus_alpha {i in I}: x[i,'b','g']>= business_gen *(x[i,'b','d']+x[i,'p','d']);

# Alternativa = applico uno sconto solo // Scenario indicato alla sezione 4.3

# Se c'e' lo sconto sulla classe Business per Dicembre, non applico lo sconto del 10% sui biglietti totali

#s.t. alt_sconto {i in I}: k[i]-v2<=0;
#s.t. alt_sconto2: z-(1-v2)<=0;
