---
layout: post
title: Commencer avec Vue 3
author: cexbrayat
tags: ["Vue"]
description: "Commençons une nouvelle application avec Vue 3 en partant de zéro."
---

> **Disclaimer**
> Cet article est un chapitre de notre livre [Deviens un Ninja avec Vue](https://books.ninja-squad.com/vue). Bonne lecture&nbsp;! Garde en tête que, contrairement à notre livre, cet article ne sera pas maintenu à jour avec de futurs changements de Vue.

Vue s'est toujours présenté comme un framework évolutif qui,
au contraire d'alternatives comme Angular ou React,
peut être adopté progressivement.
On peut parfaitement prendre une page HTML statique,
ou une application basée sur jQuery, et y ajouter
un peu de Vue.

Donc, pour commencer, j'aimerais montrer comme c'est simple
de mettre en place Vue dans une page HTML.

Créons une page HTML vide `index.html`&nbsp;:

    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
      </head>
      <body>
      </body>
    </html>


Ajoutons-y un peu de HTML que Vue devra gérer&nbsp;:

    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
      </body>
    </html>

Les accolades autour de `user` font partie de la syntaxe de Vue.
Elles indiquent que `user` doit être remplacé par sa valeur.
Nous expliquerons tout cela en détails dans le prochain chapitre,
pas d'inquiétude.

Si tu ouvres cette page dans ton navigateur, tu verras
qu'elle affiche {% raw %}`Hello {{ user }}`{% endraw %}.
C'est normal&nbsp;: nous n'avons pas encore utilisé Vue.

Faisons-le.
Vue est publié sur [NPM](https://www.npmjs.com/package/vue)
et il existe des sites (appelés _CDNs_, pour _Content Delivery Network_)
qui hébergent les packages NPM et permettent ainsi de les inclure dans nos pages HTML.
[Unpkg](https://unpkg.com/) est l'un d'entre eux,
et on peut donc l'utiliser pour ajouter Vue à notre page.
Bien sûr, tu pourrais aussi choisir de télécharger le fichier
et de l'héberger toi-même.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
      </body>
    </html>
{% endraw %}

NOTE: Cet exemple utilise la dernière version de Vue.
Tu peux spécifier n'importe quelle version explicitement en ajoutant
`@version` dans l'URL, après `https://unpkg.com/vue`.

Si tu recharges la page,
tu verras que Vue affiche un avertissement dans la console,
nous informant qu'on utilise une version dédiée au développement.
Tu peux utiliser `vue.global.prod.js` pour utiliser la version de production,
et faire disparaître l'avertissement.
La version de production désactive toutes les validations sur le code,
est minifiée, et est donc plus rapide et plus légère.

Il nous faut à présent créer notre application, avec la
fonction `createApp`. Mais cette fonction
a besoin d'un composant racine.

Pour créer ce composant, il nous suffit de créer un objet
qui le définit.
Cet objet peut avoir de nombreuses propriétés,
mais pour l'instant, nous allons seulement y ajouter
une fonction `setup`.
Pas de panique, nous reviendrons en détails sur la définition
d'un composant et sur cette fonction.
Mais son nom est assez explicite&nbsp;:
elle prépare le composant, et Vue appellera cette fonction
lorsque le composant sera initialisé.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
        </script>
      </body>
    </html>
{% endraw %}

La fonction `setup` ne fait que retourner un objet avec une propriété `user`
et une valeur pour cette propriété.
Si tu recharges la page, toujours pas de changement&nbsp;:
il nous reste toujours à appeler `createApp` avec notre composant racine.

NOTE: nous utilisons du JavaScript moderne dans cet exemple, et il
te faut donc utiliser un navigateur suffisamment récent, qui supporte cette syntaxe.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

`createApp` crée une application qui doit être "montée",
c’est-à-dire attachée à un élément du DOM.
Nous utilisons ici la `div` avec l'identifiant `app`.
Si tu recharges la page, tu devrais voir `Hello Cédric` s'afficher.
Bravo, tu viens de créer ta première application Vue.

Peut-être pourrions-nous ajouter un autre composant&nbsp;?

Créons un composant qui affiche le nombre de messages non lus.
Il nous faut donc un nouvel objet `UnreadMessagesComponent`,
avec une fonction `setup` similaire&nbsp;:

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const UnreadMessagesComponent = {
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

Cette fois, au contraire du composant racine dont la vue
est directement définie par la `div` `#app`, nous voudrions
définir un template pour le composant `UnreadMessagesComponent`.
Il suffit pour cela de définir un élément `script`
avec le type `text/x-template`.
Ce type garantit que le navigateur ignorera simplement le contenu du script.
On peut ensuite référencer le template par son identifiant dans la définition du composant.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
        <script type="text/x-template" id="unread-messages-template">
          <div>You have {{ unreadMessagesCount }} messages</div>
        </script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const UnreadMessagesComponent = {
            template: '#unread-messages-template',
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

On veut pouvoir insérer ce nouveau composant à l'intérieur du composant racine.
Pour pouvoir faire ça, nous devons autoriser le composant racine
à utiliser le composant _unread messages_, et lui assigner
un nom en _PascalCase_.

On peut ensuite utiliser `<unread-messages></unread-messages>`
(qui est la version _dash-case_ de `UnreadMessages`)
pour insérer le composant où on le veut.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
        <script type="text/x-template" id="unread-messages-template">
          <div>You have {{ unreadMessagesCount }} messages</div>
        </script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const UnreadMessagesComponent = {
            template: '#unread-messages-template',
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            components: {
              UnreadMessages: UnreadMessagesComponent
            },
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

We can now use the tag `<unread-messages></unread-messages>`
(which is the dash-case version of `UnreadMessages`) to insert the component where we want:

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
        <script type="text/x-template" id="unread-messages-template">
          <div>You have {{ unreadMessagesCount }} messages</div>
        </script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
          <unread-messages></unread-messages>
        </div>
        <script>
          const UnreadMessagesComponent = {
            template: '#unread-messages-template',
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            components: {
              UnreadMessages: UnreadMessagesComponent
            },
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

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
d'outils nous-mêmes. Mais profitons plutôt du travail
de la communauté et utilisons l'excellente Vue CLI.

Reviens la semaine prochaine pour apprendre comment,
ou paye le prix que tu veux pour notre ebook complet
[Deviens un Ninja avec Vue](https://books.ninja-squad.com/vue)&nbsp;!