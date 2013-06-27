---
layout: post
title: Angular filter - Part 1
author: [cexbrayat]
tags: [javascript, angular]
canonical: http://hypedrivendev.wordpress.com/2013/06/28/angular-filter-part-1
---

L'une des fonctionalités les plus appréciables et méconnues d'Angular réside dans les filtres disponibles. Dans toutes applications web, il est courant de devoir filtrer ou réordonner une collection pour l'afficher. Les filtres Angular sont applicables à la fois en HTML ou en Javascript, à un seul élément ou un tableau. En HTML, la syntaxe se rapproche du style Unix, où l'on peut chaîner les commandes à l'aide du pipe. Par exemple, on peut appliquer un filtre nommé 'uppercase' sur une expression de la façon suivante :
{% raw %}
<pre>
  <code class="javascript">
    {{ expression | uppercase }}
  </code>
</pre>
{% endraw %}
On peut également chaîner plusieurs appels de filtre :
{% raw %}
<pre>
  <code class="javascript">
    {{ expression | uppercase | trim }}
  </code>
</pre>
{% endraw %}

Certains filtres prennent des paramètres : c'est le cas du filtre 'number', qui nécessite de préciser le nombre de chiffres suivant la virgule. Pour passer les paramètres au filtre, il suffir de procéder comme suit :
{% raw %}
<pre>
  <code class="javascript">
    {{ expression | number:2 | currency:'$'}}
  </code>
</pre>
{% endraw %}

Il est également possible d'invoquer les filtres depuis le code Javascript :
{% raw %}
<pre>
  <code class="javascript">
    $filter('uppercase')
  </code>
</pre>
{% endraw %}
Angular va alors retrouver la fonction de filtre correspondant à la chaîne de caractères passée en paramètre.

Angular propose par défaut certains filtres communs :

- number : permet de préciser le nombre chiffre après la virgule à afficher (arrondi au plus proche).

{% raw %}
<pre>
  <code class="javascript">
    {{ 87.67 | number:1 }} // 87.7 
  </code>
</pre>
{% endraw %}  

{% raw %}
<pre>
  <code class="javascript">
    {{ 87.67 | number:3 }} // 87.670
  </code>
</pre>
{% endraw %} 

- currency : permet de préciser la monnaie.
{% raw %}
<pre>
  <code class="javascript">
    {{ 87.67 | currency:'$' }} // $87.67
  </code>
</pre>
{% endraw %}

- date : permet de formatter l'affichage des dates, en précisant un pattern. On retrouve l'écriture classique de pattern :
{% raw %}
<pre>
  <code class="javascript">
    {{ today | date:'yyyy-MM-dd' }} // 2013-06-25
  </code>
</pre>
{% endraw %}  

Un certain nombre de pattern sont disponibles (avec un rendu différent selon la locale) :
{% raw %}
<pre>
  <code class="javascript">
    {{ today | date:'longDate' }} // June 25, 2013
  </code>
</pre>
{% endraw %}    

- lowercase/uppercase : de façon assez évidente, ces filtres vont convertir l'expression en majuscules ou miniscules.
{% raw %}
<pre>
  <code class="javascript">
    {{ "Cedric" | uppercase }} // CEDRIC   
    {{ "Cedric" | lowercase }} // cedric
  </code>
</pre>
{% endraw %}    

- json : moins connu, ce filtre permet d'afficher l'objet au format JSON. Il est également moins utile, car, par défaut, afficher un object avec la notation '{{ }}' convertit l'objet en JSON.
{% raw %}
<pre>
  <code class="javascript">
    {{ person | json }} // { name: 'Cedric', company: 'Ninja Squad'} 
  </code>
</pre>
{% endraw %}  

{% raw %}
<pre>
  <code class="javascript">
    {{ person }} // { name: 'Cedric', company: 'Ninja Squad'} 
  </code>
</pre>
{% endraw %}    

- limitTo : ce filtre s'applique quant à lui à un tableau, en créant un nouveau tableau ne contenant que le nombre d'éléments passés en paramètre. Selon le signe de l'argument, les éléments sont retenus depuis le début ou la fin du tableau.
{% raw %}
<pre>
  <code class="javascript">
    {{ ['a','b','c'] | limitTo:2 }} // ['a','b'] 
    {{ ['a','b','c'] | limitTo:-2 }} // ['b','c'] 
  </code>
</pre>
{% endraw %}  

- orderBy : là encore un filtre s'appliquant à un tableau. Celui-ci va trier le tableau selon le prédicat passé en paramètre. Le prédicat peut être une chaîne de caractères représentant une propriété des objets à trier ou une fonction. Le prédicat sera appliqué sur chaque élément du tableau pour donner un résultat, puis le tableau de ces résultats sera trié selon les opérateur <', '=', '>'. Une propriété peut être précédée du signe '-' pour indiquer que le tri doit être inversé. A la place d'un simple prédicat, il est possible de passer un tableau de propriétés ou de fonctions (chaque propriété ou fonction supplémentaire servant à affiner le tri primaire). Un second paramètre, booléen, permet quant à lui d'indiquer si le tri doit être inversé.
{% raw %}
<pre>
  <code class="javascript">
    var jb = {name: 'JB', gender: 'male'};    
    var cyril = {name: 'Cyril', gender: 'male'};     
    var agnes = {name: 'Agnes', gender: 'female'};     
    var cedric = {name: 'cedric', gender: 'male'};     
    $scope.ninjas = [jb, cyril, agnes, cedric];  
    
    // order by the property 'gender' 
    {{ ninjas | orderBy:'gender'}} // Agnes,JB,Cyril,Cédric 

    // order by a function (lowercase first) 
    $scope.lowercaseLast = function(elem){ 
      return elem.name === elem.name.toLowerCase() 
    }; 
    {{ ninjas | orderBy:lowercaseLast }} // Agnes,JB,Cyril,cedric 

    // order by an array of properties or functions 
    {{ ninjas | orderBy:['-gender','name'] }} // cedric,Cyril,JB,Agnes 
  </code>
</pre>
{% endraw %}

Dans le prochain billet, nous verrons comment créer nos propres filtres.

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/06/28/angular-filter-part-1 "Article original sur le blog de Cédric Exbrayat")_