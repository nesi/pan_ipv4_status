#Generate the original tables for displaying 
#This will not regenerate the html files we are using
#They will be missing the vertical U in the racks (pdu's and switches), which have been manually added later.

@web_base = 'http://xcat.ceres.auckland.ac.nz'
@tdc_rows = ['18','15']
@tdc_cols = ['L','K','I','H','G','E','D','B']
@ping_target = 'ib_net' #Matches the hash key in the rack_master.json file 
@state_file = 'ib_state.json' #Where the web page gets the current state data from
@web_page_title = 'IB Linkinfo State'

File.open("../tmp/www/test.html","w") do |fd| 

fd.puts <<-EOF
<html>
  <head>
  <title>TDC</title>
  <meta name="robots" content="noindex,nofollow" />
  <meta name="description" content="Pan Cluster '#{@web_page_title}" />
  
  <script> var ping_target='#{@ping_target}';
           var state_file='#{@state_file}'
           var page_header='#{@web_page_title}'
  </script>

  <script src="http://xcat.ceres.auckland.ac.nz/rgraph/libraries/RGraph.common.core.js" ></script>
  <script src="http://xcat.ceres.auckland.ac.nz/rgraph/jquery.min.js"></script>

  <style type="text/css">
  table.rack {
    background-color: black;
  }
  table.rack td {
    border-width: 1px;
    border-style: solid;
    border-color: black;
    padding: 0px;
    padding: 0px;
    background-color: black;
    color: white;
    font-family:sans-serif;
    font-size:4pt;
    height: 5px;
    width: 50px;
  }
  table.rack th {
    border-width: 1px;
    border-style: solid;
    border-color: black;
    padding: 0px;
    padding: 0px;
    background-color: grey;
    color: white;
    font-family:sans-serif;
    font-size:12pt;
  }
  table.rack th.u {
      background-color: black;
      color: white;
      font-family:sans-serif;
      font-size:4pt;
      height: 5px;
      width: 5px;
   }
  table.rack td.v {
      background-color: black;
      color: white;
      font-family:sans-serif;
      font-size:4pt;
      height: 50px;
      width: 5px;
   }
  table.rack td.v4 {
      background-color: black;
      color: white;
      font-family:sans-serif;
      font-size:4pt;
      height: 20px;
      width: 5px;
   }
  table.rack td.v5 {
      background-color: black;
      color: white;
      font-family:sans-serif;
      font-size:4pt;
      height: 25px;
      width: 5px;
   }
   table.tdcrow {
     background-color: white;
     border-width: 0px;
   }
   table.tdcrow th.u {
     background-color: black;
     color: white;
     font-family:sans-serif;
     font-size:4pt;
     height: 5px;
     width: 5px;
   }
  </style>
  <script>
  function set_cell(cell_id, new_state, title) {
      var the_cell = document.getElementById(cell_id);
      if(the_cell != null) {
        switch(new_state) {
          case 'no_u': //There isn't such a U in the rack
            the_cell.style.backgroundColor = 'black';
            the_cell.style.borderColor = 'black';
            the_cell.title = cell_id ;
            return;
          case 'no_state': //we know there will not be a state record
            the_cell.style.backgroundColor = 'grey';
            the_cell.style.borderColor = 'white';
            the_cell.title = cell_id ;
            return;
          case 'blank': //known filler in the rack
            the_cell.style.backgroundColor = 'black';
            the_cell.style.borderColor = 'white';
            the_cell.title = cell_id ;
            return;
          case 'ok':
            the_cell.style.backgroundColor = '#00FF00'; //green
            the_cell.style.borderColor = 'white';
            break;
          case 'degraded':
            the_cell.style.backgroundColor = 'orange';
            the_cell.style.borderColor = 'white';
            break;
          case 'fault':
            the_cell.style.backgroundColor = '#FF0000'; //red
            the_cell.style.borderColor = 'white';
            break;
          case 'unexpected': //didn't expect there to be data
            the_cell.style.backgroundColor = '#0000FF'; //blue
            the_cell.style.borderColor = 'orange';
            break
          default: //no data, but expected it
            the_cell.style.backgroundColor = 'white';
            the_cell.style.borderColor = 'orange';
        }
        the_cell.title = title + '\n' + cell_id ;
      }
    }
    
    var delay_master = 3600000; //2.5 minutes
    var delay_state = 150000; //5 minutes
    var racks = {}; //record of what should be, by rack, then U in the rack. What machine is expected where, and any state it should have (some state is implied by there being a record)
    var tdc_rack = ['L15','L15_D','K15','K15_B',
                   'I15','I15_D','H15','H15_B','G15','G15_A','G15_B','G15_C','G15_D',
                   'E15','E15_D','D15','D15_B','B15','B15_A','B15_B','B15_C','B15_D',
                   'I18','I18_B','H18','H18_D','G18','G18_A','G18_B','G18_C','G18_D',
                   'E18','E18_B','D18','D18_D','B18','B18_A','B18_B','B18_C','B18_D']; //And what racks (column names) are of interest to us.
    
    function myAJAXCallback_master(data) {
      //alert("in myAJAXCallback_master");
      process_racks(data);
      // Make another AJAX call after the delay (which is in milliseconds)
      setTimeout(function () { RGraph.AJAX.getJSON('rack_master.json' + "?timestamp="+ Date.now(), myAJAXCallback_master); }, delay_master);
    }
    
    function myAJAXCallback_state(data) {
      process_each_rack(data.state)
      // Make another AJAX call after the delay (which is in milliseconds)
      setTimeout(function () { RGraph.AJAX.getJSON(window.state_file + "?timestamp="+ Date.now(), myAJAXCallback_state); }, delay_state);
    }
    
    function process_racks(racks_master) {
      if(racks_master != null) { //We have loaded the master record of what should be in the racks.
        window.racks = racks_master.rack; //context will be in a callback, so need to be explicit 
        for(var r in window.racks ) { //each rack
          nodes = window.racks[r]['nodes'] //List of nodes in the rack
          var rack_u = [];
          for(var i=1; i<= window.racks[r]['U']; i++ ) { //ensure undefined U in rack have blank plates
            rack_u[i] = { "model": "BLANK", "u": i, "u_depth": 1, "management_net": "", "provisioning_net": "", "ipoib_net": "",  "ib_net": ""}
          }
          for(var u in nodes) { //overwrite blank plates with actual nodes defined in json.
            for(var i=0; i < nodes[u]['u_depth']; i++){
              //alert(nodes[u]['u']);
              rack_u[nodes[u]['u'] + i] = nodes[u];
            }
          }
          window.racks[r]['rack_u'] = rack_u ; //add in processed rack u's
          //alert(window.racks[r]['rack_u'][1]);
        }
      }
    }

    function process_each_rack(state) {
      if(window.racks != null) { //We have loaded the master record of what should be in the racks.
        for(var c = 0; c < window.tdc_rack.length; c++) { //columns in those rows
          var rack_name = window.tdc_rack[c]  ; //eg. B18
          //alert('processing ' + rack_name);
          if(window.racks[rack_name] != null && window.racks[rack_name]['rack_u'] != null) { //master json record knows about this rack.
            for(var u = 1; u <= window.racks[rack_name]['rack_u'].length; u++) { 
                if(window.racks[rack_name] != null && window.racks[rack_name]['rack_u'] != null && window.racks[rack_name]['rack_u'][u] != null) {
                if(window.racks[rack_name]['rack_u'][u]['model'] == 'BLANK') {
                  set_cell(rack_name + '_' + u.toString(), 'blank', rack_name + '_' + u.toString());
                } else { //set cell state based on management network state
                  if(  window.racks[rack_name]['rack_u'][u][window.ping_target]  == "" ) {
                    set_cell(rack_name + '_' + u.toString(), "no_state", rack_name + '_' + u.toString()) //we know there will not be a state record (or don't care)
                  } else {
                    set_cell(rack_name + '_' + u.toString(), state[ window.racks[rack_name]['rack_u'][u][window.ping_target] ], window.racks[rack_name]['rack_u'][u][window.ping_target] ) 
                  }
                }
              }
            }
          }
        }
      }
    }

    function init() {
    /**
    * Initial AJAX calls
    */
      var header = document.getElementById('header');
      
      setTimeout(function () {RGraph.AJAX.getJSON('rack_master.json' + "?timestamp="+ Date.now(), myAJAXCallback_master);}, 1000);
      setTimeout(function () {RGraph.AJAX.getJSON(window.state_file + "?timestamp="+ Date.now(), myAJAXCallback_state);}, 10000);
      header.innerHTML = window.page_header;
    }
  </script>
  </head>
  <body>
  <H1 id="header">XXXX State</H1>
  <table id="tdc" class="tdcrow">
	<tr ><th colspan="2">B-Rack</th><th>C2</th><th colspan="2">A-Rack</th><th>A2</th>
		<td>&nbsp;</td>
		<th>A3</th><th colspan="2">D-Rack</th><th>C4</th><th colspan="2">C-Rack</th><th colspan="2">E-Rack</th>
	</tr>
  <tr>
EOF

forward = true
@tdc_rows.each do |row|
  if forward == true
    @tdc_cols.each do |column|
      fd.puts "    <td><table id='#{column}#{row}' class=rack><tr><th>&nbsp;</th><th>#{column}#{row}</th></tr>"
      48.downto(1) do |u| 
        fd.puts "      <tr><th class=u>#{u}</th><td title='#{column}#{row}_#{u}' id='#{column}#{row}_#{u}'><a href=\"#{column}#{row}_#{u}.html\">&nbsp</a></td></tr>"
      end
      fd.puts "    </table></td>"
    end
    forward = false
  else
    @tdc_cols.reverse.each do |column|
      fd.puts "    <td><table id='#{column}#{row}' class=rack><tr><th>&nbsp;</th><th>#{column}#{row}</th></tr>"
      48.downto(1) do |u| 
        fd.puts "      <tr><th class=u>#{u}</th><td title='#{column}#{row}_#{u}' id='#{column}#{row}_#{u}'><a href=\"#{column}#{row}_#{u}.html\">&nbsp</a></td></tr>"
      end
      fd.puts "    </table></td>"
    end
  end
  fd.puts "<td width=\"50px\">&nbsp;</td>" if row == '18'
end

fd.puts <<-EOF
    </tr></table>
    <script>
      init();
    </script>
  </body>
</html>
EOF
  
end
