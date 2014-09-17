---
layout: post
title: Bilan des ventes de l'ebook AngularJS
author: clacote
tags: ["ebook","angularjs", "bilan"]
---

bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla

## Ventes par jour

### Version Google Charts

<div id="chart_ventes" style="width: 100%;"></div>

### Version Infogr.am

<script id="infogram_0_ebook--ventes-en-montants" src="//e.infogr.am/js/embed.js" type="text/javascript"></script><div style="width:100%;border-top:1px solid #acacac;padding-top:3px;font-family:Arial;font-size:10px;text-align:center;"><a target="_blank" href="//infogr.am/ebook--ventes-en-montants" style="color:#acacac;text-decoration:none;">Volume en euros des ventes par jour</a> | <a style="color:#acacac;text-decoration:none;" href="//infogr.am" target="_blank">Create Infographics</a></div>

bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla

## Achats par tarifs

### Version Google Charts

<div id="chart_tarifs" style="width: 100%;"></div>

### Version Infogr.am

<script id="infogram_0_ebook--volume-par-tarif" src="//e.infogr.am/js/embed.js" type="text/javascript"></script><div style="width:100%;border-top:1px solid #acacac;padding-top:3px;font-family:Arial;font-size:10px;text-align:center;"><a target="_blank" href="//infogr.am/ebook--volume-par-tarif" style="color:#acacac;text-decoration:none;">Nombre d'achats par tarif</a> | <a style="color:#acacac;text-decoration:none;" href="//infogr.am" target="_blank">Create Infographics</a></div>


<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
	google.load("visualization", "1", {packages:["corechart"]});
	google.setOnLoadCallback(drawCharts);

	function drawCharts() {
		
		var dataVentes = new google.visualization.DataTable();
		dataVentes.addColumn('string', 'Date');
		dataVentes.addColumn('number', 'Ventes HT');
		dataVentes.addColumn({type:'string', role:'annotation'});
		dataVentes.addColumn({type:'string', role:'annotationText'});
		dataVentes.addRows([
			['01/09', 4.00, 'T', 'Nos tests en production'],
			['02/09', 846.33, 'J', 'Le jour J de la mise en vente'],
			['03/09', 641.33, null, null],
			['04/09', 528.48, null, null],
			['05/09', 374.33, null, null],
			['06/09', 203.33, null, null],
			['07/09', 143.00, null, null],
			['08/09', 315.50, 'M', 'Sortie de la version MOBI'],
			['09/09', 191.83, null, null],
			['10/09', 88.00, null, null],
			['11/09', 61.00, null, null],
			['12/09', 151.00, null, null],
			['13/09', 30.00, null, null],
			['14/09', 44.00, null, null],
			['15/09', 57.00, null, null],
			['16/09', 42.00, null, null],
			['17/09', 19.00, null, null]
		]);
		var optionsVentes = {
			title: 'Volume en euros des ventes HT par jour',
			curveType: 'function'
		};

		var formatter = new google.visualization.NumberFormat({decimalSymbol: ',', suffix: '€', groupingSymbol: '.'});
		formatter.format(dataVentes, 1);

		var chartVentes = new google.visualization.LineChart(document.getElementById('chart_ventes'));
		chartVentes.draw(dataVentes, optionsVentes);
		
		var dataTarifs = new google.visualization.DataTable();
		dataTarifs.addColumn('number', 'Tarif');
		dataTarifs.addColumn('number', 'Nombre d\'achats');
		dataTarifs.addColumn({type:'string', role:'annotation'});
		dataTarifs.addColumn({type:'string', role:'annotationText'});
		dataTarifs.addRows([
			[0, 0, null, null],
			[2.00, 88.00, 'M', 'Le prix TTC minimum'],
			[3.00, 8.00, null, null],
			[4.00, 9.00, null, null],
			[4.17, 1.00, null, null],
			[5.00, 53.00, null, null],
			[6.00, 1.00, null, null],
			[7.00, 3.00, null, null],
			[8.00, 11.00, null, null],
			[8.33, 6.00, null, null],
			[8.33, 1.00, null, null],
			[9.00, 3.00, null, null],
			[10.00, 104.00, 'D1', 'Le prix par défaut initial'],
			[12.00, 6.00, null, null],
			[12.50, 6.00, null, null],
			[13.00, 9.00, null, null],
			[14.00, 3.00, null, null],
			[15.00, 11.00, null, null],
			[16.67, 1.00, null, null],
			[17.00, 2.00, null, null],
			[18.00, 1.00, null, null],
			[20.00, 43.00, 'D2', 'Le prix par défaut dans un second temps'],
			[25.00, 6.00, null, null],
			[30.00, 5.00, null, null],
			[35.00, 3.00, null, null],
			[40.00, 1.00, null, null],
			[50.00, 3.00, null, null]
		]);

		var optionsTarifs = {
			title: 'Le nombre d\'achats par tarif',
			hAxis: {
				title: 'Le prix HT décidé par l\'acheteur',
				ticks: [5,10,15,20,25,30,35,40,45,50],
				format: '#€'
			}
		};
		formatter.format(dataTarifs, 0);

		var formatter = new google.visualization.NumberFormat({decimalSymbol: ',', suffix: '€', groupingSymbol: '.'});

		var chartTarifs = new google.visualization.LineChart(document.getElementById('chart_tarifs'));
		chartTarifs.draw(dataTarifs, optionsTarifs);
	}
</script>
