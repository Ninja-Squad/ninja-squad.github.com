---
layout: page
title: Blog Ninja Squad
tagline: Set&lt;AwesomeDeveloper&gt;
---

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date:"%Y-%m-%d" }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
