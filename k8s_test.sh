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