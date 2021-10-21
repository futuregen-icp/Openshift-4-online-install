while IFS= read line; do
   items=( $line )
   NAMESPACE=${items[0]}
   DC=${items[1]}
   if [ $NAMESPACE == "dob" ] || [ $NAMESPACE == "dap" ] || [ $NAMESPACE == "dbb" ] || [ $NAMESPACE == "dmy" ]; then
      echo "- dc/$DC -n $NAMESPACE"
      oc get dc/$DC -n NAMESPACE -o yaml | grep ET_HSM -A220
   fi
done
