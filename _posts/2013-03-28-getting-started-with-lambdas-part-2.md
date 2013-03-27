---
layout: post
title: Getting started with lambdas - Part 2
author: [cexbrayat]
tags: [java8, lambda]
---

Après une première partie dédiée à comprendre les interfaces fonctionnelles, nous allons entrer dans le vif du sujet avec cet article dont le but est de vous présenter les différentes façons d'écrire une lambda.

Supposons que nous ayons une interface `Concatenator` (histoire d'avoir un nom qui fait peur comme on sait faire en Java), qui prend un `entier` et un `double` pour les concaténer :

    interface Concatenator {
         String concat(int a, double b);                    
    }

La première façon d'écrire une lambda implémentant cette interface sous forme de lambda sera :

    (int a, double b) -> { 
         String s = a + " " + b; 
         return s;
    }

Voilà notre première lambda!
Cette syntaxe est le fruit de nombreux mois de réflexion, après débat entre 3 propositions principales. On retrouve nos paramètres entre parenthèses avec leur type, suivi d'une flèche et d'un bloc de code entre accolades. Le bloc de code représente le corps de la fonction, c'est l'implémentation concréte de la méthode concat de notre interface `Concatenator`. Ce corps de fonction est tout à fait classique avec un return en fin de bloc pour renvoyer le résultat.

Une autre façon, plus concise, d'écrire cette lambda est possible avec la syntaxe suivante :

     (int a, double b) -> return a + " " + b;

On note cette fois l'omision des accolades autour du bloc représentant la fonction. Cette syntaxe n'est bien sûr possible que si le corps de votre fonction tient sur une seule ligne, vous l'aurez compris!

Nous pouvons encore simplifier un peu l'écriture en utilisant un return implicite :

    (int a, double b) -> a + " " + b;

Le return a disparu! En effet, par défaut, la dernière valeur est retournée par la lambda : les syntaxes avec et sans return sont donc parfaitement équivalentes.

Nous pouvons également nous reposer sur l'inférence de type et laisser le compilateur (lorsque c'est possible) déterminer les types de nos paramètres :

    (a, b) -> a + " " + b;


Vous voyez qu'une lambda peut être une expression très concise!

Si notre interface fonctionnelle avait une méthode avec un seul paramètre, par exemple :

    interface UnaryOperator {
        int op(a);
    }	

Alors une lambda implémentant `UnaryOperator` pourrait être : 

    (a) -> a * a;

Mais la lambda pourrait même ici se passer des parenthèses autour des paramètres :

    a -> a * a;

En revanche, une interface avec une méthode ne possédant pas de paramètres comme `NumberSupplier :

    interface NumberSupplier { 
       int get();
    }

devra s'écrire :

    () -> 25;

Enfin, lorsque la lambda est un appel à une fonction de l'objet passé en paramètre, il est possible d'utiliser une syntaxe légérement différente. Ainsi, pour une interface fonctionnelle : 

    interface StringToIntFunction {                        
        int toInt(String s);
    }

qui transforme une chaîne de caractères en entier, on peut écrire une lambda comme suit :

    s -> s.length()

ou encore écrire :

    String::length

Ce `::` est un nouvel opérateur Java : il agit comme un appel à la méthode `length` de l'argument de la méthode `toInt`. Un peu surprenant au début, mais on s'habitue vite. Cet opérateur peut également s'appliquer à un constructeur. Notre méthode `toInt`pourrait donc également s'écrire :

    Integer::new

ce qui équivaut à 

    s -> new Integer(s)

L'opérateur peut aussi s'appliquer à une méthode statique, comme parseInt pour la classe Integer. La lambda :

    s -> Integer.parseInt(s)
   
est donc identique à :

    Integer::parseInt

Enfin, il est aussi possible de faire référence à une méthode d'un autre objet. Si nous supposons l'existence d'une HashMap `stringToIntMap` dans notre code, nous pouvons écrire une lambda comme suit :

    stringToIntMap::get

qui signifie la même chose que :

    s -> stringToIntMap.get(s)
 
Voilà, nous avons fait un inventaire exhaustif des façons d'écrire une lambda! La possibilité d'omettre les parenthèses, types, accolades et le mot clé return sont appréciables et donne une syntaxe très peu verbeuse. L'ajout de l'opérateur `::` introduit de nouvelles possibilités dans l'écriture comme vous avez pu le constater. Son utilisation demande un peu de pratique, mais cela viendra vite!

La prochaine fois nous regarderons une petite subtilité sur la portée des variables utilisables dans une lambda. Teasing teasing...