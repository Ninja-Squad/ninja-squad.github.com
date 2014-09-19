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

<div id="chart_ventes" style="width: 100%; height: 400px;"></div>

bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla
bla bla bla bla bla bla

## Achats par tarifs

<div id="chart_tarifs" style="width: 100%; height: 400px;"></div>

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
			legend: {
				position: 'none'
			},
			chartArea:{width:'85%',height:'80%'},
			curveType: 'function'
		};

		var formatter = new google.visualization.NumberFormat({decimalSymbol: ',', suffix: '€', groupingSymbol: '.'});
		formatter.format(dataVentes, 1);

		var chartVentes = new google.visualization.LineChart(document.getElementById('chart_ventes'));
		chartVentes.draw(dataVentes, optionsVentes);
		
		var dataTarifs = new google.visualization.DataTable();
		dataTarifs.addColumn('number', 'Tarif HT');
		dataTarifs.addColumn('number', 'Nombre d\'achats');
		dataTarifs.addColumn({type:'string', role:'annotation'});
		dataTarifs.addColumn({type:'string', role:'annotationText'});
		dataTarifs.addRows([
			[0, 0, null, null],
			[2.00, 88.00, 'M', 'Prix minimum'],
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
			[10.00, 104.00, 'D1', '1er prix par défaut'],
			[12.00, 6.00, null, null],
			[12.50, 6.00, null, null],
			[13.00, 9.00, null, null],
			[14.00, 3.00, null, null],
			[15.00, 11.00, null, null],
			[16.67, 1.00, null, null],
			[17.00, 2.00, null, null],
			[18.00, 1.00, null, null],
			[20.00, 43.00, 'D2', '2nd prix par défaut'],
			[25.00, 6.00, null, null],
			[30.00, 5.00, null, null],
			[35.00, 3.00, null, null],
			[40.00, 1.00, null, null],
			[50.00, 3.00, null, null]
		]);

		var optionsTarifs = {
			title: 'Le nombre d\'achats par tarif HT librement choisi',
			legend: {
				position: 'none'
			},
			bar: {groupWidth: "2"},
			chartArea:{width:'85%',height:'80%'},
			annotations: {
				alwaysOutside: true
			},
			hAxis: {
				title: 'Le prix HT décidé par l\'acheteur',
				format: '#€'
			},
			vAxis: {
				logScale: true
			}
		};
		formatter.format(dataTarifs, 0);

		var formatter = new google.visualization.NumberFormat({decimalSymbol: ',', suffix: '€', groupingSymbol: '.'});

		var chartTarifs = new google.visualization.ColumnChart(document.getElementById('chart_tarifs'));
		chartTarifs.draw(dataTarifs, optionsTarifs);
	}
</script>
