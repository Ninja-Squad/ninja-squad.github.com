---
layout: post
title: Ninja Tips 2 - Type ton JSON avec TypeScript
author: jbnizet
tags: ["Angular 2", "Angular", "typescript", "json", "tips"]
description: "Rend ton code plus sûr et plus maintenable en typant ton JSON avec TypeScript"
---

Ce *tip* concerne plutôt TypeScript qu'Angular.
Mais comme c'est Angular qui, comme beaucoup d'entre vous sans doute,
nous a amené à utiliser TypeScript, on va l'expliquer avec un exemple
basé sur Angular, et le comparer avec du code JavaScript d'un exemple
similaire avec AngularJS.

## Un service type ramenant des données du backend

Un service AngularJS typique qui retourne des données
en provenance du backend, en utilisant le service $http
et les [promesses](/2015/05/28/angularjs-promises/) ressemble à ça&nbsp;:

    myModule.service('raceService', function($http) {
        this.getRaceById = function(id) {
            return $http.get('/api/races/' + id)
                        .then(function(response) {
                return response.data;
            });
        };
    });

C'est assez simple, et l'utiliser dans un controller ne pose pas de problème...
à condition de savoir à quoi le message JSON ressemble.

Qu'est-ce qu'une *race*? Quels champs contient-elle? C'est facile de se le
rappeler dans une petite application, alors qu'on vient d'écrire le service
côté serveur. Mais dans une grosse application bien complexe, manipulant
des objets métiers plus obscurs qu'une course de poneys, ce n'est pas toujours évident
de savoir ce que le message contient. Et la lecture du code JavaScript n'est pas
d'un grand secours.

## Le même service avec Angular et TypeScript

En Angular, avec TypeScript, le même service ressemblerait à ça (on vous passe les
imports)&nbsp;:

    @Injectable()
    export class RaceService {
        constructor(private _http:Http) {
        }

        getRaceById(id): Observable<any> {
            return this._http.get(`/api/races/${id}`)
                             .map(response => response.json());
        }
    }

Est-ce franchement mieux que la version AngularJS&nbsp;?

A part le sucre syntaxique (classe, *arrow function*, interpolation de chaîne de caractères),
pas vraiment. On sait que le service retourne un *Observable*, mais on ne sait toujours
pas à quoi une course ressemble.

## TypeScript à la rescousse

L'objet retourné par `response.json()` n'est pas une instance d'une quelconque
classe que vous auriez pu définir. C'est juste un objet JavaScript basique, avec
quelques propriétés.

Pour les développeur plus habitués aux langages fortement typés comme Java,
un objet qui n'a pas de type... n'a pas de type. Et on ne peut pas faire comme s'il en avait un.

Mais TypeScript, bien qu'ayant des concepts similaires à ceux de Java, est très
différent de Java. TypeScript permet entre autres de définir des interfaces qui,
au contraire des interfaces Java, peuvent contenir des attributs.
Par exemple&nbsp;:

    export interface Race {
        id: number,
        name: string,
        ponies: Array<Pony>,
        startInstant: string,
        status: RaceStatus
    }

Les interfaces, un peu comme les types génériques de Java, sont un concept qui n'existe
que pour le compilateur. L'interface n'existe plus à l'exécution. Mais pour le compilateur
TypeScript, elle permet de définir *la forme* d'un objet. Et on peut donc définir son
service comme ceci&nbsp;:

    @Injectable()
    export class RaceService {
        constructor(private _http:Http) {
        }

        getRaceById(id): Observable<Race> {
            return this._http.get(`/api/races/${id}`)
                             .map(response => response.json());
        }
    }

La différence est subtile, mais importante. Au lieu de retourner un `Observable<any>`,
le service retourne à présent un `Observable<Race>`.

## Et si...

OK, mais que se passe-t-il si le JSON renvoyé par le serveur n'a pas d'attribut `startInstant`
mais a en réalité un attribut `startTime`&nbsp;?

TypeScript ne peut pas détecter ce problème. A l'exécution, `startInstant`
sera *undefined*.

Mais au moins, une fois que cette erreur aura été détectée,
tu pourras utiliser ton IDE préféré pour refactoriser `startInstant` en `startTime`,
et corriger d'un seul coup tout le code TypeScript utilisant l'attribut incorrect.

Plus important encore, quand tu devras (toi ou un collègue) modifier un composant de
l'application qui manipule une course, tu n'auras qu'à examiner l'interface `Race`
pour savoir immédiatement à quoi ressemble un objet de ce type. Et tu pourras compter sur
ton IDE pour te fournir de l'auto-complétion.

Voici donc mon *ninja tip*&nbsp;: definis des interfaces représentant les objets retournés
par le backend. Bonus&nbsp;: documente leurs attributs&nbsp;!
