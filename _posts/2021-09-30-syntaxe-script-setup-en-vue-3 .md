---
layout: post
title: Comment utiliser la syntaxe `script setup` en Vue 3
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.2 a ajouté la syntaxe `script setup` pour définir un composant. Voyons comment l'utiliser&nbsp;!"
---

Vue&nbsp;3.2 a introduit la syntaxe `script setup`,
une façon un peu moins verbeuse de déclarer les composants.
On l'active en ajoutant l'attribut `setup` à la balise `script` d'un SFC,
et on peut alors enlever un peu de boilerplate du composant.

Prenons un exemple pratique, et migrons-le vers cette syntaxe !

## Migrer un composant

Le composant `Pony` ci-dessous a deux props (le `ponyModel` à afficher, et une option `isRunning`).
Basée sur ces deux props, une URL est calculée pour l'image du poney affichée dans le template
(via un autre composant `Image`).
Le composant émet également un événement `selected` quand on clique dessus.

Pony.vue
{% raw %}
    <template>
      <figure @click="clicked()">
        <Image :src="ponyImageUrl" :alt="ponyModel.name" />
        <figcaption>{{ ponyModel.name }}</figcaption>
      </figure>
    </template>
    <script lang="ts">
    import { computed, defineComponent, PropType } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    export default defineComponent({
      components: { Image },

      props: {
        ponyModel: {
          type: Object as PropType<PonyModel>,
          required: true
        },
        isRunning: {
          type: Boolean,
          default: false
        }
      },

      emits: {
        selected: () => true
      },

      setup(props, { emit }) {
        const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

        function clicked() {
          emit('selected');
        }

        return { ponyImageUrl, clicked };
      }
    });
    </script>
{% endraw %}

Première étape&nbsp;: ajoutons l'attribut `setup` à l'élément `script`.
On peut alors garder seulement le contenu de la fonction `setup`,
et supprimer l'appel à `defineComponent` et `setup`&nbsp;:

Pony.vue
{% raw %}
    <script setup lang="ts">
    import { computed, PropType } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    components: { Image },

    props: {
      ponyModel: {
        type: Object as PropType<PonyModel>,
        required: true
      },
      isRunning: {
        type: Boolean,
        default: false
      }
    },

    emits: {
      selected: () => true
    },

    const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

    function clicked() {
      emit('selected');
    }

    return { ponyImageUrl, clicked };
    </script>
{% endraw %}

## Retour implicite

On peut également supprimer le `return` à la fin&nbsp;:
toutes les déclarations de haut niveau à l'intérieur d'un `script setup` (ainsi que les imports)
sont automatiquement disponible dans le template.
Ici `ponyImageUrl` et `clicked` sont disponibles sans avoir besoin de les renvoyer.

C'est la même chose pour les `components`&nbsp;!
Importer le composant `Image` est suffisant,
et Vue comprend qu'il est utilisé dans le template.
On peut donc enlever la déclaration `components`.

Pony.vue
{% raw %}
    <script setup lang="ts">
    import { computed, PropType } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    props: {
      ponyModel: {
        type: Object as PropType<PonyModel>,
        required: true
      },
      isRunning: {
        type: Boolean,
        default: false
      }
    },

    emits: {
      selected: () => true
    },

    const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

    function clicked() {
      emit('selected');
    }
    </script>
{% endraw %}

---


On y est presque&nbsp;:
il reste à migrer les déclarations `props` et `emits`.

## defineProps

Vue nous donne une fonction `defineProps` que l'on peut utiliser pour déclarer les props.
C'est une fonction disponible à la compilation (une macro),
il n'y a donc pas besoin de l'importer dans le code&nbsp;:
Vue comprend tout seul lorsqu'il compile le composant.

`defineProps` renvoie les props&nbsp;:

    const props = defineProps({
      ponyModel: {
        type: Object as PropType<PonyModel>,
        required: true
      },
      isRunning: {
        type: Boolean,
        default: false
      }
    });

`defineProps` reçoit la même déclaration que `props` comme paramètre.
Mais on peut faire encore mieux pour les utilisateurs TypeScript&nbsp;!

`defineProps` est typé de façon générique&nbsp;:
on peut l'appeler sans paramètre,
mais en spécifiant une interface comme "forme" des props.
Plus besoin de l'horrible `Object as PropType<Something>`&nbsp;!
On peut utiliser de vrais types TypeScript,
et ajouter `?` pour marquer une prop comme optionnelle 😍.

    const props = defineProps<{
      ponyModel: PonyModel;
      isRunning?: boolean;
    }>();

Nous avons perdu un bout d'information cependant.
Dans la version précédente, nous pouvions spécifier que `isRunning` avait une valeur par défaut à `false`.
Pour avoir le même comportement, on peut utiliser la fonction `withDefaults`&nbsp;:

    interface Props {
      ponyModel: PonyModel;
      isRunning?: boolean;
    }

    const props = withDefaults(defineProps<Props>(), { isRunning: false });

La dernière partie à migrer est la déclaration des événements.

## defineEmits

Vue nous offre également une fonction `defineEmits`,
très similaire à `defineProps`.
`defineEmits` renvoie la fonction `emit`&nbsp;:

    const emit = defineEmits({
      selected: () => true
    });

Ou encore mieux, avec TypeScript&nbsp;:

    const emit = defineEmits<{
      (e: 'selected'): void;
    }>();

La déclaration complète est plus courte de 10 lignes,
ce qui est pas mal pour un composant d'une trentaine de lignes&nbsp;!
Le composant est plus simple à lire, et plus facile à écrire en TypeScript.
Il est cependant un peu étrange de voir tout exposé automatiquement dans le template,
sans avoir à écrire de return, mais on s'habitue.

Pony.vue
{% raw %}
    <template>
      <figure @click="clicked()">
        <Image :src="ponyImageUrl" :alt="ponyModel.name" />
        <figcaption>{{ ponyModel.name }}</figcaption>
      </figure>
    </template>

    <script setup lang="ts">
    import { computed } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    interface Props {
      ponyModel: PonyModel;
      isRunning?: boolean;
    }

    const props = withDefaults(defineProps<Props>(), { isRunning: false });

    const emit = defineEmits<{
      (e: 'selected'): void;
    }>();

    const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

    function clicked() {
      emit('selected');
    }
    </script>
{% endraw %}

## Fermé par défaut et defineExpose

Il y a une différence subtile entre les deux façons d'écrire des composants&nbsp;:
un composant `script setup` est "fermé par défaut".
Cela veut dire que d'autres composants ne voit pas ce qui est défini à l'intérieur de celui-ci.

Par exemple, le composant `Pony` peut accéder au composant `Image` qu'il utilise
(en utilisant des refs, comme on le verra dans un chapitre plus loin).
Si `Image` est déclaré avec `defineComponent`,
alors tout ce que renvoie sa fonction `setup` est aussi visible par le composant parent (`Pony`).
En revanche, si `Image` est défini avec `script setup`,
alors _rien_ n'est visible pour le composant parent.
`Image` peut cependant exposer ce qu'il souhaite en ajoutant `defineExpose({ key: value })`.
Alors `value` sera accessible comme étant `key`.

Cette syntaxe est donc celle qui est recommandée pour construire tes composants,
et elle est très cool à utiliser&nbsp;!

Notre [ebook](https://books.ninja-squad.com/vue), [formation en ligne](https://vue-exercises.ninja-squad.com/) et [formation](https://ninja-squad.com/training/vue) sont à jour avec ces changements si vous voulez en apprendre plus&nbsp;!
