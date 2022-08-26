This repository serves the following purpose
- you have F5 BIGIP involved in BGP peering, receiving full internet route
- you want to treat dataplane traffic differently based on ASN of destination IP

Highlevel workflow
- F5 BIGIP have BGP peering through Zebos (manage via imish command)
- script bgproutedumper.sh runs periodically (triggered by bigip icall), doing this stuff
  1. copy current route list (route.current) to previous route list (route.prev)
  2. fill (route.current) with new information from recent received BGP prefixes
  3. compare (route.current) with (route.prev). If there is delta, update external datagroup. Otherwise, do nothing.

Usage of the external datagroup is outside the scope of this repo.
