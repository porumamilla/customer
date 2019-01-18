#!/bin/bash
printf '\n'
echo Part I: Auto Tests
printf '\n\n'
sleep 2

echo "Test One: Node Health"
echo "Checking nodes and kubelets for the 'Ready' status"
printf '\n'
sleep 2
i="0"
#get the list of node names
node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}|{.metadata.name}')
#count the list of names -> needed for the while loop
node_counting=$(echo $node_list | grep -o "|" | wc -l)
#for each node run these commands
for((i=0;i<$node_counting;i++));do
  #get the node reason for node i
  node_reason=$(kubectl get nodes -o=jsonpath='{.items['"$i"'].status.conditions[7].reason}')
  #get the node type for node i
  node_type=$(kubectl get nodes -o=jsonpath='{.items['"$i"'].status.conditions[7].type}')
  #if node reason is KubeletReady (good) and node type is Ready (good) then pass
  if [[ $node_reason == "KubeletReady" && $node_type == "Ready" ]]
  then
    echo Test One: Pass for $(kubectl get nodes -o=jsonpath='{range .items['"$i"']}{.metadata.name}')
    echo Node and Kubelet are Ready
    printf '\n'
  #if node reason is not KubeletReady (bad) and node type is Ready (good) then warning
  elif [[ $node_reason != "KubeletReady" && $node_type == "Ready" ]]
  then
    echo Test One: Warning for $(kubectl get nodes -o=jsonpath='{range .items['"$i"']}{.metadata.name}')
    echo Node is Ready Kubelet is Not
    printf '\n'
  #if node reason is KubeletReady (good) and node type is not Ready (bad) then warning
  elif [[ $node_reason == "KubeletReady" && $node_type != "Ready" ]]
  then
    echo Test One: Warning for $(kubectl get nodes -o=jsonpath='{range .items['"$i"']}{.metadata.name}')
    echo Kubelet is Ready Node is Not
    printf '\n'
  #if node reason is not KubeletReady (bad) and node type is not Ready (bad) then fail
  else
    echo Test One: Failure for $(kubectl get nodes -o=jsonpath='{range .items['"$i"']}{.metadata.name}')
    echo Node and Kubelet are Not Ready
    printf '\n'
  fi
  #after each node wait 3 seconds and start testing the next node
  sleep 2
done
echo Test One Complete


printf '\n\n\n'
sleep 3

#exit

echo "Test Two: Pod Health"
printf '\n\n'
echo "Comparing the number of requested and available pods"
printf '\n'

sleep 2
i="0"
#create blank array for workloads
workload_list=()
#get the list of pipe delimited pod names this will be used to find the list of unique workloads (StatefulSets, Deployments, Replication Controllers, etc.)
pods_counting_list=$(kubectl get pods -o=jsonpath='{range .items[*]}|{.metadata.name}{end}')
#count the number of pods using the pipe delimiter to separate each pod name
pod_counting=$(echo $pods_counting_list | grep -o "|" | wc -l)
#there was some whitespace before the number of pods, removing that here
#pod_counting_no_whitespace="$(echo -e "${pod_counting}" | tr -d '[:space:]')"
#for each pod run these commands
for((i=0;i<$pod_counting;i++));do
  #get the workload type from pod i
  workload_type=$(kubectl get pods -o=jsonpath='{.items['"$i"'].metadata.ownerReferences[0].kind}')
  #get the workload name from pod i
  workload=$(kubectl get pods -o=jsonpath='{.items['"$i"'].metadata.ownerReferences[0].name}')
  #add pod i's workload type and name to the list
  workload_list+=("$workload_type/$workload")
  #start working on the next pod
done

#after getting all of the pods' workloads, remove duplicates in case some have replicasets >1 (trim spaces and get unique list)
workload_list_unique=($(printf "%s\n" "${workload_list[@]}" | tr ' ' " \n" | sort -u))

#for each unique workload run these commands
for((i=0;i<${#workload_list_unique[@]};i++)); do
  #get the number of replicas for workload i
  replica_count=$(kubectl get ${workload_list_unique["$i"]} -o=jsonpath='{.status.replicas}')
  #get the number of ready replicas for workload i
  ready_replica_count=$(kubectl get ${workload_list_unique["$i"]} -o=jsonpath='{.status.readyReplicas}')
  #if there are more replicas than ready replicas then something is wrong with the other pods
  if [[ $ready_replica_count < $replica_count ]]
  then
    echo Test Two: Failure for ${workload_list_unique["$i"]}
    echo ${workload_list_unique["$i"]} has requested $replica_count pods, but only $ready_replica_count are ready
    echo
    printf '\n\n'
  else
    echo Test Two: Pass for ${workload_list_unique["$i"]}
    echo All $replica_count pods in ${workload_list_unique["$i"]} are up and running
    printf '\n'
  fi
done
echo Test Two Complete

printf '\n\n\n'
sleep 3

#exit


echo Test Three: Logs Running
printf '\n'
sleep 2
#get list of dameonset names
ds_list=$(kubectl get ds --all-namespaces -o=jsonpath='{range .items[*]}|{.metadata.name}')
#get count of dameonset names
ds_counting=$(echo $ds_list | grep -o "|" | wc -l)
#i="0"
#for each daemonset run these commands
echo Testing DaemonSets to make sure that logs are being recorded for all nodes
printf '\n'
for((i=0;i<$ds_counting;i++));do
  #for daemonset i get the node selector --> looking for one equal to beta.kubernetes.io/fluentd-ds-ready:true
  node_selector=$(kubectl get ds --all-namespaces -o=jsonpath='{.items['"$i"'].spec.template.spec.nodeSelector}')
  #for daemonset i get the number of scheduled nodes
  nodes_scheduled=$(kubectl get ds --all-namespaces -o=jsonpath='{.items['"$i"'].status.desiredNumberScheduled}')
  #for daemonset i get the number of ready nodes
  nodes_ready=$(kubectl get ds --all-namespaces -o=jsonpath='{.items['"$i"'].status.numberReady}')
  #for daemonset i get the number of currently scheduled nodes
  nodescurrently_scheduled=$(kubectl get ds --all-namespaces -o=jsonpath='{.items['"$i"'].status.currentNumberScheduled}')
  #if node selector for node i is map[beta.kubernetes.io/fluentd-ds-ready:true and the number of scheduled, ready, and currently scheduled nodes are equal
  if [[ $node_selector == "map[beta.kubernetes.io/fluentd-ds-ready:true]" && $nodes_scheduled == $nodes_ready && $nodes_ready == $nodescurrently_scheduled ]]
  then
    results="pass"
  fi
  #go through all daemonsets
done
sleep 2
#if any of the daemonsets fulfilled those conditions then the test was successful
if [[ $results=="pass" ]]
then
  echo Test Three: Pass
  echo Logs are running for all nodes
else
  echo Test Three: Failure
  echo Logs are not running for all nodes
fi
printf '\n'
echo Test Three Complete
printf '\n\n\n'
sleep 3

#exit

echo Test Four: Service Endpoint Check
printf '\n'
sleep 2
#Count of total services
services=(kubectl get svc -o=jsonpath='{.items[*]}')
#service_count=("${#services[@]}")
echo Getting and checking all "${#services[@]}" service endpoints
printf '\n'

for((i=0;i<${#services[@]};i++));do
  #gets the name of the service
  service_name=$(kubectl get svc -o=jsonpath='{range .items['"$i"']}{.metadata.name}{end}')
  #gets the service IP address
  service_IP=$(kubectl get svc -o=jsonpath='{range .items['"$i"']}{.status.loadBalancer.ingress[0].ip}{end}')
  #gets the service endpoint (IP address and port)
  service_endpoint=$(kubectl get svc -o=jsonpath='{range .items['"$i"']}{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}{end}')
  #returns service name and endpoint
  echo -e service: $service_name "\nendpoint for" $service_name: $service_endpoint
  #checks the service endpoint to see if it is running
  URL_check=$(curl -Is http://$service_endpoint | head -n 1)
  #Does the service have an IP address
  if [ ! $service_IP ];
  then
    echo Test Four: Failure for service $service_name
    echo service $service_name does not have an IP address
    printf '\n'
  #Does the endpoint work
  elif [[ ! $URL_check ]];
  then
    echo Test Four: Failure for service $service_name
    echo the endpoint for service $service_name is unresponsive
    printf '\n'
  else
    echo Test Four: Pass for service $service_name
    echo service $service_name is running and serving traffic
    printf '\n'
  fi
  #DELETE i=$[$i+1]
  sleep 5
done
echo Test Four Complete