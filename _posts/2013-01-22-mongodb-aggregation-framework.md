---
layout: post
title: MongoDb Aggregation Framework
author: [cexbrayat]
tags: [mongodb, aggregation, mapreduce, javascript]
canonical: http://hypedrivendev.wordpress.com/2013/01/22/mongodb-aggregation-framework
---
Vous avez probablement entendu parlé de [MongoDb](http://mongodb.org), une solution NoSQL orientée document développée par 10Gen. Les documents sont stockés en JSON, et bien que vous ayez un driver disponible pour chaque language, on se retrouve souvent à coder les requêtes en javascript dans le shell mongo fourni. Je vais vous parler de la version 2.2 qui est la dernière version stable et contient le framework d’aggregation, grande nouveauté attendue par les développeurs. Pour votre information, les numéros de version de Mongo suivent le vieux modèle du kernel Linux : les numéros pairs sont stables (2.2) alors que les versions de développement sont instables (2.1). Node.js suit le même modèle par exemple.

L’aggrégation donc, qu’est ce que c’est? Pour vous faire comprendre l’intérêt nous allons prendre un petit exemple (version simplifée d’un vrai projet). Admettons que vous stockiez les connexions à votre application toute les minutes, par exemple avec un document qui ressemblerait à 

    {"timestamp": 1358608980 , "connections": 150}

C’est à dire un timestamp qui correspond à la minute concernée et un nombre de connexions total.

Disons que vous vouliez récupérer les statistiques sur une plage de temps, par exemple sur une heure : il faudrait alors aggréger ces données pour obtenir le nombre total de connexion et le nombre moyen par minute. Seulement voilà, MongoDb ne propose pas de “group by”, de “sum” ou de “avg” comme l’on pourrait avoir en SQL. Ce genre d'opération est même déconseillé, car fait en javascript cela prend un plus de temps que dans une base classique. C’est en tout cas à éviter pour répondre à des requêtes en temps réel. Mais bon des fois, on est obligé...

### The old way : Map/Reduce
Jusqu’à la version 2.2 donc, on utilisait un algo [map/reduce](http://docs.mongodb.org/manual/applications/map-reduce/) pour arriver à nos fins. Si vous ne connaissez pas, je vous invite à lire [cet article](http://hypedrivendev.wordpress.com/2011/09/26/hadoop-part-1/) de votre serviteur expliquant le fonctionnement. Dans un algo map/reduce, Il faut écrire une fonction map et une fonction reduce, qui vont s’appliquer sur les données selectionnées par une requête (un sous ensemble de votre collection MongoDb). 

La requête qui permet de selectionner ce sous ensemble serait par exemple :

    // stats comprises entre 15:00 et 16:00
    var query = { timestamp : { $gte: 1358607600, $lte: 1358611200 }}

La fonction map va renvoyer les informations qui vous intéressent pour une clé. Ici nous voulons les connexions pour l’heure qui nous intéresse, donc nous aurons une fonction comme suit :

    // on renvoie les infos pour la clé 15:00
    var map = function(){ emit(1358607600, { connections : this.connections}) }

La fonction reduce va ensuite aggréger les informations, en ajoutant les connexions totales pour la clé 15:00 et calculer la moyenne associée. 

	// calculer la somme de toutes les connexions et la moyenne
    var reduce = function(key, values){ 
      var connections = Array.sum(values.connections);
      var avg = connections/values.length;
      return { connections: connections, avg: avg}
    }

Maintenant que nous avons nos fonctions map et reduce, ainsi que la requête pour remonter les données qui nous intéressent, on peut lancer le map reduce.

    // dans le shell mongo
    db.statistics.mapReduce(map, reduce, { query: query, out: { inline: 1 }})

Le out inline permet d'écrire la réponse dans le shell directement (sinon il faut préciser une collection qui acceuillera le résultat). On obtient une réponse du style :

    {connections: 180000, avg: 3000} 

en 4,5 secondes environ sur ma collection de plusieurs millions de document légèrement plus complexes que l’exemple.

### The new way : Aggregation Framework
Maintenant voyons la nouvelle façon de faire avec le [framework d’aggrégation](http://docs.mongodb.org/manual/applications/aggregation/). Une nouvelle opération apparaît : aggregate. Celle-ci remplace mapReduce et fonctionne comme le pipe sous Linux : de nouveaux opérateurs sont disponibles et on peut les enchaîner. Par exemple, le “group by” est simplifié avec un nouvel attribut $group. La requête qui permet de filtrer un sous ensemble de la collection est écrite avec un opérateur $match. Enfin de nouveaux opérateurs viennent nous simplifier la vie : $sum, $avg, $min, $max... J’imagine que vous avez saisi l’idée.

Ici on veut un élément match qui limite l’opération aux données de l’heure concernée, on peut réutiliser la même query que tout à l’heure. On groupe ensuite les documents avec une seule clé : celle de l’heure qui nous intéresse, puis l’on demande le calcul de deux valeurs, le nombre total de connexions (une somme) et la moyenne des connections (une moyenne donc).

    db.statistics.aggregate( 
      { $match: query}, 
      { $group: { _id: 1358607600, totalCompleted: {$sum: "$connections"}, totalAvg: {$avg: "$connections"} 
    }})

Le résultat est le suivant (en 4,2 secondes, soit un temps légérement inférieur au précédent) :

    { result: [{
      "_id": 1358607600,
      "totalCompleted": 180000,
      "totalAvg": 3000
    }], ok: 1}

L’avantage principal du framework d’aggrégation réside dans sa plus grande simplicité d’écriture et de lecture : plus besoin d’écrire des fonctions js soi-même pour des opérations somme toute assez courantes. [Spring Data Mongo](www.springsource.org/spring-data/mongodb) par exemple, le très bon projet de SpringSource pour vous simplifier la vie, demande d’écrire des fonctions en js pour faire du map/reduce. Vous avez donc un projet Java, qui contient quand même quelques fichiers js au milieu pour faire certaines opérations. Beaucoup attendent donc avec impatience l’arrivée du support du framework d’aggrégation dans Spring Data. Espérons qu’il ne tarde pas trop! En attendant d’autres frameworks comme [Jongo](http://jongo.org) l’ont déjà intégré. Il y a toutefois quelques limites comme le résultat de l'aggregate qui doit faire moins de 16Mo. Bref tout n'est pas idéal, mais ce très bon produit s'améliore à chaque version!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/01/22/mongodb-aggregation-framework "Article original sur le blog de Cédric Exbrayat")_
