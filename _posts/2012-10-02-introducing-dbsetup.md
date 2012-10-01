---
layout: post
title: Let me introduce (drumroll...) DbSetup
author: jbnizet
tags: [java, open-source, dbsetup, testing]
---
## Le constat

Tous les projets auxquels j'ai participé jusqu'ici utilisent une base de données. 

L'immense majorité d'entre eux utilisent une base de données relationnelle. Et qui dit base de données
dit requêtes. Cela peut être des requêtes SQL, HQL, JPQL, Criteria ou quoi que ce soit d'autre, mais dans 
tous les cas, il s'agit de tester ces requêtes de manière automatisée. Le moindre changement 
de schéma peut les rendre incorrectes, sans que le compilateur vous prévienne.

L'outil de prédilection pour ces tests est [DbUnit](http://dbunit.sourceforge.net/). 
C'est gratuit, open-source, éprouvé. Je l'ai utilisé, plusieurs fois, et ça marche. DbUnit fait plein de 
choses, comme comparer des DataSets entre eux par exemple. Pourtant, si je m'interroge et que j'interroge 
des collègues, je constate que son utilisation est toujours la même&nbsp;: on peuple la base de données 
avant chaque test, on exécute le test, puis on vide la base de données pour le test suivant. Tout le reste 
de ce que propose DbUnit n'est pas utilisé.

Les données de test sont écrites dans un ou plusieurs fichiers XML. Et souvent, on se bat pour maintenir 
ces fichiers, faire en sorte que les données soient insérées et supprimées dans le bon ordre, etc.

## Le problème

A mon sens, DbUnit a deux défauts principaux:

 - Le XML: impossible de factoriser quoi que ce soit, de faire des boucles, de définir ou utiliser des 
   constantes, d'utiliser des types natifs.
 - La vitesse: maintenir des jeux de données très petits, adaptés chacun à une classe de test, est l'idéal
   pour assurer l'indépendance des tests. Mais c'est fastidieux, et ça implique énormément de copier-coller.
   Et quelle que soit la taille des jeux de données, DbUnit les réinsère dans la base avant chaque test. Dans 
   mon expérience, 95% des méthodes testées ne font que lire dans la base (on teste une requête), et pourtant,
   DbUnit passe *notre* temps à vider la base et à la repeupler avec les mêmes données.
   
## DbSetup to the rescue

Alors voilà, l'idée est née: [DbSetup](http://dbsetup.ninja-squad.com). Toute l'équipe de Ninja Squad est très 
attachée à l'open-source. On a tous envie de créer nos projets, et de les rendre open-source si possible. 
Alors on commence à le faire.

DbSetup est un projet très modeste, mais on y a mis du soin, et on espère que ça va rendre service à d'autres 
qu'à nous. 

L'idée: une API Java simple, peu verbeuse, qui permette de définir ses jeux de données en Java, de vider et 
de peupler la base avant chaque test, **sauf si ce n'est pas nécessaire**. 

On a pris du temps pour tâcher de [documenter l'API](http://dbsetup.ninja-squad.com/apidoc.html) au mieux, 
de fournir un [guide utilisateur](http://dbsetup.ninja-squad.com/user-guide.html) lisible (en anglais), 
et d'expliquer pourquoi DbSetup est la plus grande invention depuis le fil à couper le beurre et donc [pourquoi 
il faut l'utiliser](http://dbsetup.ninja-squad.com/approach.html).
Je ne vais donc pas répéter ici tout ce qui est écrit dans la documentation. Juste un aperçu de la définition 
d'un jeu de données très simple&nbsp;:

    Operation operation =
        Operations.sequenceOf(
            CommonOperations.DELETE_ALL,
            CommonOperations.INSERT_REFERENCE_DATA,
            Operations.insertInto("CLIENT")
                      .columns("CLIENT_ID", "FIRST_NAME", "LAST_NAME", "DATE_OF_BIRTH", "COUNTRY_ID")
                      .values(1L, "John", "Doe", "1975-07-19", Countries.USA)
                      .values(2L, "Martin", "Circus", "1969-08-22", Countries.FRANCE)
                      .withDefaultValue("VERSION", 1L)
                      .build());
                      
Tester DbSetup n'est pas facile&nbsp;: chaque base de données a ses petites particularités, ses
types de données, etc. On n'a sans doute pas pensé à tout. Mais on pense que cette version est stable est 
utilisable en l'état. 

On a donc fait une version 1.0-RC1 (Release Candidate 1), disponible 
[en téléchargement](http://dbsetup.ninja-squad.com/download.html),
et dans le repo [Maven Central](http://search.maven.org/#search|ga|1|a%3A%22DbSetup%22), sous 
[licence MIT](http://dbsetup.ninja-squad.com/license.html).
(On fera sans doute un post pour détailler notre expérience).

Testez-là avec votre base de données, dans votre projet. Critiquez là, soumettez-nous des bugs sur 
[JIRA](https://ninjasquad.atlassian.net/) (merci à [Atlassian](http://www.atlassian.com) de nous héberger 
gratuitement&nbsp;!). Proposez-nous des améliorations en forkant le projet sur 
[github](https://github.com/Ninja-Squad/DbSetup).

Enjoy&nbsp;!