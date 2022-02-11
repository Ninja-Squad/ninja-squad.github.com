---
layout: post
title: Débuter avec Vite et Vue 3
author: cexbrayat
tags: ["Vue 3", "Vite", "Vitest"]
description: "Comment bien commencer avec Vite et Vue 3&nbsp;?"
---

> **Disclaimer**
> Cet article est un chapitre de notre ebook [Devenir un Ninja avec Vue](https://books.ninja-squad.com/vue). Bonne lecture&nbsp;!

En comparaison des autres frameworks,
une application Vue est extrêmement simple à mettre en œuvre&nbsp;:
juste du pur JavaScript et HTML.
Pas d'outillage nécessaire.
Les composants sont de simples objets.
Même un développeur qui ne connaît pas Vue
peut sans doute comprendre ce qui se passe.
Et c'est l'une des forces du framework&nbsp;:
c'est facile de démarrer, facile à comprendre,
et les fonctionnalités peuvent être apprises progressivement.

On _pourrait_ se contenter de cette approche minimale,
mais soyons réalistes&nbsp;: ça ne tiendra pas très longtemps.
Trop de composants vont devoir être définis dans le même fichier.
On voudrait aussi pouvoir utiliser TypeScript au lieu de JavaScript,
ajouter des tests, de l'analyse de code, etc.

Nous _pourrions_ installer et configurer toute une série
d'outils nous-mêmes. Mais profitons plutôt du travail de la communauté
et utilisons Vue CLI (qui a été le standard pendant de nombreuses années)
ou l'outil maintenant recommandé, Vite.

## Vue CLI

> **Note**
> La CLI est maintenant en mode "maintenance",
c'est-à-dire qu'elle ne reçoit plus de nouveautés.
L'outil recommandé est maintenant Vite,
que nous présentons dans la section suivante.
Comme beaucoup de projets existants utilisent la CLI,
nous pensons que cela vaut encore le coup de la présenter,
et cela aide à comprendre les différences avec Vite.

La Vue CLI (_Command Line Interface_)
est née pour simplifier le développement d'applications Vue.
Elle permet de créer le squelette de l'application, et ensuite
de la construire.
Et elle offre un vaste écosystème de plugins.
Chaque plugin ajoute une fonctionnalité spécifique,
comme le support pour les tests unitaires,
ou le linting, ou le support de TypeScript.
La CLI a même une interface graphique&nbsp;!

L'une des caractéristiques de Vue CLI est de permettre
d'écrire chaque composant dans un fichier unique avec l'extension
`.vue`.
Dans ce fichier, toutes les parties d'un composant
sont définies&nbsp;: sa définition en JavaScript/TypeScript,
son template HTML, et même ses styles CSS.
Un tel fichier est appelé _Single File Component_, ou SFC.

Mais l'intérêt principal de la CLI est
d'éviter d'avoir à apprendre et à configurer
tous les outils qu'elle utilise
(Node.js, NPM, Webpack, TypeScript, etc.),
tout en restant flexible et configurable.

Mais la CLI est maintenant en mode maintenance,
et Vite est l'alternative recommandée.
Explorons donc pourquoi.

## Bundlers&nbsp;: Webpack, Rollup, esbuild

Quand on écrit des applications modernes en JavaScript/TypeScript,
on a souvent besoin d'un outil qui _bundle_ (rassemble) tous les assets
(le code, les styles, les images, les polices de caractères).

Pendant longtemps, [Webpack](https://webpack.js.org/)
a été le favori indiscutable.
Webpack vient avec une fonctionnalité simple mais très pratique&nbsp;:
il comprend tous les types de module JavaScript qui existent
(les modules ECMAScript modernes, mais aussi les modules AMD et CommonJS,
des formats qui existaient avant le standard).
Cette compréhension rend facile d'utilisation n'importe quelle bibliothèque
que tu trouves sur Internet (le plus souvent sur NPM)&nbsp;:
il y a juste besoin de l'installer,
de l'importer dans un de tes fichiers,
et Webpack s'occupe du reste.
Même si tu utilises des bibliothèques avec des formats très différents,
Webpack va joyeusement les convertir et packager tout ton code
et le code de ces bibliothèques ensemble dans un seul gros fichier JS&nbsp;:
le fameux _bundle_.

C'est une tâche très importante,
parce que même si le standard a défini les modules ECMAScript en 2015,
la plupart des navigateurs ne les supportent que depuis peu&nbsp;!

L'autre tâche de Webpack est aussi de t'aider pendant le développement,
en fournissant un serveur de développement et en surveillant ton projet
(il peut même faire du HMR, _Hot Module Reloading_,
c'est-à-dire du rechargement de module à chaud).
Quand quelque chose change,
Webpack lit le point d'entrée de l'application (`main.ts` par exemple),
puis il lit les imports et charge ces fichiers,
puis il lit les imports de ces fichiers importés et les charge,
et ainsi de suite récursivement.
Tu vois l'idée&nbsp;!
Quand tout est chargé,
il remet tout cela dans un grand fichier,
contenant à la fois ton code et les bibliothèques importées
depuis `node_modules`,
en changeant le format des modules si besoin.
Le navigateur recharge alors tout ce fichier pour afficher les changements 😅.
Toute cette boucle peut prendre un certain temps quand on travaille sur des gros projets
avec des centaines, voire des milliers de fichiers,
même si Webpack vient avec un système de caches et d'optimisations pour être le plus rapide possible.

La CLI Vue (comme beaucoup d'autres outils) utilise Webpack
pour la majeure partie de son travail,
aussi bien quand on construit l'application avec `npm run build`,
que quand on lance le serveur de développement avec `npm run serve`.

Ce qui est chouette, c'est que l'écosystème Webpack
est extraordinairement riche en _plugins_ et _loaders_&nbsp;:
tu peux donc faire pratiquement ce que tu veux,
même les trucs les plus improbables.
D'un autre côté, une configuration Webpack
peut rapidement devenir assez difficile à comprendre avec toutes ces options.

Si je parle de Webpack et ce que font les bundlers,
c'est parce que de sérieuses alternatives ont émergé ces derniers temps,
et il peut être assez difficile de saisir ce qu'elles font
et quelles sont leurs différences.
Pour être honnête, je ne suis pas sûr de comprendre tous les détails moi-même,
et j'ai pourtant pas mal contribué aux CLIs Vue et Angular,
toutes deux utilisant massivement Webpack&nbsp;!
Mais je tente quand même une explication.

Une alternative sérieuse est [Rollup](https://www.rollupjs.org/guide/en/).
Rollup entend faire les choses de façon plus simple que Webpack,
en en faisant moins par défaut,
mais souvent plus vite que Webpack.
Son auteur est Rich Harris, qui est aussi l'auteur du framework Svelte.
Rich a écrit un article assez populaire appelé
["Webpack et Rollup&nbsp;: les mêmes mais différents"](https://medium.com/webpack/webpack-and-rollup-the-same-but-different-a41ad427058c).
Sa conclusion est "Utilise Webpack pour les applications, et Rollup pour les bibliothèques".
En fait, Rollup peut faire quasiment tout ce que fait Webpack
pour les builds de production,
mais il ne vient pas avec un serveur de développement
qui pourrait surveiller tes fichiers pendant que tu travailles.

Une autre super alternative est [esbuild](https://esbuild.github.io/).
À la différence de Webpack et Rollup,
esbuild n'est pas lui-même écrit en JavaScript.
Il est écrit en Go et compilé en code natif.
Il a aussi été conçu avec le parallélisme en tête.
Cela le rend bien plus rapide que Webpack et Rollup.
Genre 10 à 100 fois plus rapide 🤯.

Pourquoi ne pas utiliser esbuild plutôt que Webpack alors&nbsp;?
C'est exactement ce qu'Evan You, l'auteur de Vue,
a pensé quand il développait Vue&nbsp;3.
Il a eu une autre brillante idée.
En 2018, Firefox a officiellement supporté les Modules ECMAScript natifs (souvent appelés "ESM natifs").
En 2019, ce fut au tour de NodeJS, et des autres navigateurs principaux.
De nos jours, ton navigateur personnel peut probablement comprendre les ESM natifs sans problème.
Evan a imaginé un outil qui servirait les fichiers au navigateur au format ESM,
laissant le gros du travail à esbuild quand il faut transformer les fichiers sources en fichier ESM si besoin
(par exemple pour les fichiers TypeScript ou Vue, ou pour des modules dans un format plus ancien).

[Vite](https://vitejs.dev) (encore un mot français) était né.

## Vite

L'idée derrière Vite est que, comme les navigateurs modernes supportent les modules ES,
on peut maintenant les utiliser directement, au moins pendant le développement, plutôt que de générer un bundle.

Donc lorsque tu charges une page dans un navigateur quand tu développes avec Vite,
tu ne charges pas un seul gros fichier JS contenant toute l'application&nbsp;:
tu charges juste les quelques ESM nécessaires pour cette page, chacun dans leur propre fichier
(et chacun dans leur propre requête HTTP).
Si un ESM a des imports, alors le navigateur demande à Vite ces fichiers également.

Vite est donc principalement un serveur de développement,
chargé de répondre aux requêtes du navigateur,
en lui envoyant les ESM demandés.
Comme on a peut-être écrit notre code en TypeScript,
ou utilisé un SFC avec une extension `.vue` (voir plus loin),
Vite doit parfois transformer ces fichiers sur notre disque en un ESM
que le navigateur peut comprendre.
C'est ici qu'esbuild intervient.
Vite est bâti au-dessus d'esbuild
et quand un fichier demandé a besoin d'être transformé,
Vite demande à celui-ci de s'en occuper et envoie ensuite le résultat au navigateur.
Si tu changes quelque chose dans un fichier
alors Vite n'envoie que le module qui a changé au navigateur,
au lieu d'avoir à reconstruire toute l'application
comme le font les outils basés sur Webpack&nbsp;!

Vite utilise aussi esbuild pour optimiser certaines choses.
Par exemple si tu utilises une bibliothèque avec des tonnes de fichiers,
Vite "pré-bundle" cette bibliothèque en un seul fichier grâce à esbuild
et l'envoie au navigateur en une seule requête plutôt que quelques dizaines/centaines.
Cette tâche est faite une seule fois au démarrage du serveur,
tu n'as donc pas à payer le coût à chaque fois que tu rafraîchis la page.

Le truc marrant est que Vite n'est pas vraiment lié à Vue&nbsp;:
il peut être utilisé avec Svelte, React ou autre.
En fait, certains frameworks recommandent même son utilisation&nbsp;!
Svelte, de Rich Harris, a été l'un des premiers à sauter le pas
et recommande maintenant officiellement Vite.

esbuild est très fort pour la partie JS,
mais il n'est pas (encore) capable de découper l'application en plusieurs morceaux,
ou de gérer entièrement les CSS (alors que Webpack et Rollup le font par défaut).
Il n'est donc pas adapté pour packager l'application pour la prod.
C'est là que Rollup entre en jeu&nbsp;:
Vite utilise esbuild pendant le développement,
mais utilise Rollup pour le build de prod.
Peut-être que dans le futur, Vite utilisera esbuild pour tout.

Vite est cependant plus qu'une simple enveloppe autour d'esbuild.
Comme on l'a vu, esbuild transforme les fichiers très vite.
Mais Vite ne lui demande cependant pas de faire ce travail à chaque fois qu'une page est rechargée&nbsp;:
il utilise le cache du navigateur pour effectuer le moins de travail possible.
Ainsi si tu affiches une page que tu as déjà chargé,
elle sera affichée instantanément.
Vite vient aussi avec [plein d'autres fonctionnalités](https://vitejs.dev/guide/features.html)
et un riche ensemble de plugins.

Une note importante&nbsp;: esbuild transpile TypeScript en JavaScript,
mais il ne le compile pas&nbsp;: esbuild ignore complètement les types&nbsp;!
Ça le rend hyper rapide, mais cela veut donc dire
que tu n'auras pas de vérification des types de la part de Vite pendant le développement.
Pour vérifier que ton application compile,
tu devras exécuter [Volar](https://github.com/johnsoncodehk/volar) (`vue-tsc`),
généralement quand tu construis l'application.

Alors tu as envie d'essayer&nbsp;? Parce que moi oui&nbsp;!

Vite propose des exemples de projets pour React, Svelte et Vue,
mais l'équipe Vue a également lancé un petit projet basé sur Vite appelé `create-vue`.
Et ce projet est maintenant la façon recommandée de démarrer un nouveau projet Vue&nbsp;3.

## create-vue

create-vue est donc bâti au-dessus de Vite
et fournit des squelettes de projets Vue&nbsp;3.

Pour démarrer, tu lances simplement&nbsp;:

    npm init vue@3

La [command `npm init quelquechose`](https://docs.npmjs.com/cli/v6/commands/npm-init)
télécharge et exécute en fait le package `create-quelquechose`.
Donc ici `npm init vue` exécute le package `create-vue`.

Tu peux alors choisir&nbsp;:

- un nom de projet
- si tu veux TypeScript ou non
- si tu veux JSX ou non
- si tu veux Vue router ou non
- si tu veux Pinia (gestion de l'état) ou non
- si tu veux Vitest pour les tests unitaires ou non
- si tu veux Cypress pour les tests e2e ou non
- si tu veux ESLint/Prettier pour le lint et le formatage ou non

et ton projet est prêt&nbsp;!

Nous allons bien sûr explorer ces différentes technologies tout au long du livre.

Tu veux t'y mettre&nbsp;?

Pour créer ta première application avec Vite,
suis les instructions de l'exercice [Getting Started](https://vue-exercises.ninja-squad.com/exercises/0/getting-started).
Il fait partie de notre Pack Pro, mais est accessible pour tout le monde.
Tu seras guidé pour créer ta première application,
et on donne quelques astuces que l'on trouve utiles pour ajuster la configuration par défaut

Terminé&nbsp;?

Si tu as bien suivi les instructions (et obtenu un score de 100&nbsp;% j'espère&nbsp;!),
tu as maintenant une application en place, qui fonctionne.

Notre setup préféré inclut&nbsp;:

- TypeScript pour le typage qu'il apporte, aussi bien dans le code que dans les templates grâce à vue-tsc
- [Vitest](https://vitest.dev/) pour les tests unitaires. Vitest est très similaire à Jest mais utilise Vite pour charger les fichiers à tester, ce qui le rend bien plus simple à utiliser que Jest, puisque l'on a pas à configuré ts-jest, vue-jest, etc.
- [Cypress](https://www.cypress.io/) pour les tests e2e
- [ESLint](https://eslint.org/) avec [Prettier](https://prettier.io/) pour l'analyse de code et le formatage

Avec tout ça, tu es prêt à te lancer avec Vue 3&nbsp;!


Notre [ebook](https://books.ninja-squad.com/vue), [cours en ligne](https://vue-exercises.ninja-squad.com/) et [formation](https://ninja-squad.com/training/vue) expliquent tous ces sujets dans le détails si tu veux en apprendre plus&nbsp;!
