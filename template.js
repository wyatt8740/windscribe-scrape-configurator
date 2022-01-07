var json=JSON.parse('REPLACE_WITH_JSON');
var city='REPLACE_WITH_CITY';
var nickname='REPLACE_WITH_NICKNAME';
var i=0;
var j=0;
function gethostnames() {
  while(i<json.data.length) {
    while(j < json.data[i].nodes.length && j >= 0) {
      var grp=json.data[i].nodes[j].group.toUpperCase();
      if(grp.includes(city.toUpperCase()) && grp.includes(nickname.toUpperCase().replace())) {
        console.log(json.data[i].nodes[j].hostname.replace(/\..*/,"") + '-' + city + '_' + nickname);
        j=-1
      }
      else {
        j++;
      }
    }
    j=0;
    i++;
  }
}
gethostnames();
