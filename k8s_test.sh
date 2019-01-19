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
  service_name=$(kubectl get svc -o=jsonpath='{range .items['"$i"']}{.metadata.name}{end}' --namespace=dev)
  #gets the service IP address
  service_IP=$(kubectl get svc -o=jsonpath='{range .items['"$i"']}{.status.loadBalancer.ingress[0].ip}{end}' --namespace=dev)
  #gets the service endpoint (IP address and port)
  service_endpoint=$(kubectl get svc -o=jsonpath='{range .items['"$i"']}{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}{end} --namespace=dev')
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

echo Test Five: Workload Revision History
echo Checking workloads to see if revision history was set up during the workload deployment
printf '\n'
sleep 3
#add the list of rollout histories for the list of unique workloads


for((i=0;i<${#workload_list_unique[@]};i++));do
  rollout_list=()
  rollout_list+=$(kubectl rollout history ${workload_list_unique[$i]})
  #sort and make the list of revisions unique
  revision_list=($(echo $rollout_list | tr " " "\n" | sort -u))
  #split the workload type/workloads by the delimiter

  workload_full=($(echo ${workload_list_unique[$i]} | tr "/" "\n" ))
  #get the workload type
  workload_type=($(echo ${workload_full[0]} | tr '[:upper:]' '[:lower:]'))
  workload_type+="s"
  #get the workload name
  workload_name=${workload_full[1]}

  #trying to find out if the revision history items are just numbers. If revision history was properly set up then the item should have the revision item and action taken
  for((f=0;f<${#revision_list[@]};f++));do
    #exclude the workload type, name, and "REVISION" from this check
    if [[ ${revision_list[$f]} == $workload_type ]] || [[ ${revision_list[$f]} == "\"$workload_name"\" ]] || [[ ${revision_list[$f]} == "REVISION" ]]
    then
      continue
    #if the revision list items are just numbers (less those previous exclusions) then revision history was not set up
    elif [[ ${revision_list[$f]} == [0-9]* ]]
    then
      results+=("Revision History is not on")
    fi
  done
  printf '\n\n'
  if [[ $results == "Revision History is not on" ]]; then
    echo "Test Five: Failure for ${workload_list_unique[$i]}"
    echo Workload Versioning was not set up during deployment
  else
    echo "Test Five: Pass for ${workload_list_unique[$i]}"
    echo Workload Versioning was set up
  fi
  sleep 3
done
printf '\n\n'
echo Test Five Complete

echo Test Six: Pod Resiliency pt 1
echo 'Pod Restarts on Working Nodes'
printf '\n'
sleep 3
#defines first pod and pod's node
pod1_name=$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}')
node1_name=$(kubectl get pods -o=jsonpath='{.items[0].spec.nodeName}')

echo Pod: $pod1_name is currently on node: $node1_name
printf '\n'
sleep 2
echo This test will drain and cordon node: $node1_name
printf '\n\n'
sleep 2
echo Pod: $pod1_name will be rebuilt on another node
printf '\n\n\n'
#cordon and drain first node
#pod should be removed from node and should reappear on another node with the same name (StatefulSet pods keep the same names)
kubectl cordon $node1_name
printf '\n\n'
sleep 2
echo This next step will take some time to complete
printf '\n\n'
kubectl drain $node1_name --grace-period=900  --force --delete-local-data --ignore-daemonsets
#find the pod again and the new node
node1_name_new=$(kubectl get pod $pod1_name -o=jsonpath='{.spec.nodeName}')
printf '\n'
echo Pod: $pod1_name is now on node: $node1_name_new
printf '\n'
sleep 2
if [[ $node1_name != $node1_name_new ]]
then
  echo Test Six: Pass
  echo $pod1_name has been moved from $node1_name to $node1_name_new
  printf '\n'
else
  echo Test Six: Failure
  echo $pod1_name has not been moved to $node1_name_new
  printf '\n'
fi
#uncordon first node (pod may eventually return to this node)
sleep 2
echo Restarting Node $node1_name
printf '\n'
kubectl uncordon $node1_name
printf '\n'
echo Test Six Complete
printf '\n\n\n'