#!/bin/bash

####################
# common script init
if ! test -r ../utils.sh; then
	echo "run executable from its own directory: $0"; exit 1; fi
. ../utils.sh
Z="`detect_zenroom_path` `detect_zenroom_conf`"
####################

out='../../docs/examples/zencode_cookbook/reflow'
function save() {
	tee ${out}/$1 | tee ./$1 | jq .
}

cat << EOF > Agent.json
{ "Agent": {
  "id": "BADC0FFE",
  "name": "Alice",
  "note": "The smartypants who is lost in Wonderland",
  }
}
EOF

cat << EOF > EconomicResource.json
{ "EconomicResource": { 
        "accountingQuantity": {
          "hasNumericalValue": 0.0478270231353376,
          "hasUnit": {
            "label": "kilo"
          }
        },
        "currentLocation": {
          "lat": -18.895467439976088,
          "long": 13.45323887068065,
          "name": "Streich"
        },
        "id": "01EVTV5QR62V7A489V2W84NJHT",
        "image": null,
        "name": "Streich",
        "note": "Dicta velit quo neque qui unde fuga non laboriosam! Aliquam eligendi ex autem ut ratione incidunt et maiores voluptas? Vitae et repellat exercitationem omnis quos eaque totam pariatur. Autem quam a officiis rerum fuga aspernatur.",
        "primaryAccountable": {
          "name": "Cruickshank-Hodkiewicz"
        }
      }
    }
EOF

cat << EOF > EconomicEvent.json
{ "EconomicEvent": {
        "action": {
          "label": "transfer"
        },

        "id": "01EVTV5RCD4JTJDYX5HKERJ5KP",
        "note": "Earum placeat eveniet sint sint exercitationem ea? Sint libero perspiciatis ad et harum aliquid et minus. Natus reprehenderit asperiores sapiente quae.",
        "provider": {
          "id": "01EVTV5F0PHMH7R1J5A1QXEZM1",
          "name": "Cruickshank-Hodkiewicz"
        },
        "receiver": {
          "id": "01EVTV5F0PHMH7R1J5A1QXEZM1",
          "name": "Cruickshank-Hodkiewicz"
        },
        "resourceInventoriedAs": {
          "name": "Waters",
          "note": "Consequatur facilis dignissimos cum dolores dolorem qui facere numquam. Ea quia recusandae tempora modi facilis blanditiis dolores. Deserunt quia qui facere eius soluta vel quo itaque vitae. Nesciunt blanditiis ea nihil incidunt."
        },
        "resourceQuantity": {
          "hasNumericalValue": 0.5173676470814242,
          "hasUnit": {
            "label": "kilo"
          }
        }
      }
    }
EOF

cat << EOF > Process.json
{ "Process": {
  "finished": 0,
  "id": "01EVTV5F0PHMH7R1J5A1QXEZM1",
  "name": "A sample process",
  "note": "Description of a sample process",
  "inputs": [],
  "outputs": []
  }
}
EOF

cat <<EOF | zexe create_agent_reflow_identity.zen -a Agent.json | save identity_Alice.json
Scenario reflow
Given I am 'Alice'
and I have a 'string dictionary' named 'Agent'
When I create the reflow identity of 'Agent'
Then print 'reflow identity'
EOF

jq -s 'reduce .[] as $item ({}; . * $item)' . identity_Alice.json keypair_Alice.json | save alice.json

cat << EOF | debug create_seal_of_resource.zen -a EconomicResource.json -k alice.json | save EconomicResource_seal.json
Scenario reflow
Given I am 'Alice'
and I have my 'keys'
and I have a 'reflow identity'
and I have a 'string dictionary' named 'EconomicResource'
When I create the material passport of 'EconomicResource'
and I rename the 'material passport' to 'EconomicResource.seal'
Then print the 'EconomicResource'
and print the 'EconomicResource.seal'
EOF

cat << EOF | zexe verify_seal_of_resource.zen -a EconomicResource_seal.json
Scenario reflow
Given I have a 'string dictionary' named 'EconomicResource'
and I have a 'reflow seal' named 'EconomicResource.seal'
When I verify the material passport of 'EconomicResource'
Then print the string 'Valid Resource material passport'
EOF

cat << EOF | debug create_seal_of_event.zen -a EconomicEvent.json -k alice.json |tee EconomicEvent_seal.json 
Scenario reflow
Given I am 'Alice'
and I have my 'keys'
and I have a 'reflow identity'
and I have a 'string dictionary' named 'EconomicEvent'
When I create the material passport of 'EconomicEvent'
and I rename the 'material passport' to 'EconomicEvent.seal'
Then print the 'EconomicEvent'
and print the 'EconomicEvent.seal'
EOF

cat << EOF | zexe verify_seal_of_event.zen -a EconomicEvent_seal.json
Scenario reflow
Given I have a 'string dictionary' named 'EconomicEvent'
and I have a 'reflow seal' named 'EconomicEvent.seal'
When I verify the material passport of 'EconomicEvent'
Then print the string 'Valid Event material passport'
EOF

# cat << EOF | debug create_seal_of_process.zen -a Process.json -k keypair_Alice.json | tee Process_seal.json 
# Scenario reflow
# Given I have a 'string dictionary' named 'Process'
# and I have a 'bls public key array' named 'public keys'
# When I aggregate the bls public key from array 'public keys'
# and I rename the 'bls public key' to 'reflow public key'
# and I create the reflow identity of 'Process'
# and I create the reflow seal with identity 'reflow identity'
# and I rename the 'reflow seal' to 'Process.seal'
# Then print the 'Process'
# and print the 'Process.seal'
# EOF
