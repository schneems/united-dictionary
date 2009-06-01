// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


var maxrows=20;
var minrows = 3

function doResize() {
var txt=meaning.value;
var cols=meaning.cols;
var arrtxt=txt.split('\n');
var rows=arrtxt.length-1;
for (i=0;i<arrtxt.length;i++)
  rows+=parseInt(arrtxt[i].length/cols);
if (rows>meaning.maxrows)
meaning.rows=meaning.maxrows;
else if (rows<minrows)
meaning.rows==minrows;
else if (rows==minrows)
meaning.rows=minrows+1;
else 
meaning.rows=rows+1;

}