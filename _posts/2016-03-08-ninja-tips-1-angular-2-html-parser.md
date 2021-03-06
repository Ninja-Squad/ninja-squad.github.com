---
layout: post
title: Ninja Tips 1 - Angular et son parser HTML
author: acrepet
tags: ["Angular 2", "Angular", "template", "html", "tips"]
description: "Trucs et astuces concernant le moteur de parsing propre à Angular"
---

# Ninja Tips #1
Les ninjas se lancent dans l'écriture de *Ninja Tips*&nbsp;! On a envie de vous faire partager les trucs et astuces que l'on découvre et qui nous plaisent. On se dit aussi que cela pourrait être sympa que l'on vous explique des petits (ou gros) problèmes que l'on a pu rencontrer au quotidien dans nos projets, en vous donnant quelques pistes de solutions... Nous nous lançons donc dans des petits posts courts mais réguliers&nbsp;! Les sujets viendront au fur et à mesure des semaines, en fonction des problèmes que l'on rencontre, de nos lectures ou des derniers sujets auxquels [JB a répondu](http://stackoverflow.com/users/571407/jb-nizet?tab=answers) sur StackOverflow.

# Bien écrire ses templates

Avec Angular, les templates doivent être strictement valides au niveau HTML. Donc si vous écrivez mal votre HTML, vous allez avoir des erreurs.

En travaillant sur les exercices de notre futur [Pack Pro](https://books.ninja-squad.com/angular) et de notre [formation Angular](https://ninja-squad.fr/formations/formation-angular), on a rencontré quelques problèmes. D'abord, en se trompant dans l'écriture d'un tag `<img>`, en écrivant&nbsp;:

    <div>
      <img [src]="..."></img>
    </div>

On a eu un beau message d'erreur dans la console, alors que les navigateurs sont normalement assez (trop) permissifs sur la validité du code HTML&nbsp;:

    EXCEPTION: Template parse errors:
    Void elements do not have end tags "img" ("<div>
    <img [src]="getPonyImageUrl(pony)">[ERROR ->]</img>
    </div>"): Pony@1:39 BrowserDomAdapter.logError @ angular2.dev.js:23083

Vous remarquez que le message est assez précis&nbsp;: on nous indique les numéros de ligne et de colonne où le problème apparaît dans le template, ce qui est plutôt cool.

Autre problème, nous avons voulu utiliser l'entité HTML `&times;` et là encore, un message d'erreur inconnu (et cette fois injustifié). La raison&nbsp;: Angular utilise à présent son propre parser HTML, et il avait encore quelques bugs&nbsp;!
A noter, depuis notre expérience malheureuse avec [ce bug](https://github.com/angular/angular/issues/5546), le problème a été partiellement corrigé (dans la version alpha-48 récente)&nbsp;: les entités les plus fréquemment utilisées comme `&times;` sont maintenant acceptées (`&copy;`, `&quot;`, `&amp;`, etc.).


# Un nouveau moteur de parsing HTML

La [raison principale](http://angularjs.blogspot.fr/2016/02/angular-2-templates-will-it-parse.html), énoncée officiellement par la team Angular, pour embarquer ce nouveau moteur de parsing est l'élimination de la convention de mapping qu'il y avait en Angular&nbsp;1 entre les attributs de template (en *dash-case*) et les attributs de vos directives (attendus en *camelCase*).

Pour celles et ceux qui se sont un peu amusés avec Angular&nbsp;1, vous vous êtes sûrement faits avoir au moins une fois sur un problème entre le nom que vous donniez à un attribut de votre template, donc respectant la convention *dash-case*, par exemple&nbsp;:

    <div ninja-poney>This awesome poney</div>

et le nom attendu par le framework sur votre attribut JavaScript de la directive, en *camelCase*&nbsp;:

    app.directive('ninjaPoney', function() {
      return {
        template: '<h1>Poney</h1>'
      };
    });


Nous aurions préféré pouvoir écrire le template comme suit&nbsp;:

    <div ninjaPoney>This awesome poney</div>


Dorénavant en Angular&nbsp;2+, c'est possible&nbsp;: les noms des attributs seront case-sensitive. Puisque HTML est case-insensitive, la solution pour la team Angular a donc été de développer leur propre moteur de parsing HTML.

# D'autres avantages&nbsp;?

Un autre avantage au fait d'avoir un moteur de parsing HTML propre dans Angular c'est que, quel que soit votre navigateur, le template est parsé de la même manière. Avec Angular, vous aurez la garantie que vos templates seront réellement valides au niveau HTML, avant le déploiement et ce pour tous les navigateurs&nbsp;!
Cela ouvre également des portes pour le rendering côté serveur, mais on y reviendra.

À très bientôt pour de nouveaux Ninja Tips&nbsp;!
