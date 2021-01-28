DIRECTORIES

- scenes:
	Contiene le immagini di input per le scene

- scenes_gt:
	Contiene le groundtruths utilizzate per testare il classificatore bayesiano (relative alle immagini P04, P06 e P07)
- schemes:
	Contiene le immagini di input per gli schemi

- shapes_gt:
	Contiene le forme utilizzate come groundtruths per valutare il classificatore knn

- training:
	Contiene le immagini utilizzate per il training

- training_shapes
	Contiene le forme ESTRATTE DALLE IMMAGINI FORNITE R01 e R02 utilizzate per il training del classificatore knn

FILES ROOT

- training.m
	Effettua il training di entrambi i classificatori (bayesiano e knn). Deve essere eseguito prima di main.m se non sono ancora stati generati i file classifier_bayes.mat e classifier_knn.mat

- training_segmentation.m
	Procedura di supporto utilizzato per binarizzare le immagini di training, allo scopo di ricavare le labels

- test.m
	Utilizzato per effettuare la fase di test di entrambi i classificatori

- main.m
	File principale del progetto, inserire nelle variabili scheme_name e scene_name i nomi dei file relativi alle immagini rispettivamente di schema e scena da utilizzare. Al termine dell'esecuzione viene visualizzata l'immagine prodotta

- confmat.m (file fornito dal professor Ciocca)
	Calcola la matrice di confusione e il valore di accuracy

- get_corners.m
	Utilizzato per calcolare il numero di angoli delle forme

- load_shapes.m
	Carica le immagini da una directory, e ritorna i descrittori calcolati su di esse e le labels associate (ricavate dal nome dei file delle immagini)

- adjust_piece.m
	Esegue le trasformazioni geometriche di rotazione e scaling sul tetramino di scena, rispetto allo schema

- remove_border.m
	Rimuove eventuali bordi neri di padding intorno ad una forma, riducendola alla minima bounding box

- color_region.m
	Applica una maschera binaria ad un'immagine a colori

- classifier_bayes.mat e classifier_knn.mat vengono generati dal file training.m 