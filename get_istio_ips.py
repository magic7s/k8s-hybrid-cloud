#!/usr/bin/env python

import subprocess
import json
import sys
import os

my_env = os.environ.copy()
if len(sys.argv) > 1:
  my_env["KUBECONFIG"] = sys.argv[1]

cmd_list = {
"PILOT_POD_IP"     : "kubectl -n istio-system get pod -l istio=pilot -o jsonpath='{.items[0].status.podIP}'",
"POLICY_POD_IP"    : "kubectl -n istio-system get pod -l istio-mixer-type=policy -o jsonpath='{.items[0].status.podIP}'",
"STATSD_POD_IP"    : "kubectl -n istio-system get pod -l istio=statsd-prom-bridge -o jsonpath='{.items[0].status.podIP}'",
"TELEMETRY_POD_IP" : "kubectl -n istio-system get pod -l istio-mixer-type=telemetry -o jsonpath='{.items[0].status.podIP}'",
"ZIPKIN_POD_IP"    : "kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{range .items[*]}{.status.podIP}{end}'"
}

output = {}

for var in (cmd_list):
  try:
    output[var] = subprocess.check_output(cmd_list[var].split(" "), stderr=subprocess.STDOUT, env=my_env)
    output[var] = output[var].strip("\'")
  except Exception, e:
    output[var] = ""

print (json.dumps(output, indent=4, sort_keys=True))